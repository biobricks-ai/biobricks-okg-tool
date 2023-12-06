package Bio_Bricks::KG::Mapping::OKGML::Model::T::Class;
# ABSTRACT: Class component of mapping model

use namespace::autoclean;
use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( ArrayRef Str StrMatch InstanceOf
	IriOrPrefixedQName
	IriOrPrefixedQNameFromStr
);

use IRI;
use URI::Template;
use URI::Escape qw(uri_unescape);

# classes:
#   Dict[
#     description => Optional[Str],
#     types       =>  ArrayRef[ QName | Uri ],
#     Slurpy,
#
#     # has one of:
#     #  has prefix: concatenate with prefix
#     #  has uri: fill URI template
#     #  neither: generate URI using data elements names
#     prefix      => Optional[Str],
#        ## where 'prefix' value exists in $self->_data_prefixes
#     uri         => Optional[Uri],
#        ## where Uri is actually a URI template
#   ]
ro name => (
	isa => Str,
);

ro description => (
	required => 0,
	isa => Str,
);

ro types => (
	isa    => ArrayRef[ IriOrPrefixedQName->plus_coercions( IriOrPrefixedQNameFromStr ) ],
	coerce => 1,
);

ro prefix => (
	required => 0,
	isa => StrMatch[ qr/\A\w+\z/],
	predicate => 1,
);

ro uri => (
	required  => 0,
	isa       => InstanceOf['URI::Template'],
	coerce    => sub { URI::Template->new( $_[0] ) },
	predicate => 1,
);

method types_to_attean_iri( $model ) {
	map {
		$_ isa IRI
		? Attean::IRI->new( $_->as_string )
		: $model->_data_prefixes->ns_map->lazy_iri( $_ )
	} $self->types->@*
}

method rml_template( $model, $element ) {
	return "TODO" if $element->columns->@* > 1;
	if( $self->has_prefix ) {
		$model->_data_prefixes
			->ns_map->namespace_uri( $self->prefix )
			->iri->as_string . "{@{[ $element->columns->[0] ]}}";
	} elsif( $self->has_uri ) {
		uri_unescape $self->uri->process_to_string(
			value => "{@{[ $element->columns->[0] ]}}",
		);
	}
}

with qw(
	Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromMapping
);

1;
