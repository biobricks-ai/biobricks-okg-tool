package Bio_Bricks::RDF::DSL::Types;
# ABSTRACT: Types for RDF DSL

use Type::Library 0.008 -base,
	-declare => [qw(
		RDF_DSL_Object
		RDF_DSL_PredicateObjectPairs

		RDF_DSL_Context

		RDF_DSL_Bnode
		RDF_DSL_ObjList
	)];
use Type::Utils -all;

use Types::Common          qw(
	CycleTuple InstanceOf
);
use Bio_Bricks::RDF::AtteanX::Types qw(
	RDFPredicate
	RDFObject
);

# Packages used for tagging of lightweight internal objects
use constant {
	BNode_Tag   => 'BNode',
	ObjList_Tag => 'ObjList'
};

my $RDF_DSL_BNode   =
	declare RDF_DSL_BNode   => as InstanceOf[ BNode_Tag ];
my $RDF_DSL_ObjList =
	declare RDF_DSL_ObjList => as InstanceOf[ ObjList_Tag ];
my $RDF_DSL_Object =
	union   RDF_DSL_Object  => [ RDFObject, $RDF_DSL_BNode, $RDF_DSL_ObjList ];

declare RDF_DSL_PredicateObjectPairs => as CycleTuple[RDFPredicate,$RDF_DSL_Object];


declare RDF_DSL_Context => as InstanceOf['Bio_Bricks::RDF::DSL::Context'];

1;
