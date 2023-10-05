package Bio_Bricks::RDF::DSL::Context;
# ABSTRACT: A context object for the DSL

use Mu;
use Attean;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	InstanceOf ConsumerOf
);
use With::Roles;

use aliased 'Bio_Bricks::KG::Role::LazyIRIable' => 'LazyIRIable';

ro namespaces => (
	isa => InstanceOf['URI::NamespaceMap'] & ConsumerOf[ LazyIRIable ],
	coerce => sub {
		state $uri_ns_map = InstanceOf['URI::NamespaceMap'];
		$uri_ns_map->assert_valid($_[0]);
		$_[0]->with::roles( LazyIRIable );
		$_[0];
	},
	default => sub {
		return URI::NamespaceMap->with::roles( LazyIRIable )->new;
	},
);

ro store => (
	default => sub {
		Attean->get_store('SimpleTripleStore')->new();
	},
);

1;
