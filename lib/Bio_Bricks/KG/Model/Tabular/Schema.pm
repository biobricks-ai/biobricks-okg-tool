package Bio_Bricks::KG::Model::Tabular::Schema;
# ABSTRACT: Model for tabular data

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	ArrayRef
	InstanceOf
);

ro columns => (
	isa => ArrayRef[InstanceOf['Bio_Bricks::KG::Model::Tabular::Column']],
);

1;
