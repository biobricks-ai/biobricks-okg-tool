package Bio_Bricks::KG::App::Role::BaseDirOption;
# ABSTRACT: Provides a base directory option

use Mu::Role;
use CLI::Osprey;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( AbsDir );

option base_dir => (
	required => 0,
	is       => 'ro',
	format   => 's',
	isa      => AbsDir,
	coerce   => 1,
	doc      => 'Path to base directory for file paths',
	default  => sub { Path::Tiny->cwd },
);


1;
