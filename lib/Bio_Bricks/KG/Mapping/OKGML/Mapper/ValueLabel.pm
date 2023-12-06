package Bio_Bricks::KG::Mapping::OKGML::Mapper::ValueLabel;
# ABSTRACT: A mapper to a value via a generated IRI

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( Str
	IriOrPrefixedQName
	IriOrPrefixedQNameFromStr
);

ro class => ( isa => Str );

ro label_predicate => (
	required => 0,
	isa    => IriOrPrefixedQName->plus_coercions( IriOrPrefixedQNameFromStr ),
	coerce => 1,
	default => sub { 'rdfs:label' },
);


method label_predicate_to_attean_iri( $context, $model ) {
	map {
		$_ isa IRI
		? Attean::IRI->new( $_->as_string )
		: $context->namespaces->lazy_iri( $_ )
	} $self->label_predicate;
}

with qw(Bio_Bricks::KG::Mapping::OKGML::Role::Mapper);

1;
