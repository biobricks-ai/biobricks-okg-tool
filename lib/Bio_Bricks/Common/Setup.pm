package Bio_Bricks::Common::Setup;
# ABSTRACT: Common imports

use strict;
use warnings;
use autodie;

use Import::Into;

use feature qw(say postderef);
use Devel::StrictMode;
use Function::Parameters ();
use Return::Type::Lexical ();
use MooX::TypeTiny ();
use With::Roles ();

use Feature::Compat::Try ();

use Path::Tiny ();
use Attean     ();

use Bio_Bricks::Common::URI::Namespace::Fix ();
use Bio_Bricks::Common::Types ();

sub import {
	my ($class) = @_;

	my $target = caller;

	strict->import::into( $target );
	warnings->import::into( $target );
	if( $^V > v5.34.0 ) {
		warnings->unimport::out_of( $target, qw( experimental::try ) );
	}

	autodie->import::into( $target );

	feature->import::into( $target,
		qw(say state postderef),
		qw(isa)x!!( $^V > v5.32.0 ),
	);
	Feature::Compat::Try->import::into( $target );

	Devel::StrictMode->import::into( $target );

	With::Roles->import::into( $target );

	my %type_tiny_fp_check = ( reify_type => sub { Type::Utils::dwim_type($_[0]) }, );
	Function::Parameters->import::into( $target,
		{
			fun         => { defaults => 'function_lax'   , %type_tiny_fp_check },
			classmethod => { defaults => 'classmethod_lax', %type_tiny_fp_check },
			method      => { defaults => 'method_lax'     , %type_tiny_fp_check },
		}
	);
	Return::Type::Lexical->import::into( $target, check => STRICT );

	Path::Tiny->import::into( $target );

	return;
}

1;
