package Bio_Bricks::KG::App::YAML::Processor;
# ABSTRACT: Process a YAML schema

use Mu;
use CLI::Osprey
	desc => 'Process OKG-ML into RML';

use Bio_Bricks::Common::Setup;
use Bio_Bricks::KG::Mapping::OKGML::Model;
use Bio_Bricks::KG::Mapping::OKGML::Processor::RML;
use Bio_Bricks::Common::Types qw( AbsFile );

use YAML::XS qw(LoadFile);

with qw(
	Bio_Bricks::KG::App::Role::BaseDirOption
);

option file => (
	required => 1,
	is       => 'ro',
	format   => 's',
	isa      => AbsFile,
	coerce   => 1,
	doc      => 'Path to OKG-ML file',
);

method run() {
	my $data = LoadFile( $self->file );
	my $model = Bio_Bricks::KG::Mapping::OKGML::Model->FROM_HASH(
		$data
	);
	my $rml = Bio_Bricks::KG::Mapping::OKGML::Processor::RML->new(
		model => $model,
	);

	my $output_fh = \*STDOUT;
	my $namespaces = $rml->rml_context->namespaces;
	$namespaces->add_mapping( '', Attean::IRI->new('http://base/') );
	Attean->get_serializer( 'Turtle' )
		->new( namespaces => $namespaces )
		->serialize_iter_to_io( $output_fh, $rml->triple_store->get_triples );
}

1;
