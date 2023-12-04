package Bio_Bricks::KG::Mapping::OKGML::Model::T::Mapping;
# ABSTRACT: Mapping component of mapping model

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( ArrayRef Str );

ro _mappings => (
	isa => ArrayRef[Str],
);

1;
