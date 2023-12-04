package Bio_Bricks::KG::Mapping::OKGML::Model::T::Class;
# ABSTRACT: Class component of mapping model

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( ArrayRef Str StrMatch Iri PrefixedQName );

# classes:
#   Dict[
#     description => Optional[Str],
#     types       =>  ArrayRef[ QName | Uri ],
#     Slurpy,
#
#     # has one of:
#     #  has prefix: concatenate with prefix
#     #  has uri: fill URI template
#     #  neither: generate URI using data elements names
#     prefix      => Optional[Str],
#        ## where 'prefix' value exists in $self->_data_prefixes
#     uri         => Optional[Uri],
#        ## where Uri is actually a URI template
#   ]
ro name => (
	isa => Str,
);

ro description => (
	required => 0,
	isa => Str,
);

ro types => (
	isa => ArrayRef[ Iri | PrefixedQName ],
);

ro prefix => (
	required => 0,
	isa => StrMatch[ qr/\A\w+\z/],
	predicate => 1,
);

ro uri => (
	required => 0,
	isa => Iri,
	predicate => 1,
);

1;
