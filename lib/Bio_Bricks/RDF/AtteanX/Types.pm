package Bio_Bricks::RDF::AtteanX::Types;
# ABSTRACT: Types that extend those from Attean

use Type::Library 0.008 -base,
	-declare => [qw(
		RDFSubject RDFPredicate RDFObject
		RDFTriple
		RDFLiteral
	)];
use Type::Utils -all;

use Types::Common          qw(
	ConsumerOf
);

declare RDFSubject   => as ConsumerOf['Attean::API::BlankOrIRI'];
declare RDFPredicate => as ConsumerOf['Attean::API::IRI'];
declare RDFObject    => as ConsumerOf['Attean::API::Term'];
declare RDFTriple    => as ConsumerOf['Attean::API::Triple'];

declare RDFLiteral   => as ConsumerOf['Attean::API::Literal'];

1;
