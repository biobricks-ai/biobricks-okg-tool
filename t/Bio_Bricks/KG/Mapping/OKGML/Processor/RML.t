#!/usr/bin/env perl

use Test2::V0;

use lib 't/lib';

use YAML qw(Load);
use Data::Section -setup;

subtest "" => sub {
	my $yaml = __PACKAGE__->section_data('input.yml')->$*;
	my $ttl = __PACKAGE__->section_data('output.ttl')->$*;

	my $data = Load($yaml);
	my $model = Bio_Bricks::KG::Mapping::OKGML::Model
		->FROM_HASH($data);
	my $rml = Bio_Bricks::KG::Mapping::OKGML::Processor::RML->new(
		model => $model,
	);

	my $output_fh = \*STDOUT;
	Attean->get_serializer( 'Turtle' )
		->new( namespaces => $rml->rml_context->namespaces )
		->serialize_iter_to_io( $output_fh, $rml->triple_store->get_triples );

};

done_testing;
__DATA__
__[ input.yml ]__
_meta:
  name: OKG-ML
  version: 1.0.0
classes:
  RecordPK:
    description: A record in the dataset
    types:
      - 'http://example.com/RecordPK' # measure group?
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
      data-source/ice/DART_Data.parquet:
        elements:
          - _RecordPK:
              _mapper_alts:
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Record ID
                - DTXSID
              mapper:
                Class:
                  class: RecordPK
          - Data Name:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Data Name
              mapper: {}
          - Data Type:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Data Type
              mapper: {}
          - Data Version:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Data Version
              mapper: {}
          - Record ID:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Record ID
              mapper: {}
          - Chemical Name:
              _mapper_alts:
                Class:
                  class: ~
                ValueLabel:
                  class: ~
              columns:
                - Chemical Name
              mapper:
                Value:
                  value: Chemical Name
          - CASRN:
              _mapper_alts:
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - CASRN
              mapper:
                Class:
                  class: CAS RN
          - DTXSID:
              _mapper_alts:
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - DTXSID
              mapper:
                Class:
                  class: DSSTOX SID
          - Study ID:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Study ID
              mapper: {}
          - Species:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Species
              mapper: {}
          - Strain:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Strain
              mapper: {}
          - Sex:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Sex
              mapper: {}
          - Lifestage:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Lifestage
              mapper: {}
          - Route:
              _mapper_alts:
                Class:
                  class: ~
                ValueLabel:
                  class: ~
              columns:
                - Route
              mapper:
                Value:
                  value: Route
          - Critical Effect:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Critical Effect
              mapper:
                Value:
                  value: Critical Effect
          - Assay:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
              columns:
                - Assay
              mapper:
                ValueLabel:
                  class: Assay
          - Endpoint:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Endpoint
              mapper:
                Value:
                  value: Endpoint
          - Response:
              _mapper_alts:
                Class:
                  class: ~
                ValueLabel:
                  class: ~
              columns:
                - Response
              mapper:
                Value:
                  value: Response
          - Response Unit:
              _mapper_alts:
                Class:
                  class: ~
                ValueLabel:
                  class: ~
              columns:
                - Response Unit
              mapper:
                Value:
                  value: Response Unit
          - Unified Medical Language System:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Unified Medical Language System
              mapper: {}
          - Reference:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Reference
              mapper: {}
          - PMID:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - PMID
              mapper: {}
          - URL:
              _mapper_alts:
                Class:
                  class: ~
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - URL
              mapper: {}
mappings:
  - >-
    <(RecordPK)>
      ex:has_assay <(Assay)>;
      ex:has_chemical <(CAS RN)>, <(DTXSID)>
      .

    <(Assay)>
      ex:has_critical_effect "(Critical Effect)" ;
      ex:has_endpoint        "(Endpoint)"        ;
      ex:has_response        "(Response)"        ;
      ex:has_response_unit   "(Response Unit)"   ;
      ex:has_route           "(Route)"           .
prefixes:
  BAO:
    uri: http://www.bioassayontology.org/bao#BAO_
  CAS:
    uri: http://identifiers.org/cas/
  CHEMINF:
    uri: http://purl.obolibrary.org/obo/CHEMINF_
values:
  Chemical Name: ~
  Critical Effect: ~
  Endpoint: ~
  Response: ~
  Response Unit: ~
  Route: ~

