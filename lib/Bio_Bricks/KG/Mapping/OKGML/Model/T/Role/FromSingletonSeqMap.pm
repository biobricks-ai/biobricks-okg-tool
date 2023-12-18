package Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromSingletonSeqMap;
# ABSTRACT: Data from sequence mapping with a single key

use Mu::Role;
use Bio_Bricks::Common::Setup;
use List::Util qw(pairs);
use Scalar::Util qw(blessed);

requires 'name';

classmethod FROM_COLLECTION( $data ) {
	my @obj;
	for my $item ( @$data  ) {
		my @keys = keys %$item;
		die "Multiple mappings inside of sequence" unless @keys == 1;
		push @obj, $class->new( name => $keys[0], $item->{$keys[0]}->%* );
	}
	return \@obj;
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
	my @obj;
	for my $item ( @$data  ) {
		my @keys = keys %$item;
		push @obj, { $item->name => $item->TO_HASH };
	}
	return \@obj;
}

1;
