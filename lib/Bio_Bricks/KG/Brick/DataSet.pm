package Bio_Bricks::KG::Brick::DataSet;
# ABSTRACT: A brick dataset

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( Str ArrayRef );;

ro name => (
	isa => Str,
);

ro inputs => (
	isa => ArrayRef, # of Inputs
);

1;
