package Bio_Bricks::KG::Mapping::OKGML::Processor::RML;
# ABSTRACT: Process mapping model to RML

use Mu;
use Object::Util magic => 0;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( InstanceOf ConsumerOf );

use curry;
use Attean::RDF qw(iri);
use Bio_Bricks::RDF::DSL;
use Types::Attean qw( AtteanIRI );
use Bio_Bricks::RDF::AtteanX::Types qw( RDFLiteral );
use Bio_Bricks::RDF::DSL::Types qw(RDF_DSL_Context);
use URI::NamespaceMap;

use aliased 'Bio_Bricks::KG::Mapping::OKGML::MapperContext' => 'MapperContext';
use Bio_Bricks::KG::Mapping::OKGML::Mapper::Null;

use Data::DPath qw(dpath);

ro model => (
	isa => InstanceOf['Bio_Bricks::KG::Mapping::OKGML::Model'],
);

lazy rml_context => method() {
	my $map = $self->uri_map;
	return Bio_Bricks::RDF::DSL::Context->new( namespaces => $map );
};

lazy uri_map => method() {
	my %base_mapping = (
		# R2RML and RML
		rr => 'http://www.w3.org/ns/r2rml#',
		rml => 'http://semweb.mmlab.be/ns/rml#',

		# Use by RML logical sources
		ql => 'http://semweb.mmlab.be/ns/ql#',

		# Function ontology <https://fno.io/>: RML-FNML, Function Ontology, etc.
		fnml => 'http://semweb.mmlab.be/ns/fnml#',
		fno => 'https://w3id.org/function/ontology#',
		grel => 'http://users.ugent.be/~bjdmeest/function/grel.ttl#',
	);

	my $map = URI::NamespaceMap->new({
		%base_mapping,
	});
	$map->guess_and_add( qw(rdf rdfs xsd) );

	while (my ($prefix, $nsURI) = $self->model->_data_prefixes->ns_map->each_map) {
		$map->add_mapping( $prefix, $nsURI );
	}

	$map;
};

method _rml_logical_source_subject( $mc ) {
	my $logical_source = iri(join '_',
		'ls',
		$mc->dataset->name,
		$mc->input->name =~ s,/,_,gr
	);

	return $logical_source;
}

method _rml_subject_map_po($mc) {
	die <<~ERROR unless $mc->model->has_class( $mc->element->mapper->class );
	Missing class:
	  dataset  : @{[ $mc->dataset->name ]}
	  input    : @{[ $mc->input->name ]}
	  element  : @{[ $mc->element->name ]}
	  class    : @{[ $mc->element->mapper->class ]}
	ERROR

	my $class = $mc->model->get_class( $mc->element->mapper->class );
	return qname('rr:subjectMap')    , bnode [
		qname('rr:template'), literal( $class->rml_template( $mc, $mc->element ) ),    #;
		qname('rr:class')   , olist( $class->types_to_attean_iri($mc->model) )
	],#;
}

method _rml_maybe_valuelabel_po($mc) {
	return () unless $mc->element->mapper->can('label_predicate_to_attean_iri');

	return qname('rr:predicateObjectMap'), bnode [
		qname('rr:predicate'), $mc->element->mapper->label_predicate_to_attean_iri($self->rml_context, $mc->model)            ,#;
		qname('rr:objectMap'), bnode [ qname('rml:reference'), literal($mc->element->mapper->label_column_for_element($mc)) ] ,#;
	],#
}

lazy _rdf_mapping_graph => method() {
	my $graph  = Attean::IRI->new('http://example.org/graph');
};

lazy _rdf_mapping_model => method() {
	my $store  = Attean->get_store('Memory')->new();
	my $model = Attean::QuadModel->new( store => $store );
	my $parser = Attean->get_parser('Turtle')->new();

	my $turtle_buffer = join "\n",
			$self->model->_data_prefixes->to_turtle_prefixes,
			$self->model->get_mappings->@*;
	my $iter = $parser->parse_iter_from_bytes( $turtle_buffer );
	my $quads = $iter->as_quads($self->_rdf_mapping_graph);

	$store->add_iter($quads);

	return $model;
};

method _rdf_mapping_results_for_class( $class ) {
	my $sparql = "SELECT * WHERE { <($class)> ?p ?o }";
	my $s = Attean->get_parser('SPARQL')->new();
	my ($algebra) = $s->parse($sparql);
	my $results = $self->_rdf_mapping_model->evaluate($algebra, $self->_rdf_mapping_graph);
	return $results;
}

