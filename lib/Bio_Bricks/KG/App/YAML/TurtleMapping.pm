package Bio_Bricks::KG::App::YAML::TurtleMapping;
# ABSTRACT: Process RDF mapping in file

use Mu;
use CLI::Osprey
	desc => 'Process RDF mapping in file';

use Bio_Bricks::Common::Setup;
use Bio_Bricks::KG::Mapping::OKGML::Model;
use Bio_Bricks::KG::Mapping::OKGML::Processor::RML;
use Bio_Bricks::Common::Types qw( AbsFile );

use YAML::XS qw(LoadFile Dump);

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
	my $okg_model = Bio_Bricks::KG::Mapping::OKGML::Model->FROM_HASH(
		$data
	);

	my @turtles;
	for my $mapping ($okg_model->get_mappings->@*) {
		my $store  = Attean->get_store('Memory')->new();
		my $model = Attean::QuadModel->new( store => $store );
		my $parser = Attean->get_parser('Turtle')->new();

		my $turtle_buffer = join "\n",
				$okg_model->_data_prefixes->to_turtle_prefixes,
				$mapping;
		my $iter = $parser->parse_iter_from_bytes( $turtle_buffer );
		my $quads = $iter->as_quads(Attean::IRI->new('http://example.com/graph'));

		$store->add_iter($quads);

		my $output_fh = \*STDOUT;
		my $namespaces = $okg_model->_data_prefixes->ns_map;
		$namespaces->add_mapping( '', Attean::IRI->new('http://base/') );
		my $turtle = Attean->get_serializer( 'Turtle' )
			->new( namespaces => $namespaces )
			->serialize_iter_to_bytes( $store->get_quads );

		push @turtles, $turtle;
	}

	print Dump(\@turtles);
}


1;
