package Bio_Bricks::KG::Mapping::OKGML::Model::T::Dataset;
# ABSTRACT: Dataset component of mappping model

use Mu;

# datasets:
#  (dataset name):
#     (input name):
#       Dict[
#         elements =>
#           Dict[
#             columns => ArrayRef[Str, 1]
#               ## columns in the data source
#             mapper  => Optional[ HashRef ]
#               ## mapper module + arguments
#           ]
#       ]
ro '_data';

1;
