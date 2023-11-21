package Bio_Bricks::KG::Model::Tabular::Column;
# ABSTRACT: A tabular column

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( Str );
use Types::TypeTiny qw( TypeTiny );

ro name => (
	isa => Str,
);

ro type => (
	isa => TypeTiny,
);

1;
