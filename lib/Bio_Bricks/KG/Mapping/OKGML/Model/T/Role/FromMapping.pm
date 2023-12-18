package Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromMapping;
# ABSTRACT: Data from a mapping (dict)

use Mu::Role;
use Bio_Bricks::Common::Setup;

use List::Util qw(pairs);
use Scalar::Util qw(blessed);

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

method TO_HASH() {
	my %obj;
	for my $pair ( pairs %$self ) {
		my ( $key, $value ) = @$pair;
		next if $key eq 'name';
		$obj{$key} =
			blessed $value && $value->can('TO_HASH')
				? $value->TO_HASH
				: $value;
	}
	return \%obj;
}

classmethod TO_COLLECTION( $data ) {
	my %obj;
	for my $pair ( pairs %$data ) {
		my ( $key, $value ) = @$pair;
		$obj{$key} = $value->TO_HASH;
	}
	return \%obj;
}

1;
