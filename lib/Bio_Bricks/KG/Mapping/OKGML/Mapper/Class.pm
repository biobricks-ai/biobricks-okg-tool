package Bio_Bricks::KG::Mapping::OKGML::Mapper::Class;
# ABSTRACT: A mapper to a class type

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( IriableName );

ro class => ( isa => IriableName );

with qw(Bio_Bricks::KG::Mapping::OKGML::Role::Mapper);

1;
