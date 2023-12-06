package Bio_Bricks::KG::Mapping::OKGML::Model::T::Class;
# ABSTRACT: Class component of mapping model

use namespace::autoclean;
use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( ArrayRef Str StrMatch InstanceOf
	IriOrPrefixedQName
	IriOrPrefixedQNameFromStr
	IriableName
);

use Bio_Bricks::KG::Mapping::Util qw(
	normalize_column_name
	normalize_dataset_name
	normalize_table_name
);

use IRI;
use URI::Template;
use URI::Escape qw(uri_unescape);
use List::Util qw(tail);

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
	isa => IriableName,
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

method rml_template( $mc, $element ) {
	if( $self->has_prefix ) {
		die "prefix: does not work with multiple columns"
			if $element->columns->@* > 1;

		return $mc->model->_data_prefixes
			->ns_map->namespace_uri( $self->prefix )
			->iri->as_string . "{@{[ $element->columns->[0] ]}}";
	} elsif( $self->has_uri ) {
		die "uri: does not work with multiple columns (yet)"
			if $element->columns->@* > 1;

		return uri_unescape $self->uri->process_to_string(
			value => "{@{[ $element->columns->[0] ]}}",
		);
	} else {
		# neither
		return join q{/},
			"http://example.com",
			normalize_dataset_name($mc->dataset->name),
			normalize_table_name(
				join "/", tail -2, split m{/}, $mc->input->name
			),
			map { normalize_column_name($_), qq({$_}) } $element->columns->@*
,#;
	}
}

with qw(
	Bio_Bricks::KG::Mapping::OKGML::Model::T::Role::FromMapping
);

1;
