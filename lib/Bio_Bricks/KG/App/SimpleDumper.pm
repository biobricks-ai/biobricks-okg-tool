package Bio_Bricks::KG::App::SimpleDumper;
# ABSTRACT: Process a tabular dataset and dump a simple RML file

use Mu;
use CLI::Osprey;
use Object::Util magic => 0;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	Path AbsDir
);
use String::CamelCase qw(decamelize);

use Bio_Bricks::DuckDB;
use Bio_Bricks::RDF::DSL;
use Bio_Bricks::RDF::DSL::Types qw(RDF_DSL_Context);

use Attean;
use URI::NamespaceMap;
use Devel::StrictMode qw(LAX);
use Path::Iterator::Rule;
use File::Spec;
use Text::ANSITable;;

has input_file => (
	required => 0,
	is       => 'rw',
	format   => 's',
	isa      => Path,
	coerce   => 1,
	doc      => 'Path to input file',
);

option output_file => (
	required => 1,
	is       => 'rw',
	format   => 's',
	isa      => Path,
	coerce   => 1,
	doc      => 'Path to output file',
);

option base_dir => (
	required => 0,
	is       => 'ro',
	format   => 's',
	isa      => AbsDir,
	coerce   => 1,
	doc      => 'Path to base directory for file paths',
	default  => sub { Path::Tiny->cwd },
);

lazy duckdb => sub { Bio_Bricks::DuckDB->new };

lazy _base_uri => sub { 'http://example.com/base/' };
lazy _base     => method() {
	URI::Namespace
		->with::roles(qw(Bio_Bricks::KG::Role::LazyIRIable))
		->new( $self->_base_uri )
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

	return URI::NamespaceMap->new({
		%base_mapping,

		# Placeholders for now.
		ex => 'http://example.com/',
		'ex-base' => $self->_base_uri,
	})->$_tap( guess_and_add => qw(rdf rdfs xsd) );
};

fun normalize_column_name($column_name) {
	# Spaces to underscores
	$column_name =~ s/\s/_/g;

	# Fix use of `FooIDs` to `FooIds` so that it gets decamelize'd
	# properly:
	#
	#   FooIDs -> foo_i_ds
	#   FooIds -> foo_ids
	$column_name =~ s/(?<=[_a-z])IDs(?=\z|[_A-Z])/_Ids/g;

	return decamelize($column_name);
}

use MooX::Struct TableSpec => [
	qw/$dataset_name! $table_name! @column_names! @primary_keys! $source_file!/
];

method generate_rml( (RDF_DSL_Context) :$context, :$base, :$spec ) :ReturnType(RDF_DSL_Context) {
	my $context = rdf {
		context( $context );

		my $logical_source = $base->lazy_iri('ls_' . $spec->table_name );

		collect turtle_map $logical_source,
			a()                               , qname('rml:LogicalSource')      ,#;
			qname('rml:source')               , literal(''.$spec->source_file ) ,#;
			qname('rml:referenceFormulation') , qname('ql:CSV')                 ;#.


		my $triple_map = $base->lazy_iri('TripleMap_Top');
		collect turtle_map $triple_map,
			a()                   ,  qname('rr:TriplesMap') ,#;
			qname('rr:subjectMap'), bnode [
				qname('rr:template'), literal(
					join q{/},
						"http://example.com",
						$spec->dataset_name,
						$spec->table_name,
						map { normalize_column_name($_), qq({$_}) } $spec->primary_keys->@*
				),#;
				qname('rr:class')   ,  qname('ex:chem-gene-ixn'),#;
			],#;
			( map {
				my $column_name = $_;
				qname('rr:predicateObjectMap'), bnode [
					qname('rr:predicate'), qname('ex:' . normalize_column_name($column_name) )    ,#;
					qname('rr:objectMap'), bnode [ qname('rml:reference'), literal($column_name) ],#;
				]
			} $spec->column_names->@* )
		;#.
	};

	return $context;
}

