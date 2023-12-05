package Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromSequence;
# ABSTRACT: Data from a sequence (array)

use Mu::Role;
use Bio_Bricks::Common::Setup;

classmethod FROM_COLLECTION( $data ) {
	my @obj;
	for my $item ( @$data  ) {
		push @obj, $class->new( $item )
	}
	return \@obj;
}

with qw( MooX::SingleArg );

1;
