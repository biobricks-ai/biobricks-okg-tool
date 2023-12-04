package Bio_Bricks::KG::Mapping::OKGML::Model::T::Class;
# ABSTRACT: Class component of mapping model

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( ArrayRef Str StrMatch Iri PrefixedQName );

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
