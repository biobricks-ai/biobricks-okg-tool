#!/usr/bin/env perl

use Test2::V0;

use lib 't/lib';

use Bio_Bricks::Common::Setup;
use Bio_Bricks::KG::Mapping::OKGML::Model;
use YAML::XS qw(Load);
use Data::Section -setup;

fun load_model_from_data($name) {
	my $yaml = __PACKAGE__->section_data($name)->$*;
	my $data = Load($yaml);
	return Bio_Bricks::KG::Mapping::OKGML::Model
		->FROM_HASH($data);
}

subtest "Loading model" => sub {
	my $Model_only_meta = object {
		call TO_HASH => hash {
			field _meta => hash {
				field name => 'OKG-ML';
				etc;
			};
			end();
		};
	};

	is load_model_from_data('empty'), $Model_only_meta, 'empty';

	is load_model_from_data('basic'), $Model_only_meta, 'basic';

	is load_model_from_data('prefix'),
		object {
			call TO_HASH => hash {
				field 'prefixes' => hash {
					field 'CAS' => hash {
						field uri => 'http://identifiers.org/cas/';
						end;
					};
					end;
				};
				etc;
			};
		},
		'prefix';

	is load_model_from_data('class'),
		object {
			call TO_HASH => hash {
				field 'prefixes' => hash {
					field 'CAS'     => D();
					field 'CHEMINF' => D();
					end;
				};
				field 'classes' => hash {
					field 'CAS_RN' => hash {
					  field 'description' => D();
					  field 'types' => array {
					    item 'CHEMINF:000446';
					    end;
					  };
					};
					end;
				};
				etc;
			};
		},
		'class';
;
};

done_testing;
__DATA__
__[ empty ]__
---

__[ basic ]__
_meta:
  name: OKG-ML
  version: 1.0.0

__[ prefix ]__
prefixes:
  CAS:
    uri: http://identifiers.org/cas/

__[ class ]__
prefixes:
  CAS:
    uri: http://identifiers.org/cas/
  CHEMINF:
    uri: http://purl.obolibrary.org/obo/CHEMINF_
classes:
  CAS_RN:
    description: >-
      CAS registry number.
    types:
      - CHEMINF:000446

__[ data ]__
prefixes:
  BAO:
    uri: http://www.bioassayontology.org/bao#BAO_
  CAS:
    uri: http://identifiers.org/cas/
  CHEMINF:
    uri: http://purl.obolibrary.org/obo/CHEMINF_
classes:
  Assay:
    description: bioassay
    types:
      - BAO:0000015
  CAS RN:
    description: CAS registry number.
    prefix: CAS
    types:
      - CHEMINF:000446
  DSSTOX SID:
    description: DSSTOX substance identifier
    types:
      - CHEMINF:000568
    uri: 'https://comptox.epa.gov/dashboard/chemical/details/{value}'
datasets:
  ice:
    inputs:
      data-source/ice/Acute_Dermal_Toxicity_Data.parquet:
        elements:
          - Assay:
              columns: [ 'Assay' ]
              mapper:
                ValueLabel:
                  class: Assay
          - CASRN:
              columns: [ 'CASRN' ]
              mapper:
                Class:
                  class: CAS RN
          - Chemical Name:
              columns: [ 'Chemical Name' ]
              mapper:
                Value: ~
          - DTXSID:
              columns: [ 'DTXSID' ]
              mapper:
                Class:
                  class: DSSTOX SID
          - Data Name:
              class: ~
              type: ~
          - Data Type:
              class: ~
              type: ~
          - Data Version:
              class: ~
              type: ~
          - Endpoint:
              class: ~
              type: ~
          - Formulation ID:
              class: ~
              type: ~
          - Formulation Name:
              class: ~
              type: ~
          - Mixture:
              class: ~
              type: ~
          - Percent Active Ingredient:
              class: ~
              type: ~
          - Record ID:
              class: ~
              type: ~
          - Reference:
              class: ~
              type: ~
          - Response:
              class: ~
              type: ~
          - Response Modifier:
              class: ~
              type: ~
          - Response Unit:
              class: ~
              type: ~
          - Route:
              class: ~
              type: ~
          - Species:
              class: ~
              type: ~
