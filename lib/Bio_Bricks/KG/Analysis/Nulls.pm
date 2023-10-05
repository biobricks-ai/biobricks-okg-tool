package Bio_Bricks::KG::Analysis::Nulls;
# ABSTRACT: Count of columns containing non-nulls

use Mu;
use Bio_Bricks::Common::Setup;

ro name => default => 'Non-Null Count';

ro description => default => 'Find count of non-null values'

method query() {
# (
#   SELECT 'GeneSymbol' AS columm_name, COUNT(GeneSymbol) AS count FROM 'data/ctdbase/CTD_genes_diseases.parquet' WHERE GeneSymbol IS NOT NULL
# ) UNION (
#   SELECT 'GeneID' AS columm_name, COUNT(GeneID) AS count FROM 'data/ctdbase/CTD_genes_diseases.parquet' WHERE GeneID IS NOT NULL
# )
}

1;
