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
);
use Bio_Bricks::RDF::DSL::Types qw(
	RDF_DSL_Object
	RDF_DSL_BNode
	RDF_DSL_PredicateObjectPairs
	RDF_DSL_Context
);
use Bio_Bricks::RDF::DSL::Context;

use namespace::clean;

my $context;

fun rdf($cb) :prototype(&) {
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

=cut
fun qname(@iri_args) :prototype($) {
	_check_context;
	$context->namespaces->lazy_iri(@iri_args)
}

=fun a()

Shortcut for C<rdf:type> just as in Turtle.

=cut
fun a() {
	state $a_iri = Attean::IRI->new( value => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', lazy => 1 );
	return $a_iri;
}

=fun bnode( (RDF_DSL_PredicateObjectPairs) $po )

Creates a blank node for the subject and uses the (predicate, object) pairs
with it.

=cut
fun bnode( (RDF_DSL_PredicateObjectPairs) $po ) :prototype($) {
	my $blank = blank();
	bless { head => $blank, triples => [ turtle_map $blank, $po->@* ] },
		Bio_Bricks::RDF::DSL::Types::BNode_Tag();
}

=fun olist( @objs )

List of objects that can be used in the object slot of a triple.

=cut
fun olist( @objs ) {
	state $type = ArrayRef[RDF_DSL_Object];
	$type->assert_valid(\@objs);
	bless [@objs], Bio_Bricks::RDF::DSL::Types::ObjList_Tag();
}

fun literal( @literal ) {
	Attean::RDF::literal( @literal );
}

1;