use Search::Fzf;


my %base_fzf_config = (
	pointer => '>',
	marker => '*',
	algo => 'v2',
);

sub _preview_ddp {
	require 'DDP';
	my $dump = DDP::np(@_, colored => 1);
	# \e[m is the same as \e[0m (reset all modes)
	[ split /\n/, $dump =~ s/\e\[m/\e\[0m/gr ]
}

fun with_preview($cb) {
	return (
		preview => 1,
		previewWithColor => 1,
		previewFunc => $cb,
	)
}

method _preview_column_cb() {
	return sub {
		my ($column_name) = $_[0]->@*;
		try {
			my $results = $self->duckdb->query( <<~SQL );
			SELECT DISTINCT @{[ Bio_Bricks::DuckDB::Syntax->column_name($column_name) ]}
			FROM @{[ Bio_Bricks::DuckDB::Syntax->table_name( '' . $self->input_file) ]}
			WHERE @{[ Bio_Bricks::DuckDB::Syntax->column_name($column_name) ]} IS NOT NULL
			LIMIT 100
			SQL

			my $t = Text::ANSITable->new;
			my $it = $results->iterator;
			$t->columns( [$column_name] );
			$t->add_rows( [ map { [values %$_] } $it->all->@* ] );

			return [ split /\n/, $t->draw ];
		} catch($e) {
			return [ split /\n/, $e ];
		}
	};

}

method user_query_table_spec() {
	my $parquet_rule = Path::Iterator::Rule->new->file->name( qr/\.parquet$/ );
	my %parquet_files = map @$_, map values %$_, {
		map {
			my $source_top_dir = $_;
			map {
				my $path = path($_);
				(
					$path->relative( $source_top_dir )
					=>
					[ $path->relative( $self->base_dir->canonpath ) => $path ]
				)
			} $parquet_rule->all( $source_top_dir );
		} (
			$self->base_dir->child('data-source'),
			$self->base_dir->child('data-processed')
		)
	};
	die "No Parquet files found" unless %parquet_files;
	my $input_files = fzf( [ keys %parquet_files ] , {
		%base_fzf_config,
		prompt => 'Choose a Parquet file> ',
		multi  => 0,
	});

	$self->input_file( path($parquet_files{$input_files->[0]}) );

	my $dataset_name = ( File::Spec->splitdir($input_files->[0]) )[1];

	my $schema_data = $self->duckdb->get_schema_data( $self->input_file );
	my @column_names = map { $_->{name} } $schema_data->iterator->all->@*;
	shift @column_names if $column_names[0] =~ /\A(?:schema|duckdb_schema)\z/;

	my $primary_keys = fzf( \@column_names , {
		%base_fzf_config,
		prompt => 'Choose primary keys> ',
		sort   => 0,
		multi  => 1,
		with_preview( $self->_preview_column_cb ),
	});

	die "Need at least one primary key" unless @$primary_keys;

	my $spec = TableSpec->new(
		dataset_name => $dataset_name,
		primary_keys => $primary_keys,
		table_name   => $self->input_file->basename(qr/\.parquet$/),
		source_file  => $self->input_file->relative($self->base_dir),
		column_names => \@column_names,
	);

}

method run() {
	say STDERR <<~INFO; # TODO logging
	== Processing base directory: @{[ $self->base_dir ]}.
	INFO

	my $spec = $self->user_query_table_spec;

	my $output_fh = $self->output_file->openw_utf8;

	my $map = $self->uri_map;
	my $base = $self->_base;

	my $context = $self->generate_rml(
		context => Bio_Bricks::RDF::DSL::Context->new( namespaces => $map ),
		base    => $base,
		spec    => $spec,
	);

	Attean->get_serializer( 'Turtle' )
		->new( namespaces => $context->namespaces )
		->serialize_iter_to_io( $output_fh, $context->store->get_triples );
}

1;
