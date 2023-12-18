package Bio_Bricks::KG::Mapping::OKGML::Role::Mapper;
# ABSTRACT: Role for mappers

use Mu::Role;
use Bio_Bricks::Common::Setup;

method TO_HASH() {
	return +{ %$self };
}

1;
