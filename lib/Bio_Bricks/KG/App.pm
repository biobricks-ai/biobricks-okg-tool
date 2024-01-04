package Bio_Bricks::KG::App;
# ABSTRACT: App for working with knowledge graphs

use strict;
use warnings;

our $VERSION = 'v0.1.0';

use Mu;
use CLI::Osprey;

use Bio_Bricks::Common::Setup;

with qw(
	Bio_Bricks::KG::App::Role::BaseDirOption
);

option version => (
	is => 'ro',
	default => 0,
	doc => 'Show version information',
);

subcommand 'yaml' => 'Bio_Bricks::KG::App::YAML';

use Search::Fzf;
my %base_fzf_config = (
	pointer => '>',
	marker => '*',
	algo => 'v2',
);

method show_version() {
	print "biobricks-okg-tool $VERSION\n";
	exit 0;
}

method run() {
	$self->show_version if $self->version;

	use Bio_Bricks::KG::Brick::DataSetFactory;
	my $datasets = Bio_Bricks::KG::Brick::DataSetFactory->new( base_dir => $self->base_dir )->create;
	my %dataset_by_name = map { $_->name => $_ } $datasets->@*;

	my $dataset_name = fzf( [ sort keys %dataset_by_name ] , {
		%base_fzf_config,
		prompt => 'Choose a dataset > ',
		multi  => 0,
	});

	die "Did not select dataset" unless @$dataset_name;

	my %input_by_name = map {
		$_->input->relative( $self->base_dir ) => $_
	} $dataset_by_name{$dataset_name->[0]}->inputs->@*;

	my $input_name = fzf( [ sort keys %input_by_name ] , {
		%base_fzf_config,
		prompt => 'Choose an input > ',
		multi  => 0,
	});

	die "Did not select input" unless @$input_name;


	my $input = $input_by_name{$input_name->[0]};
	my $schema = $input->schema;
	my %columns_by_name = map { $_->name => $_ } $schema->columns->@*;
	my $primary_keys = fzf( [ keys %columns_by_name ] , {
		%base_fzf_config,
		prompt => 'Choose primary keys > ',
		sort   => 0,
		multi  => 1,
	});

	say '';
	say join "\n", @$primary_keys;
}

1;
