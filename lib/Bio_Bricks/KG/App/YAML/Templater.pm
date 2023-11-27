package Bio_Bricks::KG::App::YAML::Templater;
# ABSTRACT: Create a set of YAML schema templates

use Mu;
use CLI::Osprey
	desc => 'Create OKG-ML template';
#use Data::Rmap;
use YAML qw(Dump);

use Bio_Bricks::Common::Setup;
use Bio_Bricks::KG::Mapping::OKGML::Model;

with qw(
	Bio_Bricks::KG::App::Role::BaseDirOption
);

method run() {
	my $model = Bio_Bricks::KG::Mapping::OKGML::Model->new(
		base_dir => $self->base_dir
	);
	say Dump($model->_data);
}

1;
