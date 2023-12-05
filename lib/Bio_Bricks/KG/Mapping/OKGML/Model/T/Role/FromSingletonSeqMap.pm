package Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromSingletonSeqMap;
# ABSTRACT: Data from sequence mapping with a single key

use Mu::Role;
use Bio_Bricks::Common::Setup;

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

1;
