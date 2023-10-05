package Bio_Bricks::RDF::AtteanX::ToIRI;
# ABSTRACT: A helper for converting to IRI

use Bio_Bricks::Common::Setup;

my $TO_IRI = fun($this, $value = ) {
	if( $this isa Attean::IRI ) {
		return $this;
	} elsif( $this isa IRI or $this isa URI ) {
		return Attean::IRI->new( value => $this->as_string, lazy => LAX );
	} elsif( $this isa URI::Namespace && $value ) {
		return Attean::IRI->new( value => $this->as_string . $value, lazy => LAX );
	}
	die "Unknown invocant: $this";
};

1;
