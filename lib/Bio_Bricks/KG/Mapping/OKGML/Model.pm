package Bio_Bricks::KG::Mapping::OKGML::Model;
# ABSTRACT: Mapping model

use strict;
use warnings;

use namespace::autoclean -except => [ 't_components' ];
use Moo;
use MooX::ShortHas;
use Sub::HandlesVia;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( HashRef ArrayRef AbsDir Map Str InstanceOf );
use Clone qw(clone);
use Const::Fast;

use PerlX::Maybe qw(provided_deref);
use Module::Util qw(module_name_parts);

use constant T_NS => 'Bio_Bricks::KG::Mapping::OKGML::Model::T';
use Module::Pluggable search_path => [T_NS], require => 1, sub_name => 't_components';
use String::RewritePrefix rewrite => {
	-as => 'T',
	prefixes => { '' => T_NS.'::', '+' => '' },
};
our @T_COMPONENTS = __PACKAGE__->t_components;

rw _data_prefixes => (
	required => 0,
	default  => method() { T('Prefixes')->new },
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

const my %T_MAPPING => (
	classes  => T('Class'),
	datasets => T('Dataset'),
	values   => T('Value'),
	mappings => T('Mapping'),
);

for my $type (keys %T_MAPPING) {
	my $singular = lc( (module_name_parts($T_MAPPING{$type}))[-1] );
	my $attr_name = "_data_$type";
	has $attr_name => (
		is => 'rw',
		required => 0,
		$T_MAPPING{$type}->does(T('Role::FromMapping'))
		? (
			isa      => Map[ Str , InstanceOf[$T_MAPPING{$type}] ],
			default  => method() { +{} },
			handles_via => 'Hash',
			handles     => {
				"has_${singular}" => 'exists',
				"get_${singular}" => 'get',
			},
		)
		: (
			isa      => ArrayRef[ InstanceOf[$T_MAPPING{$type}] ],
			default  => method() { [] },
			handles_via => 'Array',
			handles     => {
				"get_${type}" =>
					sub() {
						state $type_attr_arg = $T_MAPPING{$type}->single_arg;
						[ map { $_->$type_attr_arg } $_[0]->@* ];
					},
			},
		)
	);
}

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
				$_ => $T_MAPPING{$_}->TO_COLLECTION( $self->$func ),
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

	for my $key (sort keys %T_MAPPING) {
		my $func = "_data_$key";
		$self->$func(
			$T_MAPPING{$key}->FROM_COLLECTION( delete $c->{$key} ),
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
			push $init->{inputs}{$input_name}{elements}->@*, {
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
	$self->_data_datasets->{ $dataset->name } = $T_MAPPING{'datasets'}->new( name => $dataset->name, %$init );
}

1;
