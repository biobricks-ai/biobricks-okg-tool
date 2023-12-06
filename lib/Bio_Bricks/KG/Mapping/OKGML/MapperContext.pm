package Bio_Bricks::KG::Mapping::OKGML::MapperContext;
# ABSTRACT: A context to pass into a mapper for processing

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( InstanceOf );

ro 'model' => ( isa => InstanceOf['Bio_Bricks::KG::Mapping::OKGML::Model'] );

ro 'dataset' => ( isa => InstanceOf['Bio_Bricks::KG::Mapping::OKGML::Model::T::Dataset'] );

ro 'input' => ( isa => Bio_Bricks::KG::Mapping::OKGML::Model::T::Dataset::Input->TYPE_TINY );

1;
