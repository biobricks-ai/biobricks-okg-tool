package Bio_Bricks::KG::App::YAML::Templater;
# ABSTRACT: Create a set of YAML schema templates

use Mu;
use CLI::Osprey
	desc => 'Create OKG-ML template';
#use Data::Rmap;
use YAML::XS qw(Dump);

use Bio_Bricks::Common::Setup;
use Bio_Bricks::KG::Mapping::OKGML::Model;

with qw(
	Bio_Bricks::KG::App::Role::BaseDirOption
);

method run() {
	my $model = Bio_Bricks::KG::Mapping::OKGML::Model->new;
	my $datasets = Bio_Bricks::KG::Brick::DataSetFactory->new(
		base_dir => $self->base_dir
	)->create;
	my %dataset_by_name = map { $_->name => $_ } $datasets->@*;
	for my $dataset_name (sort keys %dataset_by_name) {
		$model->add_dataset(
			dataset => $dataset_by_name{$dataset_name},
			base_dir => $self->base_dir,
		);
	}
	say Dump($model->TO_HASH);
}

1;
