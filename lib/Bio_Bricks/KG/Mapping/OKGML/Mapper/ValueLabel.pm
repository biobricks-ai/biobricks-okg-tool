package Bio_Bricks::KG::Mapping::OKGML::Mapper::ValueLabel;
# ABSTRACT: A mapper to a value via a generated IRI

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	Str
	IriOrPrefixedQName
	IriOrPrefixedQNameFromStr
	IriableName
);

ro class => ( isa => IriableName );

ro label_predicate => (
	required => 0,
	isa    => IriOrPrefixedQName->plus_coercions( IriOrPrefixedQNameFromStr ),
	coerce => 1,
	default => sub { 'rdfs:label' },
);

ro label_column => (
	required => 0,
	isa    => Str,
	predicate => 1,
);

method label_predicate_to_attean_iri( $context, $model ) {
	map {
		$_ isa IRI
		? Attean::IRI->new( $_->as_string )
		: $context->namespaces->lazy_iri( $_ )
	} $self->label_predicate;
}

method label_column_for_element( $mc ) {
	die "$mc: Value @{[ $mc->element->name ]} should only have a single column or set label_column"
		if ! $self->has_label_column && $mc->element->columns->@* > 1;
	return $self->has_label_column
		? $self->label_column
		: $mc->element->columns->[0];
}

with qw(Bio_Bricks::KG::Mapping::OKGML::Role::Mapper);

1;
