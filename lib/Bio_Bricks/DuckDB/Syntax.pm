package Bio_Bricks::DuckDB::Syntax;
# ABSTRACT: Parts of the DuckDB syntax

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	Str
);

=fun _single_quote( (Str) $string) :ReturnType(Str)

Quote escapes a single quote using DuckDB's quoting rules.

=cut
fun _single_quote( (Str) $string) :ReturnType(Str) {
	# Single quotes are escaped by doubling them up.
	$string =~ s/'/''/g;
	qq{'$string'};
}

=fun _double_quote($string) :ReturnType(Str)

Quote escapes a double quote using DuckDB's quoting rules.

=cut
fun _double_quote($string) :ReturnType(Str) {
	# Double quotes are escaped by doubling them up.
	$string =~ s/"/""/g;
	qq{"$string"};
}

=classmethod identifier($identifier) :ReturnType(Str)

Quotes an SQL identifier (e.g., column, table).

C<column_name> and C<table_name> exist to differentiate
particular identifier types.

=cut
classmethod identifier($identifier) :ReturnType(Str) {
	return _double_quote($identifier);
}

classmethod column_name($column_name) { identifier($column_name) }

classmethod table_name($table_name)   { identifier($table_name) }

=classmethod string($str) :ReturnType(Str)

Quotes an SQL string.

=cut
classmethod string($str) :ReturnType(Str) {
	return _single_quote($str);
}

1;
