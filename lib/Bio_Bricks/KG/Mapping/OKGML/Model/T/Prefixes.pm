package Bio_Bricks::KG::Mapping::OKGML::Model::T::Prefixes;
# ABSTRACT: Prefix component of mapping model

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( InstanceOf ConsumerOf );

use Clone qw(clone);
use URI::NamespaceMap;
use List::Util qw(pairmap);

ro ns_map => (
	isa     => InstanceOf['URI::NamespaceMap'] & ConsumerOf['Bio_Bricks::KG::Role::LazyIRIable'],
	default =>
		sub {
			URI::NamespaceMap
				->with::roles(qw(Bio_Bricks::KG::Role::LazyIRIable))
				->new;
		},

);

method is_empty() {
	0 == $self->ns_map->list_prefixes;
}

method to_turtle_prefixes() {
	my $store = Attean->get_store('SimpleTripleStore')->new();
	return Attean->get_serializer( 'Turtle' )
		->new( namespaces => $self->ns_map )
		->serialize_iter_to_bytes( $store->get_triples );
}

classmethod FROM_HASH($data) {
	my $c = clone($data);
	my $self = $class->new;
	for my $ns (keys %$c) {
		$self->ns_map->add_mapping( $ns => delete $c->{$ns}{uri} );
	}
	$self;
}
method TO_HASH() {
	return +{ pairmap {
		$a => { uri => $b->as_string, }
	} $self->ns_map->namespace_map->%* };
}

1;
