package Bio_Bricks::RDF::DSL;
# ABSTRACT: A DSL for generating RDF in a Turtle-like syntax

use base "Exporter::Tiny";
our @EXPORT = qw(
	rdf
	context
	qname bnode literal olist
	a
	collect turtle_map
);

use Attean;
use Attean::RDF qw(triple blank);
use Attean::IRI;
use List::Util qw(pairmap);
use curry;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	ArrayRef
);
use Bio_Bricks::RDF::AtteanX::Types qw(
	RDFSubject RDFObject
	RDFTriple
	RDFLiteral
);
use Bio_Bricks::RDF::DSL::Types qw(
	RDF_DSL_Object
	RDF_DSL_BNode RDF_DSL_ObjList
	RDF_DSL_PredicateObjectPairs
	RDF_DSL_Context
);
use Bio_Bricks::RDF::DSL::Context;

use namespace::clean;

my $context;

=fun rdf($cb)

  my $context = rdf {
     context( Bio_Bricks::RDF::DSL::Context->new(
       namespaces => URI::NamespaceMap->new( qw( rdf rdfs xsd ) )
     ) );

     # Rest of DSL here...
  };

=cut
fun rdf($cb) :prototype(&) :ReturnType(RDF_DSL_Context) {
	undef $context;
	$cb->();
	_check_context();
	return $context;
}

fun _check_context() {
	die 'No context set' unless defined $context;
}

fun context( (RDF_DSL_Context) $new_context) :prototype(@) {
	$context = $new_context;
}

=fun collect(@triples)

Collect a list of triples.

=cut
fun collect(@triples) {
	state $type = ArrayRef[RDFTriple|RDF_DSL_BNode];
	$type->assert_valid(\@triples);
	_check_context();

	my $store = $context->store;
	for (@triples) {
		if( $_ isa Bio_Bricks::RDF::DSL::Types::BNode_Tag() ) {
			collect( $_->{triples}->@* );
		} else {
			$store->add_triple($_)
		}
	}
}

fun turtle_map( (RDFSubject) $subject, @predicate_object_pairs ) :ReturnType( list => ArrayRef[RDFTriple] ) {
	state $po_type = RDF_DSL_PredicateObjectPairs;
	$po_type->assert_valid( \@predicate_object_pairs );
	my $subject_curry = $subject->curry::_( \&triple );
	return pairmap {
		my @triples;
		if( RDFObject->check($b) ) {
			@triples = ( $subject_curry->( $a, $b ) );
		} elsif( $b isa Bio_Bricks::RDF::DSL::Types::ObjList_Tag() ) {
			@triples = map { turtle_map $subject, $a, $_ } $b->@*;
		} elsif( $b isa Bio_Bricks::RDF::DSL::Types::BNode_Tag() ) {
			@triples = (
				$subject_curry->($a, $b->{head}),
				$b->{triples}->@*,
			)
		}
		@triples;
	} @predicate_object_pairs;
}


=fun qname(@iri_args)

Create an IRI using a prefix.

  qname('rdfs:Property')

=cut
fun qname(@iri_args) :prototype($) {
	_check_context;
	$context->namespaces->lazy_iri(@iri_args)
}

=fun a()

Shortcut for C<rdf:type> as in Turtle. This can work in any position of a
triple, but for consistency with Turtle, only use this in the predicate
position.

=cut
fun a() :prototype() {
	state $a_iri = Attean::IRI->new( value => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', lazy => 1 );
	return $a_iri;
}

=fun bnode( (RDF_DSL_PredicateObjectPairs) $po )

Creates a blank node for the subject and uses the (predicate, object) pairs
with it.

Code:

  bnode [ a(), qname('foaf:Person') ]

Turtle:

  # The following are equivalent Turtle.

  _:B1 a        foaf:Person .

  _:B1 rdf:type foaf:Person .


=cut
fun bnode( (RDF_DSL_PredicateObjectPairs) $po ) :prototype($) :ReturnType(RDF_DSL_BNode) {
	my $blank = blank();
	bless { head => $blank, triples => [ turtle_map $blank, $po->@* ] },
		Bio_Bricks::RDF::DSL::Types::BNode_Tag();
}

=fun olist( @objs )

List of objects that can be used in the object slot of a triple.

Code:

  qname('ex:Picture.jpg'), a(), olist( qname('foaf:Image'), qname('schema:ImageObject') )

Turtle:

  ex:Picture.jpg rdf:type foaf:Image, schema:ImageObject .


=cut
fun olist( @objs ) :ReturnType(RDF_DSL_ObjList) {
	state $type = ArrayRef[RDF_DSL_Object];
	$type->assert_valid(\@objs);
	bless [@objs], Bio_Bricks::RDF::DSL::Types::ObjList_Tag();
}

fun literal( @literal ) :ReturnType(RDFLiteral) {
	Attean::RDF::literal( @literal );
}

1;
