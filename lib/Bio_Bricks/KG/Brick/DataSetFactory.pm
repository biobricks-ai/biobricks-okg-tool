package Bio_Bricks::KG::Brick::DataSetFactory;
# ABSTRACT: Create data sets from path

use Mu;
use Bio_Bricks::Common::Setup;
use Bio_Bricks::Common::Types qw( AbsDir InstanceOf );

use Bio_Bricks::KG::Brick::DataSet;
use Bio_Bricks::KG::Input::Parquet;

use Path::Iterator::Rule;
use List::Util::groupby qw(hgroupby);

use constant DATA_SOURCE_DIRS => [ qw(data-source data-processed) ];

ro base_dir => (
	isa      => AbsDir,
	coerce   => 1,
);

lazy _parquet_rule => sub {
	my $parquet_rule = Path::Iterator::Rule->new
		# Any file or directory that has .parquet suffix.
		->name( qr/\.parquet$/ )
		# Accept, but if directory, it is accepted and pruned.
		->and( sub { \1 });
};

method _process_rule( (InstanceOf['Path::Iterator::Rule']) $rule ) {
	# Later directories in DATA_SOURCE_DIRS are used to mask directories
	# that come earlier in the list.
	my %files =
		map {
			my $source_top_dir = $_;
			map {
				my $path = path($_);
				(
					$path->relative( $source_top_dir )
					=>
					$path
				)
			} $rule->all( $source_top_dir );
		} (
			map { $self->base_dir->child($_) } @{ DATA_SOURCE_DIRS() }
		);

	return [ values %files ];
}

method create() {
	my @parquet_files = $self->_process_rule( $self->_parquet_rule )->@*;
	my %dataset_to_parquet =
		hgroupby {
			(File::Spec->splitdir(
				$_->input->relative($self->base_dir)
			))[1]
		}
		map {
			Bio_Bricks::KG::Input::Parquet->new( input => $_ )
		}
		@parquet_files;

	return [ map {
		Bio_Bricks::KG::Brick::DataSet->new(
			name   => $_,
			inputs => $dataset_to_parquet{$_}
		);
	} keys %dataset_to_parquet ]
}

1;
