package Bio_Bricks::KG::Role::LazyIRIable;
# ABSTRACT: Create a lazy URI

use Mu::Role;
use Devel::StrictMode qw(LAX);
use Attean::IRI;
use Data::Dumper qw(Dumper);

use Bio_Bricks::Common::Setup;

use namespace::clean;

requires 'uri';

method lazy_iri(@args) {
	my $uri = $self->uri(@args);
	die "Could not construct IRI for ", Dumper(\@args) unless defined $uri;
	return Attean::IRI->new( value => $uri->as_string, lazy => LAX );
}

1;
