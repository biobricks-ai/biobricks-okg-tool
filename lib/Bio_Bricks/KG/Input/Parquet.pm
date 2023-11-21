package Bio_Bricks::KG::Input::Parquet;
# ABSTRACT: A Parquet file or dataset

use Mu;
use List::UtilsBy qw(uniq_by);
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( Path Any );
use Bio_Bricks::DuckDB;
use Bio_Bricks::KG::Model::Tabular::Schema;
use Bio_Bricks::KG::Model::Tabular::Column;

ro input => (
	isa => Path,
);

lazy _duckdb => sub { Bio_Bricks::DuckDB->new };

lazy schema => method() {
	my $schema_data = $self->_duckdb->get_schema_data( $self->input );
	my @columns = $schema_data->iterator->all->@*;

	# Need to make unique first because Parquet dataset directories
	# will show columns of all files.
	@columns = uniq_by { $_->{name} } @columns;

	shift @columns if $columns[0]{name} =~ /\A(?:schema|duckdb_schema)\z/;

	return Bio_Bricks::KG::Model::Tabular::Schema->new(
		columns => [
			map {
				Bio_Bricks::KG::Model::Tabular::Column->new(
					name => $_->{name},
					type => Any, # TODO map data types from DuckDB schema
				)
			}
			@columns
		]
	);
};

1;
