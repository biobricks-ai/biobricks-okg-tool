package Bio_Bricks::KG::Mapping::OKGML::Model::T::Dataset;
# ABSTRACT: Dataset component of mappping model

use Mu;
use Object::Util magic => 0;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( Str ArrayRef HashRef ConsumerOf );

use constant T_Mapper => 'Bio_Bricks::KG::Mapping::OKGML::Mapper';
use String::RewritePrefix rewrite => {
	-as => 'Mapper',
	prefixes => { '' => T_Mapper.'::', '+' => '' },
};


use MooX::Struct -retain,
	Element => [
		name    =>  [ isa => Str ],
		columns =>  [ isa => ArrayRef[Str, 1] ],
		mapper  =>  [
			isa => ConsumerOf['Bio_Bricks::KG::Mapping::OKGML::Role::Mapper'],
			coerce => sub {
				my $Name = keys $_[0]->%* == 1
					? (keys $_[0]->%*)[0]
					: 'Null';
				return Mapper($Name)->$_new( $_[0]->{$Name} // () );
			},
		],
		-with    => [ qw(Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromSingletonSeqMap) ],
	];
use MooX::Struct -retain,
	Input => [
		name     => [ isa => Str ],
		elements => [
			isa    => ArrayRef[ Element->TYPE_TINY ],
			coerce => sub { Element->FROM_COLLECTION($_[0]) },,
		],
		-with    => [ qw(Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromMapping) ],
	];

# datasets:
#  (dataset name):
#    inputs:
#     (input name):
#       Dict[
#         elements =>
#           Dict[
#             columns => ArrayRef[Str, 1]
#               ## columns in the data source
#             mapper  => Optional[ HashRef ]
#               ## mapper module + arguments
#           ]
#       ]
ro 'name' => ( isa => Str );

ro inputs => (
	required => 0,
	isa      => HashRef[ Input->TYPE_TINY ],
	coerce   => sub { Input->FROM_COLLECTION($_[0]) },
);

with qw(
	Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromMapping
);

1;
