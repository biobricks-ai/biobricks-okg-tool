#!/usr/bin/env perl

use Test2::V0;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::DuckDB;

use LWP::UserAgent;
use LWP::Protocol::https ();

sub _get_test_parquet {
	my $test_parquet_url = 'https://github.com/apache/parquet-testing/raw/master/data/alltypes_plain.parquet';
	my $path = path('alltypes_plain.parquet');

	if( ! -r $path ) {
		my $ua = LWP::UserAgent->new();
		note "Downloading file from $test_parquet_url to $path";
		my $response = $ua->get( $test_parquet_url, ':content_file' => "$path" );
		$response->is_success or die "Unable to download: @{[ $response->message ]}";
	}

	return $path;
}

subtest "Reading in the colums and types from single file" => sub {
	my $path = _get_test_parquet;

	my $db = Bio_Bricks::DuckDB->new;
	my $schema = $db->get_schema_data($path);

	is $schema->iterator->all, array {
		prop size => 12;
		etc();
	}, 'contents of schema';
};

subtest "Reading in the colums and types from multiple files (dataset)" => sub {
	my $single_file_path = _get_test_parquet;
	my $dataset = path('duckdb-basic.parquet');
	$dataset->mkpath;
	my $n = 3;
	$single_file_path->copy( $dataset->child("part-$_.parquet") ) for (0..$n-1);

	my $db = Bio_Bricks::DuckDB->new;
	my $schema = $db->get_schema_data($dataset);

	is $schema->iterator->all, array {
		prop size => 12 * $n;
		etc();
	}, 'contents of schema';
};

done_testing;