__[ output.ttl ]__
@prefix cheminf: <http://semanticscience.org/resource/CHEMINF_> .
@prefix ex:      <http://example.com/> .
@prefix ex-base: <http://example.com/base/> .
@prefix fnml:    <http://semweb.mmlab.be/ns/fnml#> .
@prefix fno:     <https://w3id.org/function/ontology#> .
@prefix grel:    <http://users.ugent.be/~bjdmeest/function/grel.ttl#> .
@prefix ql:      <http://semweb.mmlab.be/ns/ql#> .
@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
@prefix rml:     <http://semweb.mmlab.be/ns/rml#> .
@prefix rr:      <http://www.w3.org/ns/r2rml#> .
@prefix xsd:     <http://www.w3.org/2001/XMLSchema> .

[ rdf:type           rr:TriplesMap;
  rml:logicalSource  ex-base:ls_DART_Data;
  rr:subjectMap      [ rr:class     cheminf:000000 , cheminf:000568;
                       rr:template  "https://comptox.epa.gov/dashboard/chemical/details/{DTXSID}"
                     ]
] .

[ rdf:type           rr:TriplesMap;
  rml:logicalSource  ex-base:ls_DART_Data;
  rr:subjectMap      [ rr:class     cheminf:000000 , cheminf:000446;
                       rr:template  "http://identifiers.org/cas/{CASRN}"
                     ]
] .

ex-base:TripleMap_Top_DART_Data
        rdf:type               rr:TriplesMap;
        rml:logicalSource      ex-base:ls_DART_Data;
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Data Type" ];
                                 rr:predicate  ex:data_type
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Chemical Name" ];
                                 rr:predicate  ex:chemical_name
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Reference" ];
                                 rr:predicate  ex:reference
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "http://identifiers.org/cas/{CASRN}" ];
                                 rr:predicate  ex:casrn
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Unified Medical Language System" ];
                                 rr:predicate  ex:unified_medical_language_system
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Record ID" ];
                                 rr:predicate  ex:record_id
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "http://example.com/ice/DART_Data/record_id/{Record ID}/dtxsid/{DTXSID}/{_ROW_NUMBER}/Relation-Endpoint" ];
                                 rr:predicate  ex:relation-endpoint
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Sex" ];
                                 rr:predicate  ex:sex
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "https://comptox.epa.gov/dashboard/chemical/details/{DTXSID}" ];
                                 rr:predicate  ex:dtxsid
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Data Version" ];
                                 rr:predicate  ex:data_version
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "_ROW_NUMBER" ];
                                 rr:predicate  ex:_row_number
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "URL" ];
                                 rr:predicate  ex:url
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Species" ];
                                 rr:predicate  ex:species
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Lifestage" ];
                                 rr:predicate  ex:lifestage
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "PMID" ];
                                 rr:predicate  ex:pmid
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Study ID" ];
                                 rr:predicate  ex:study_id
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Strain" ];
                                 rr:predicate  ex:strain
                               ];
        rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Data Name" ];
                                 rr:predicate  ex:data_name
                               ];
        rr:subjectMap          [ rr:class     ex:DART_Data_Record;
                                 rr:template  "http://example.com/ice/DART_Data/record_id/{Record ID}/dtxsid/{DTXSID}"
                               ] .

ex-base:ls_DART_Data  rdf:type    rml:LogicalSource;
        rml:referenceFormulation  ql:CSV;
        rml:source                "data-processed/ice/DART_Data.parquet" .

[ rdf:type               rr:TriplesMap;
  rml:logicalSource      ex-base:ls_DART_Data;
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Response" ];
                           rr:predicate  ex:response
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Response Unit" ];
                           rr:predicate  ex:response_unit
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Endpoint" ];
                           rr:predicate  ex:endpoint
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Route" ];
                           rr:predicate  ex:route
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Assay" ];
                           rr:predicate  ex:assay
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Critical Effect" ];
                           rr:predicate  ex:critical_effect
                         ];
  rr:subjectMap          [ rr:class     ex:DART_Data-Endpoint;
                           rr:template  "http://example.com/ice/DART_Data/record_id/{Record ID}/dtxsid/{DTXSID}/{_ROW_NUMBER}/Relation-Endpoint"
                         ]
] .
