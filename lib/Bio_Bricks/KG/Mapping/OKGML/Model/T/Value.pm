package Bio_Bricks::KG::Mapping::OKGML::Model::T::Value;
# ABSTRACT: Value component of mapping model

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( StrMatch );

# values:
#   Dict[
#     datatype => Optional[StrMatch[qr/^xsd:(string|integer)$]]
#        ## TODO: add more xsd: types
#   ]
ro datatype => (
	required => 0,
	isa => StrMatch[ qr/\Axsd:(?:string|integer)\z/ ],
);

1;
