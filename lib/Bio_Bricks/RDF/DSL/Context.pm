package Bio_Bricks::RDF::DSL::Context;
# ABSTRACT: A context object for the DSL

use Mu;
use Attean;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	InstanceOf ConsumerOf
);
use With::Roles;

use aliased 'Bio_Bricks::KG::Role::LazyIRIable' => LazyIRIable;

ro namespaces => (
	isa => InstanceOf['URI::NamespaceMap'] & ConsumerOf[LazyIRIable],
	coerce => sub {
		InstanceOf['URI::NamespaceMap']->assert_valid($_);
		$_->with::roles(LazyIRIable);
		$_;
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
