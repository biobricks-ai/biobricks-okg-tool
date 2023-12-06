package Bio_Bricks::KG::Mapping::OKGML::Processor::RML;
# ABSTRACT: Process mapping model to RML

use Mu;
use Object::Util magic => 0;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( InstanceOf ConsumerOf );

use Attean::RDF qw(iri);
use Bio_Bricks::RDF::DSL;
use Bio_Bricks::RDF::DSL::Types qw(RDF_DSL_Context);
use URI::NamespaceMap;

use aliased 'Bio_Bricks::KG::Mapping::OKGML::MapperContext' => 'MapperContext';

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

method generate_rml($mc, $elements) {
	rdf {
		context( $self->rml_context );

		my $logical_source = iri(join '_',
			'ls',
			$mc->dataset->name,
			$mc->input->name =~ s,/,_,gr
		);

		collect turtle_map $logical_source,
			a()                               , qname('rml:LogicalSource')      ,#;
			qname('rml:source')               , literal($mc->input->name )      ,#;
			qname('rml:referenceFormulation') , qname('ql:CSV')                 ;#.


		my @classes = grep { $_->mapper isa 'Bio_Bricks::KG::Mapping::OKGML::Mapper::Class' } @$elements;
		for my $class_element (@classes) {
			die <<~ERROR unless $mc->model->has_class( $class_element->mapper->class );
			Missing class:
			  dataset  : @{[ $mc->dataset->name ]}
			  input    : @{[ $mc->input->name ]}
			  element  : @{[ $class_element->name ]}
			  class    : @{[ $class_element->mapper->class ]}
			ERROR
			my $class = $mc->model->get_class( $class_element->mapper->class );
			collect bnode [
				a()                       , qname('rr:TriplesMap') ,#;
				qname('rml:logicalSource'), $logical_source        ,#;
				qname('rr:subjectMap')    , bnode [
					qname('rr:template'), literal( $class->rml_template( $mc->model, $class_element ) ),    #;
					qname('rr:class')   , olist( $class->types_to_attean_iri($mc->model) )
				],#;
			];#.
		}

		my @value_labels = grep { $_->mapper isa 'Bio_Bricks::KG::Mapping::OKGML::Mapper::ValueLabel' } @$elements;
		for my $value_label_element (@value_labels) {
			die <<~ERROR unless $mc->model->has_class( $value_label_element->mapper->class );
			Missing class:
			  dataset  : @{[ $mc->dataset->name ]}
			  input    : @{[ $mc->input->name ]}
			  element  : @{[ $value_label_element->name ]}
			  class    : @{[ $value_label_element->mapper->class ]}
			ERROR
			my $class = $mc->model->get_class( $value_label_element->mapper->class );
			collect bnode [
				a()                       , qname('rr:TriplesMap') ,#;
				qname('rml:logicalSource'), $logical_source        ,#;
				qname('rr:subjectMap')    , bnode [
					qname('rr:template'), literal( $class->rml_template( $mc->model, $value_label_element ) ),    #;
					qname('rr:class')   , olist( $class->types_to_attean_iri($mc->model) )
				],#;
				qname('rr:predicateObjectMap'), bnode [
					qname('rr:predicate'), $value_label_element->mapper->label_predicate_to_attean_iri($self->rml_context, $mc->model)  ,#;
					qname('rr:objectMap'), bnode [ qname('rml:reference'), literal($value_label_element->columns->[0]) ]      ,#;
				],#
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
				my $mc = MapperContext->new(
					model   => $self->model,
					dataset => $dataset,
					input   => $input,
				);

				$self->generate_rml( $mc, \@elements );
			}
		}

		$context->store;
	},
	isa => ConsumerOf['Attean::API::Store'],
	;

1;
