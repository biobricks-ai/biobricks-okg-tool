package Bio_Bricks::RDF::DSL::Types;
# ABSTRACT: Types for RDF DSL

use Type::Library 0.008 -base,
	-declare => [qw(
		RDF_DSL_Bnode
		RDF_DSL_ObjList
		RDF_DSL_Object
		RDF_DSL_PredicateObjectPairs
	)];
use Type::Utils -all;

use Types::Common          qw(
	CycleTuple InstanceOf
);
use Bio_Bricks::RDF::AtteanX::Types qw(
	RDFPredicate
	RDFObject
);

my $RDF_DSL_Bnode   =
	declare RDF_DSL_Bnode   => as InstanceOf['BNode'];
my $RDF_DSL_ObjList =
	declare RDF_DSL_ObjList => as InstanceOf['ObjList'];
my $RDF_DSL_Object =
	union   RDF_DSL_Object  => [ RDFObject, $RDF_DSL_Bnode, $RDF_DSL_ObjList ];

declare RDF_DSL_PredicateObjectPairs => as CycleTuple[RDFPredicate,$RDF_DSL_Object];

1;
