package Bio_Bricks::KG::App::SPARQL;
# ABSTRACT: Command for SPARQL related tasks

use Mu;
use CLI::Osprey;

subcommand 'fuseki' => 'Bio_Bricks::KG::App::SPARQL::Fuseki'

1;
