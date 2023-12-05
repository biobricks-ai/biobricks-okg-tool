package Bio_Bricks::KG::Mapping::OKGML::Model::T::Mapping;
# ABSTRACT: Mapping component of mapping model

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( Str );

ro mapping => (
	isa => Str,
);

with qw(
	Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromSequence
);

__PACKAGE__->single_arg( 'mapping' );

1;
