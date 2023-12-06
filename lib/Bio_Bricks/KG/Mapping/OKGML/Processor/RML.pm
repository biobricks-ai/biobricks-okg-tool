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

method generate_rml($dataset, $input, $elements) {
	rdf {
		context( $self->rml_context );

		my $logical_source = iri(join '_',
			'ls',
			$dataset->name,
			$input->name =~ s,/,_,gr
		);

		collect turtle_map $logical_source,
			a()                               , qname('rml:LogicalSource')      ,#;
			qname('rml:source')               , literal($input->name )          ,#;
			qname('rml:referenceFormulation') , qname('ql:CSV')                 ;#.


		my @classes = grep { $_->mapper isa 'Bio_Bricks::KG::Mapping::OKGML::Mapper::Class' } @$elements;
		for my $class_element (@classes) {
			die <<~ERROR unless $self->model->has_class( $class_element->mapper->class );
			Missing class:
			  dataset  : @{[ $dataset->name ]}
			  input    : @{[ $input->name ]}
			  element  : @{[ $class_element->name ]}
			  class    : @{[ $class_element->mapper->class ]}
			ERROR
			my $class = $self->model->get_class( $class_element->mapper->class );
			collect bnode [
				a()                       , qname('rr:TriplesMap') ,#;
				qname('rml:logicalSource'), $logical_source        ,#;
				qname('rr:subjectMap')    , bnode [
					qname('rr:template'), literal( $class->rml_template( $self->model, $class_element ) ),    #;
					qname('rr:class')   , olist( $class->types_to_attean_iri($self->model) )
				],#;
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
				$self->generate_rml( $dataset, $input, \@elements );
			}
		}

		$context->store;
	},
	isa => ConsumerOf['Attean::API::Store'],
	;

1;
