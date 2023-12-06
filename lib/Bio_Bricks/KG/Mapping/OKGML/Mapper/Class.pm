package Bio_Bricks::KG::Mapping::OKGML::Mapper::Class;
# ABSTRACT: A mapper to a class type

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( Str );

ro class => ( isa => Str );

with qw(Bio_Bricks::KG::Mapping::OKGML::Role::Mapper);

1;
