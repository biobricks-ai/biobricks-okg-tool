package Bio_Bricks::KG::App::YAML;
# ABSTRACT: YAML subcommand

use Mu;
use CLI::Osprey;

subcommand 'process' => 'Bio_Bricks::KG::App::YAML::Processor';
subcommand 'template' => 'Bio_Bricks::KG::App::YAML::Templater';
subcommand 'turtle-mapping' => 'Bio_Bricks::KG::App::YAML::TurtleMapping';

1;
