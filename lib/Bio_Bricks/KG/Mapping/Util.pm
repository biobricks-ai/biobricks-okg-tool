package Bio_Bricks::KG::Mapping::Util;
# ABSTRACT: Utilities for mapping

use strict;
use warnings;

use Exporter::Shiny qw(
	normalize_column_name
	normalize_generic
	normalize_dataset_name
	normalize_table_name
);

use Bio_Bricks::Common::Setup;

use String::CamelCase qw(decamelize);
use URI::Encode qw(uri_encode);

fun normalize_column_name($column_name) {
	# Spaces to underscores
	$column_name =~ s/\s/_/g;

	# Fix use of `FooIDs` to `FooIds` so that it gets decamelize'd
	# properly:
	#
	#   FooIDs -> foo_i_ds
	#   FooIds -> foo_ids
	$column_name =~ s/(?<=[_a-z])IDs(?=\z|[_A-Z])/_Ids/g;

	$column_name = decamelize($column_name);

	$column_name = uri_encode($column_name);

	return $column_name;
}

fun normalize_generic($string) {
	# Spaces to underscores
	$string =~ s/\s/_/g;
	$string = uri_encode($string);
	return $string;
}

fun normalize_table_name($table_name) {
	return normalize_generic($table_name);
}
fun normalize_dataset_name($dataset_name) {
	return normalize_generic($dataset_name);
}

1;
