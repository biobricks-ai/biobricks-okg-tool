package Bio_Bricks::Common::Types;
# ABSTRACT: Type library

use Type::Library 0.008 -base,
	-declare => [qw(
		ParquetPath
		DuckDBQuery
		PrefixedQName
		IriOrPrefixedQName
		IriOrPrefixedQNameFromStr
		IriableName
	)];
use Type::Utils -all;

# Listed here so that scan-perl-deps can find them
use Types::Common          qw(
	StrMatch
	CycleTuple
	InstanceOf ConsumerOf
);
use Types::Common::Numeric qw();
use Types::Path::Tiny      qw(Path);
use Types::URI             qw(Iri);
use Types::Attean          qw();

use Type::Libraries;
Type::Libraries->setup_class(
	__PACKAGE__,
	qw(
		Types::Common
		Types::Path::Tiny
		Types::URI
		Types::Attean
	)
);

=head1 TYPE LIBRARIES

=for :list
* L<Types::Common>
* L<Types::Common::Numeric>
* L<Types::Path::Tiny>
* L<Types::URI>
* L<Types::Attean>

=cut

=type ParquetPath

Matches a Parquet path. Can be either a file or directory.

=cut
declare ParquetPath => as Path,
	where { $_ =~ qr/\.parquet$/ };

declare DuckDBQuery => as Str;

=type PrefixedQName

A QName with a prefix part.

=cut
my $PrefixedQName = declare PrefixedQName => as StrMatch[ qr/\A \w+ : \w+ \z/x ];

union IriOrPrefixedQName => [ Iri , $PrefixedQName ];
declare_coercion IriOrPrefixedQNameFromStr => from Str, via {
	$_ =~ m{\Ahttps?://}
	?  IRI->new( $_ )
	: $_
};

declare IriableName => as StrMatch[ qr/\A\w+\z/];

1;
