package Bio_Bricks::KG::App::SQLTemplater;
# ABSTRACT: Outputs a template SQL file to start

use Mu;
use CLI::Osprey;

use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw(
	Path AbsDir
);
use Bio_Bricks::DuckDB;

use Path::Iterator::Rule;

option base_dir => (
	required => 0,
	is       => 'ro',
	format   => 's',
	isa      => AbsDir,
	coerce   => 1,
	doc      => 'Path to base directory for file paths',
	default  => sub { Path::Tiny->cwd },
);

lazy duckdb => sub { Bio_Bricks::DuckDB->new };

method run() {
	my $data_source    = $self->base_dir->child('data-source');
	my $data_processed = $self->base_dir->child('data-processed');

	my $parquet_rule = Path::Iterator::Rule->new->file->name( qr/\.parquet$/ );
	my %parquet_files = map {
		my $path = path($_);
		(
			$path->relative( $self->base_dir->canonpath ) => $path
		)
	} $parquet_rule->all( $data_source );


	for my $rel_path_src (sort keys %parquet_files) {
		my $path = $parquet_files{$rel_path_src};
		my $rel_path_proc = $data_processed->child( $path->relative( $data_source ) )
			->relative( $self->base_dir );
		my $schema_data = $self->duckdb->get_schema_data( $path );
		my @column_names = map { $_->{name} } $schema_data->iterator->all->@*;
		shift @column_names if $column_names[0] =~ /\A(?:schema|duckdb_schema)\z/;
		say <<~SQL
		COPY (
			SELECT
				ROW_NUMBER() OVER () as _ROW_NUMBER,\n@{[
				join ",\n",  map "\t\t$_", map {
					Bio_Bricks::DuckDB::Syntax->column_name($_)
				} @column_names ]}
			FROM @{[ Bio_Bricks::DuckDB::Syntax->table_name( '' . $rel_path_src ) ]}
			-- LIMIT 1000
		)
		TO @{[ Bio_Bricks::DuckDB::Syntax->string( '' . $rel_path_proc ) ]}
		(FORMAT 'parquet')
		;
		SQL
	}
}


1;