method _rml_rdf_mapping_po( $mc ) {
	return () unless $mc->model->has_class( $mc->element->mapper->class );

	my $class = $mc->model->get_class( $mc->element->mapper->class );
	my $results = $self->_rdf_mapping_results_for_class( $class->name );

	my @po_list;
	while (my $r = $results->next) {
		my $p = $r->value('p');
		my $o = $r->value('o');
		my @objectMap;
		my ($template_name) =
			( $o->can('value') ? $o->value : $o->as_string ) =~ /\A \( (?<name>[^)]+)  \)  \z/x;

		if( $template_name ) {
			if( AtteanIRI->check( $o ) ) {
				die "No class $template_name" unless $mc->model->has_class( $template_name );
				my $class = $mc->model->get_class( $template_name );
				my @class_elements =
					grep { $_->mapper->can('class') && $_->mapper->class eq $template_name }
						dpath('/elements/*/mapper/..')->match($mc->input);
				for my $el (@class_elements) {
					push @objectMap, bnode [
						qname('rr:template'), literal( $class->rml_template( $mc, $el ) ),    #;
					]
				}
			} elsif( RDFLiteral->check($o) ) {
				die "No value $template_name" unless $mc->model->has_value( $template_name );
				my $value = $mc->model->get_value( $template_name );
				my @value_elements =
					grep { $_->mapper->can('value') && $_->mapper->value eq $template_name }
						dpath('/elements/*/mapper/..')->match($mc->input);
				for my $el (@value_elements) {
					die "$mc: Value @{[ $el->name ]} should only have a single column"
						unless $el->columns->@* == 1;
					push @objectMap, bnode [
						# TODO datatype from $value->datatype
						qname('rml:reference'), literal($el->columns->[0]), #,
					]
				}
			} else {
				# blank nodes could be here, but RML does not support that
				die "Unknown type: $o";
			}
		} else {
			push @objectMap, bnode [
				qname('rr:constant'), $o,    #;
			];
		}

		push @po_list,
			qname('rr:predicateObjectMap'), bnode [
				qname('rr:predicate'), $p  ,#;
				qname('rr:objectMap'), $_   #
			] for @objectMap;
	}

	return @po_list;
}

method generate_rml($MapperContext_curry, $elements) {
	my $dce = URI::Namespace
		->with::roles('Bio_Bricks::KG::Role::LazyIRIable')
		->new('http://purl.org/dc/elements/1.1/');
	rdf {
		context( $self->rml_context );

		my $mc_null = $MapperContext_curry->( element => undef );

		# logical source shared with all below
		my $logical_source = $self->_rml_logical_source_subject($mc_null);

		collect turtle_map $logical_source,
			a()                               , qname('rml:LogicalSource')       ,#;
			$dce->lazy_iri('source')          , literal($mc_null->dataset->name) ,#;
			$dce->lazy_iri('title')           , literal($mc_null->input->name)   ,#;
			qname('rml:source')               , literal($mc_null->input->name )  ,#;
			qname('rml:referenceFormulation') , qname('ql:CSV')                  ;#.

		my @classes = grep {
			$_->mapper isa 'Bio_Bricks::KG::Mapping::OKGML::Mapper::Class'
			or $_->mapper isa 'Bio_Bricks::KG::Mapping::OKGML::Mapper::ValueLabel'
		} @$elements;
		for my $class_element (@classes) {
			my $mc = $MapperContext_curry->( element => $class_element );


			collect bnode [
				a()                       , qname('rr:TriplesMap') ,#;
				qname('rml:logicalSource'), $logical_source        ,#;
				$self->_rml_subject_map_po($mc)                    ,#;
				$self->_rml_maybe_valuelabel_po($mc)               ,#;
				$self->_rml_rdf_mapping_po($mc)                    ,#;
			];#.
		}

	};
}


lazy triple_store =>
	method() {
		my $context = $self->rml_context;

		for my $dataset (values $self->model->_data_datasets->%*) {
			for my $input (values $dataset->inputs->%*) {
				my @elements = grep { ! $_->mapper->isa('Bio_Bricks::KG::Mapping::OKGML::Mapper::Null') }
					dpath('/elements/*/mapper/..')->match($input);
				next unless @elements;
				my $MCtx_curry = MapperContext->curry::new(
					model   => $self->model,
					dataset => $dataset,
					input   => $input,
				);

				$self->generate_rml( $MCtx_curry, \@elements );
			}
		}

		$context->store;
	},
	isa => ConsumerOf['Attean::API::Store'],
	;

1;
