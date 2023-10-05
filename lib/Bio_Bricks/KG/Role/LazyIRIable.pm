package Bio_Bricks::KG::Role::LazyIRIable;
# ABSTRACT: Create a lazy URI

use Mu::Role;
use Devel::StrictMode qw(LAX);
use Attean::IRI;

use Bio_Bricks::Common::Setup;

requires 'uri';

method lazy_iri(@args) {
	my $uri = $self->uri(@args);
	return Attean::IRI->new( value => $uri->as_string, lazy => LAX );
}

1;
