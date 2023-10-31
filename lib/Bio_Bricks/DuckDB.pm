package Bio_Bricks::DuckDB;
# ABSTRACT: 

use Mu;

use Capture::Tiny qw(capture);
use Text::CSV;
use IO::String;
use Data::TableReader;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	Str InstanceOf
	Path
	ParquetPath
	DuckDBQuery
);
use aliased 'Bio_Bricks::DuckDB::Syntax' => 'Syntax';

use namespace::clean;

ro duckdb_cli_path => default => 'duckdb';

=method _run_query_csv( (DuckDBQuery) $query) :ReturnType(Str)

Runs the SQL query C<$query> and returns the CSV data as string.

=cut
method _run_query_csv( (DuckDBQuery) $query) :ReturnType(Str) {
	my ($stdout, $stderr, $exit) = capture {
		system( $self->duckdb_cli_path, '-csv', '-c', $query );
	};

	if( $exit ) {
		die "Error with query $query: $stderr";
	}

	return $stdout;
}

=method query( (DuckDBQuery) $query) :ReturnType(InstanceOf['Data::TableReader'])

Returns a L<Data::TableReader> over the data returned by C<$query>.

=cut
method query( (DuckDBQuery) $query) :ReturnType(InstanceOf['Data::TableReader']) {
	my $csv_data = $self->_run_query_csv($query);

	my $csv_handle = IO::String->new($csv_data);

	# Extract headers
	my $csv_parser = Text::CSV->new({ binary => 1, auto_diag => 1 });
	my $header_names = $csv_parser->getline($csv_handle);

	# Start at beginning again
	$csv_handle->setpos(0);
	my $reader = Data::TableReader->new(
		input => IO::String->new($csv_data),
		decoder => [ 'CSV' , strict => 1 ],
		header_row_at => 1,
		fields  => [ map { name => $_, trim =>  0 }, @$header_names ],
	);

	return $reader;
}

=method _duckdb_parquet_path_to_FROM($data_path) :ReturnType(Str)

Use SQL FROM that handles Parquet data sets (single file versus directory of files).

=cut
method _duckdb_parquet_path_to_FROM( (ParquetPath) $data_path) :ReturnType(Str) {
	return Syntax->string(
		-f $data_path
		?  "$data_path"
		: "$data_path/*.parquet"
	);
}

method get_schema_data( (Path->coercibles) $data_path )
		:ReturnType(InstanceOf['Data::TableReader']) {
	$data_path = Path->coerce($data_path);
	if( ParquetPath->check($data_path) ) {
		return $self->query(
			sprintf( <<~'SQL',
					SELECT *
					FROM parquet_schema(%s) ;
				SQL
				$self->_duckdb_parquet_path_to_FROM($data_path)
			)
		);
	} else {
		die "Unkown file type for $data_path";
	}
}

1;
