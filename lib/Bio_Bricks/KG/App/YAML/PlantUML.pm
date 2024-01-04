package Bio_Bricks::KG::App::YAML::PlantUML;
# ABSTRACT: Process RDF mapping to PlantUML

use lib::projectroot qw(lib);

use Mu;
use CLI::Osprey
	desc => 'Process RDF mapping to PlantUML';

use Bio_Bricks::Common::Setup;
use Bio_Bricks::KG::Mapping::OKGML::Model;
use Bio_Bricks::KG::Mapping::OKGML::Processor::RML;
use Bio_Bricks::Common::Types qw( Path AbsFile );

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

option output_dir => (
	required => 1,
	is       => 'ro',
	format   => 's',
	isa      => Path,
	coerce   => 1,
	doc      => 'Path to output directory',
);

lazy _rdf_mapping_graph => method() {
	my $graph  = Attean::IRI->new('http://example.org/graph');
};

method _mapping_labels( $ns_map, $model ) {
	defined $ns_map->namespace_uri('skos') or die 'Missing skos prefix';
	my $sparql = <<~SPARQL;
	PREFIX skos: <@{[ $ns_map->namespace_uri('skos')->string ]}>

	SELECT ?iri ?label WHERE {
		?iri <http://www.w3.org/2004/02/skos/core#prefLabel> ?label
	}
	SPARQL
	my $s = Attean->get_parser('SPARQL')->new();
	my ($algebra) = $s->parse($sparql);
	my $results = $model->evaluate($algebra, $self->_rdf_mapping_graph);
	return $results;
}

method run() {
	my $data = LoadFile( $self->file );
	my $okg_model = Bio_Bricks::KG::Mapping::OKGML::Model->FROM_HASH(
		$data
	);

	my $output_dir = $self->output_dir;
	$output_dir->mkdir;

	my $rdfpuml = path($lib::projectroot::ROOT, 'vendor/rdf2rml/bin/rdfpuml.pl' );

	my $tmpdir = Path::Tiny->tempdir;
	my @mappings = $okg_model->get_mappings->@*;
	for my $mapping_idx (0..@mappings-1) {
		my $mapping = $mappings[$mapping_idx];

		my $store  = Attean->get_store('Memory')->new();
		my $model = Attean::QuadModel->new( store => $store );
		my $parser = Attean->get_parser('Turtle')->new();

		my $turtle_buffer = join "\n",
				$okg_model->_data_prefixes->to_turtle_prefixes,
				$mapping;
		my $iter = $parser->parse_iter_from_bytes( $turtle_buffer );
		my $quads = $iter->as_quads($self->_rdf_mapping_graph);

		$store->add_iter($quads);

		my $output_fh = \*STDOUT;
		my $namespaces = $okg_model->_data_prefixes->ns_map;
		$namespaces->add_mapping( '', Attean::IRI->new('http://base/') );
		my $turtle = Attean->get_serializer( 'Turtle' )
			->new( namespaces => $namespaces )
			->serialize_iter_to_bytes( $store->get_quads );

		my $ttl_file = $tmpdir->child("mapping_${mapping_idx}.ttl");
		my $puml_file = $tmpdir->child("mapping_${mapping_idx}.puml");
		$ttl_file->spew_utf8( $turtle );

		0 == system( $^X, $rdfpuml, $ttl_file ) or die "Could not run rdfpuml";

		die "Empty PlantUML" unless -s $puml_file;

		my $plantuml = $puml_file->slurp_utf8;

		my $ns_map = $okg_model->_data_prefixes->ns_map;
		my $labels_iter = $self->_mapping_labels( $ns_map, $model );

		while (my $r = $labels_iter->next) {
			my $iri_abbr = $ns_map->abbreviate( $r->value('iri') );
			my $label = $r->value('label')->value;

			$plantuml =~ s/(\Q$iri_abbr\E$)/$1\\n($label)/gm;
			$plantuml =~ s/(\Q{field}\E\s+\b\Q$iri_abbr\E\b.*$)/$1 # ($label)/gm;
		}

		$output_dir->child($puml_file->basename)->spew_utf8($plantuml);
	}
}


1;
