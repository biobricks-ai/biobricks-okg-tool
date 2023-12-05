package Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromMapping;
# ABSTRACT: Data from a mapping (dict)

use Mu::Role;
use Bio_Bricks::Common::Setup;

use List::Util qw(pairs);

requires 'name';
# isa => Str

classmethod FROM_COLLECTION( $data ) {
	my %obj;
	for my $pair ( pairs %$data ) {
		my ( $key, $value ) = @$pair;
		$obj{$key} = $class->new( name => $key, $value->%* )
	}
	return \%obj;
}

1;
