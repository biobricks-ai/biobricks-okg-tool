package Bio_Bricks::KG::App::SimpleDumper;
# ABSTRACT: Process a tabular dataset and dump a simple RML file

use Mu;
use CLI::Osprey;
use Object::Util magic => 0;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	Path AbsDir
	ArrayRef
	CycleTuple
	InstanceOf

);
use Bio_Bricks::RDF::AtteanX::Types qw(
	RDFSubject RDFPredicate RDFObject
	RDFTriple
);
use Bio_Bricks::RDF::DSL::Types qw(
	RDF_DSL_Object
	RDF_DSL_PredicateObjectPairs
);
use String::CamelCase qw(decamelize);

use Bio_Bricks::DuckDB;

use Attean;
use Attean::RDF qw(iri literal triple blank);
use URI::NamespaceMap;
use With::Roles;
use curry;
use List::Util qw(pairmap);
use Devel::StrictMode qw(LAX);

option input_file => (
	required => 1,
	is       => 'ro',
	format   => 's',
	isa      => Path,
	coerce   => 1,
	doc      => 'Path to input file',
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

	return URI::NamespaceMap->with::roles(
		qw(Bio_Bricks::KG::Role::LazyIRIable)
	)->new({
		%base_mapping,

		# Placeholders for now.
		ex => 'http://example.com/',
		'ex-base' => $self->_base_uri,
	})->$_tap( guess_and_add => qw(rdf rdfs xsd) );
};

fun turtle_map( (RDFSubject) $subject, @predicate_object_pairs ) :ReturnType( list => ArrayRef[RDFTriple] ) {
	state $po_type = RDF_DSL_PredicateObjectPairs;
	$po_type->assert_valid( \@predicate_object_pairs );
	my $subject_curry = $subject->curry::_( \&triple );
	return pairmap {
		my @triples;
		if( RDFObject->check($b) ) {
			@triples = ( $subject_curry->( $a, $b ) );
		} elsif( $b isa ObjList ) {
			@triples = map { turtle_map $subject, $a, $_ } $b->@*;
		} elsif( $b isa BNode ) {
			@triples = (
				$subject_curry->($a, $b->{head}),
				$b->{triples}->@*,
			)
		}
		@triples;
	} @predicate_object_pairs;
}


method run() {
	say STDERR <<~INFO; # TODO logging
	== Processing input file: @{[ $self->input_file ]}.

	== Processing base directory: @{[ $self->base_dir ]}.
	INFO

	my $schema_data = $self->duckdb->get_schema_data( $self->input_file );
	my @column_names = map { $_->{name} } $schema_data->iterator->all->@*;
	shift @column_names if $column_names[0] eq 'schema';

	my $store = Attean->get_store('SimpleTripleStore')->new();

	my $output_fh = \*STDOUT;

	my $map = $self->uri_map;
	my $base = $self->_base;

	my sub qname :prototype($) { $map->lazy_iri(@_) }
	fun bnode( (RDF_DSL_PredicateObjectPairs) $po ) :prototype($) {
		my $blank = blank();
		bless { head => $blank, triples => [ turtle_map $blank, $po->@* ] }, 'BNode';
	}
	fun olist( @objs ) {
		state $type = ArrayRef[RDF_DSL_Object];
		$type->assert_valid(\@objs);
		bless [@objs], 'ObjList'
	}
	my @triples;
	my $table_name = $self->input_file->basename(qr/\.parquet$/);
	my $logical_source = $base->lazy_iri('ls_' . $table_name ); 
	push @triples,
		turtle_map $logical_source,
			qname('rdf:type')                 , qname('rml:LogicalSource')                                  ,#;
			qname('rml:source')               , literal( ''. $self->input_file->relative($self->base_dir) ) ,#;
			qname('rml:referenceFormulation') , qname('ql:CSV')                                             ;#.


	my $dataset_name = 'ctdbase';
	my @primary_keys = ( 'ChemicalID', 'GeneID');

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

	my $triple_map = $base->lazy_iri('TripleMap_Top');
	push @triples,
		turtle_map $triple_map,
			qname('rdf:type'),  qname('rr:TriplesMap') ,#;
			qname('rr:subjectMap'), bnode [
				qname('rr:template'), literal(
					join q{/},
						"http://example.com",
						$dataset_name,
						$table_name,
						map { normalize_column_name($_), qq<{$_}> } @primary_keys
				),
				qname('rr:class')   ,  qname('ex:chem-gene-ixn'),
			],
			( map {
				my $column_name = $_;
				qname('rr:predicateObjectMap'), bnode [
					qname('rr:predicate'), qname('ex:' . normalize_column_name($column_name) ), #;
					qname('rr:objectMap'), bnode [ qname('rml:reference'), literal($column_name) ],
				]
			} @column_names ) ,#;
		;#.

	$store->add_triple($_) for @triples;


	Attean->get_serializer( 'Turtle' )
		->new( namespaces => $map )
		->serialize_iter_to_io( $output_fh, $store->get_triples );
}

1;
