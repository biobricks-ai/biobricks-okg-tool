package Bio_Bricks::KG::Mapping::OKGML::Mapper::ValueLabel;
# ABSTRACT: A mapper to a value via a generated IRI

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( Str );

ro class => ( isa => Str );

with qw(Bio_Bricks::KG::Mapping::OKGML::Role::Mapper);

1;
