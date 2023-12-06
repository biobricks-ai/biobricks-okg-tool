package Bio_Bricks::KG::Mapping::OKGML::Mapper::Value;
# ABSTRACT: A mapper to a value

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( IriableName );

ro value => ( required => 0, isa => IriableName, );

classmethod FROM_HASH($data) {
	...
}

with qw(Bio_Bricks::KG::Mapping::OKGML::Role::Mapper);

1;
