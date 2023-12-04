package Bio_Bricks::KG::App::YAML::Processor;
# ABSTRACT: Process a YAML schema

use Mu;
use CLI::Osprey
	desc => 'Process OKG-ML into RML';

use Bio_Bricks::Common::Setup;
use Bio_Bricks::KG::Mapping::OKGML::Model;
use Bio_Bricks::Common::Types qw( AbsFile );

use YAML qw(LoadFile);

with qw(
	Bio_Bricks::KG::App::Role::BaseDirOption
);

option file => (
	required => 1,
	is       => 'ro',
	format   => 's',
	isa      => AbsFile,
	coerce   => 1,
	doc      => 'Path to OKG-ML file',
);

method run() {
	my $data = LoadFile( $self->file );
	my $model = Bio_Bricks::KG::Mapping::OKGML::Model->FROM_HASH(
		$data
	);

	use DDP;p $model;
}

1;
