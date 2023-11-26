package Bio_Bricks::KG::App::YAML::Templater;
# ABSTRACT: Create a set of YAML schema templates

use Mu;
use CLI::Osprey;
#use Data::Rmap;
use YAML qw(Dump);

use Bio_Bricks::Common::Setup;

with qw(
	Bio_Bricks::KG::App::Role::BaseDirOption
);

method run() {
	my $data = {
		_meta => {
			name => 'OKG-ML',
			version => '1.0.0',
		},
	};

	for my $key (qw( prefixes classes
		properties datasets)) {
		$data->{$key} = {};
	}


	my $datasets = Bio_Bricks::KG::Brick::DataSetFactory->new( base_dir => $self->base_dir )->create;
	my %dataset_by_name = map { $_->name => $_ } $datasets->@*;

	for my $dataset_name (sort keys %dataset_by_name) {
		my $init = {};
		my %input_by_name = map {
			$_->input->relative( $self->base_dir ) => $_
		} $dataset_by_name{$dataset_name}->inputs->@*;
		for my $input_name (sort keys %input_by_name) {
			my $input = $input_by_name{$input_name};
			$init->{$input_name}{meta} = {};
			my $schema = $input->schema;
			my %columns_by_name = map { $_->name => $_ } $schema->columns->@*;
			for my $column_name (sort keys %columns_by_name) {
				push $init->{$input_name}{elements}->@*, { $column_name => {
					class => undef,
					type  => undef,
				} };
			}
		}
		$data->{datasets}{$dataset_name} = $init;
	}

	say Dump($data);
}

1;
