package Bio_Bricks::KG::Mapping::OKGML::Model;
# ABSTRACT: Mapping model

use strict;
use warnings;

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( HashRef AbsDir );
use Clone qw(clone);

use Sub::HandlesVia;
use List::Util qw(pairmap);
use PerlX::Maybe qw(provided_deref);
use URI::NamespaceMap;

use MooX::Press (
	class => [
		Prefixes => [
			has => [
				ns_map => {
					default => sub { URI::NamespaceMap->new; },
				}
			],
			can => {
				is_empty  => method() {
					0 == $self->ns_map->list_prefixes;
				},
				FROM_HASH => classmethod($data) {
					my $c = clone($data);
					my $self = $class->new;
					for my $ns (keys %$c) {
						$self->ns_map->add_mapping( $ns => delete $c->{$ns}{uri} );
					}
					$self;
				},
				TO_HASH => method() {
					return +{ pairmap {
						$a => { uri => $b->as_string, }
					} $self->ns_map->namespace_map->%* };
				}
			},
		]
	],
);

rw _data_prefixes => (
	required => 0,
	default  => method() { $self->new_prefixes },
);

rw _data_meta => (
	required => 0,
	isa => HashRef,
	default => sub {
		return +{
			name => 'OKG-ML',
			version => '1.0.0',
		}
	},
);

rw [ qw(
	_data_datasets
	_data_classes
	_data_values
) ] => (
	required => 0,
	isa      => HashRef,
	default  => method() { +{} },
);

# datasets:
#  (dataset name):
#     (input name):
#       Dict[
#         elements =>
#           Dict[
#             columns => ArrayRef[Str, 1]
#               ## columns in the data source
#             mapper  => Optional[ HashRef ]
#               ## mapper module + arguments
#           ]
#       ]
#
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
#
# values:
#   Dict[
#     datatype => Optional[StrMatch[qr/^xsd:(string|integer)$]]
#        ## TODO: add more xsd: types
#   ]

rw [ qw(
	_data_mappings
) ] => (
	required => 0,
	isa      => ArrayRef,
	default  => method() { [] },
);

method TO_HASH() {
	return +{
				_meta => $self->_data_meta,
		provided_deref ! $self->_data_prefixes->is_empty,
			sub {
				prefixes => $self->_data_prefixes->TO_HASH
			},

		map {
		my $func = "_data_$_";
		provided_deref keys $self->$func->%*,
			sub {
				$_ => $self->$func,
			},
		} qw( datasets classes values ),

		map {
		my $func = "_data_$_";
		provided_deref scalar $self->$func->@*,
			sub {
				$_ => $self->$func,
			},
		} qw( mappings ),

	};
}

classmethod FROM_HASH($data) {
	my $c = clone($data);

	my $self = $class->new;

	# TODO check if meta version matches expected
	$self->_data_meta( delete $c->{meta} ) if exists $c->{meta};

	$self->_data_prefixes(
		T('Prefixes')->FROM_HASH(
			delete $c->{prefixes}
		)
	);

	for my $key (qw(datasets classes values)) {
		my $func = "_data_$key";
		$self->$func(
			delete $c->{$key},
		) if exists $c->{$key};
	}

	$self;
}

method add_dataset( :$dataset, :$base_dir ) {
	$base_dir = AbsDir->coerce($base_dir);

	my $init = {};

	my %input_by_name = map {
		$_->input->relative( $base_dir ) => $_
	} $dataset->inputs->@*;

	for my $input_name (sort keys %input_by_name) {
		my $input = $input_by_name{$input_name};
		my $schema = $input->schema;
		my %columns_by_name = map { $_->name => $_ } $schema->columns->@*;
		for my $column ($schema->columns->@*) {
			push $init->{$input_name}{elements}->@*, {
				$column->name => {
					columns => [ $column->name ],
					mapper  => {
					},
					_mapper_alts => {
						Value      => { value => undef },
						Class      => { class => undef },
						ValueLabel => { class => undef },
					},
				}
			};
		}
	}
	$self->_data_datasets->{ $dataset->name } = $init;
}

1;
