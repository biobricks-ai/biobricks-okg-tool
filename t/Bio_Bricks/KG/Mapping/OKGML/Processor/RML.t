#!/usr/bin/env perl

use Test2::V0;

use lib 't/lib';

use YAML::XS qw(Load);
use Data::Section -setup;

use Path::Tiny;
use Bio_Bricks::KG::Mapping::OKGML::Model;
use Bio_Bricks::KG::Mapping::OKGML::Processor::RML;
use Capture::Tiny qw(capture);

subtest "RML RDF generation from OKG-ML YAML" => sub {
	my $yaml = __PACKAGE__->section_data('input.yml')->$*;
	my $ttl = __PACKAGE__->section_data('output.ttl')->$*;

	my $data = Load($yaml);
	my $model = Bio_Bricks::KG::Mapping::OKGML::Model
		->FROM_HASH($data);
	my $rml = Bio_Bricks::KG::Mapping::OKGML::Processor::RML->new(
		model => $model,
	);

	my $output_fh = \*STDOUT;
	my $expected_iter = Attean->get_parser( 'Turtle' )->new()
		->parse_iter_from_bytes( $ttl );


        my $tempdir = Path::Tiny->tempdir;
        $tempdir->mkpath unless -d $tempdir;

        my $expected_nt = $tempdir->child('expected.nt');
        my $got_nt      = $tempdir->child('got.nt');

	Attean->get_serializer( 'CanonicalNTriples' )->new()
		->serialize_iter_to_io( $expected_nt->openw, $expected_iter );

	Attean->get_serializer( 'CanonicalNTriples' )->new()
		->serialize_iter_to_io( $got_nt->openw, $rml->triple_store->get_triples );

        die "Need to set JENA_HOME" unless $ENV{JENA_HOME};
        my ($output, $error, $exit) = capture {
          system("$ENV{JENA_HOME}/bin/rdfcompare", $expected_nt, $got_nt);
        };
        die "Failed to compare:\n$output\n$error" unless 0 == $exit;

        like $output, qr/\Amodels are equal/, 'Models are equal';
};

done_testing;
__DATA__
__[ input.yml ]__
---
_meta:
  name: OKG-ML
  version: 1.0.0
classes:
  RecordPK:
    description: A record in the dataset
    types:
      - 'http://example.com/RecordPK' # measure group?
  Measure_Group:
    description: Measure group (connects assay with endpoint)
    types:
      - BAO:0000040
  Chemical_Entity:
    description: A chemical entity
    types:
      - CHEMINF:000000
  Endpoint:
    description: Endpoint result
    types:
      - BAO:0000179
  Assay:
    description: bioassay
    types:
      - BAO:0000015
  CAS_RN:
    description: CAS registry number.
    prefix: CAS
    types:
      - CHEMINF:000446
  DSSTOX_SID:
    description: DSSTOX substance identifier
    types:
      - CHEMINF:000568
    uri: 'https://comptox.epa.gov/dashboard/chemical/details/{value}'
datasets:
  ice:
    inputs:
      data-source/ice/DART_Data.parquet:
        elements:
          - _ChemicalEntity:
              _mapper_alts:
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - DTXSID
              mapper:
                Class:
                  class: Chemical_Entity
          - _MeasureGroup:
              _mapper_alts:
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - DTXSID
                - Assay
              mapper:
                Class:
                  class: Measure_Group
          - _Endpoint:
              _mapper_alts:
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - Record ID
                - DTXSID
                - Endpoint
              mapper:
                ValueLabel:
                  class: Endpoint
                  label_column: Endpoint
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
                  value: Chemical_Name
          - CASRN:
              _mapper_alts:
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - CASRN
              mapper:
                Class:
                  class: CAS_RN
          - DTXSID:
              _mapper_alts:
                Value: ~
                ValueLabel:
                  class: ~
              columns:
                - DTXSID
              mapper:
                Class:
                  class: DSSTOX_SID
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
                  value: Critical_Effect
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
              mapper: {}
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
                  value: Response_Unit
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
    <(Assay)>
      BAO:0000209 <(Measure_Group)>. # (has measure group)

    <(Measure_Group)>
      OBI:0000299 <(Endpoint)>        ; # (has specified output)
      RO:0000057  <(Chemical_Entity)> . # (has participant)

    <(Chemical_Entity)>
      rdfs:label          "(Chemical_Name)" ;
      RO:0000056          <(Measure_Group)> ; # (participates in)
      EDAM:has_identifier <(CAS_RN)>        ;
      EDAM:has_identifier <(DSSTOX_SID)>    .

    <(Endpoint)>
      SIO:has-value "(Response)"      ;
      SIO:has-unit  "(Response_Unit)" ;
      ExO:0000055   "(Route)"         . # route

    <(CAS_RN)>
      rdfs:label "(Chemical_Name)";
      dce:source "CAS"            .

    <(DSSTOX_SID)>
      rdfs:label "(Chemical_Name)";
      dce:source "CompTox"        .
prefixes:
  BAO:
    uri: http://www.bioassayontology.org/bao#BAO_
  CAS:
    uri: http://identifiers.org/cas/
  CHEMINF:
    uri: http://purl.obolibrary.org/obo/CHEMINF_
  SIO:
    uri: http://semanticscience.org/resource/SIO_
  OBI:
    uri: http://purl.obolibrary.org/obo/OBI_
  RO:
    uri: http://purl.obolibrary.org/obo/RO_
  ExO:
    uri: http://purl.obolibrary.org/obo/ExO_
  EDAM:
    uri: http://edamontology.org/
  dce:
    uri: http://purl.org/dc/elements/1.1/
  dcterms:
    uri: http://purl.org/dc/terms/
  rdfs:
    uri: http://www.w3.org/2000/01/rdf-schema#
values:
  Chemical_Name: ~
  Critical_Effect: ~
  Response: ~
  Response_Unit: ~
  Route: ~

__[ output.ttl ]__
@prefix BAO:     <http://www.bioassayontology.org/bao#BAO_> .
@prefix CAS:     <http://identifiers.org/cas/> .
@prefix CHEMINF: <http://purl.obolibrary.org/obo/CHEMINF_> .
@prefix EDAM:    <http://edamontology.org/> .
@prefix ExO:     <http://purl.obolibrary.org/obo/ExO_> .
@prefix OBI:     <http://purl.obolibrary.org/obo/OBI_> .
@prefix RO:      <http://purl.obolibrary.org/obo/RO_> .
@prefix SIO:     <http://semanticscience.org/resource/SIO_> .
@prefix dce:     <http://purl.org/dc/elements/1.1/> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix fnml:    <http://semweb.mmlab.be/ns/fnml#> .
@prefix fno:     <https://w3id.org/function/ontology#> .
@prefix grel:    <http://users.ugent.be/~bjdmeest/function/grel.ttl#> .
@prefix ql:      <http://semweb.mmlab.be/ns/ql#> .
@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
@prefix rml:     <http://semweb.mmlab.be/ns/rml#> .
@prefix rr:      <http://www.w3.org/ns/r2rml#> .
@prefix xsd:     <http://www.w3.org/2001/XMLSchema> .

[ rdf:type               rr:TriplesMap;
  rml:logicalSource      <ls_ice_data-source_ice_DART_Data.parquet>;
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Response" ];
                           rr:predicate  SIO:has-value
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Response Unit" ];
                           rr:predicate  SIO:has-unit
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Route" ];
                           rr:predicate  ExO:0000055
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Endpoint" ];
                           rr:predicate  rdfs:label
                         ];
  rr:subjectMap          [ rr:class     BAO:0000179;
                           rr:template  "http://example.com/ice/DART_Data.parquet/record_id/{Record ID}/dtxsid/{DTXSID}/endpoint/{Endpoint}/Endpoint"
                         ]
] .

[ rdf:type               rr:TriplesMap;
  rml:logicalSource      <ls_ice_data-source_ice_DART_Data.parquet>;
  rr:predicateObjectMap  [ rr:objectMap  [ rr:constant  "CompTox" ];
                           rr:predicate  dce:source
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Chemical Name" ];
                           rr:predicate  rdfs:label
                         ];
  rr:subjectMap          [ rr:class     CHEMINF:000568;
                           rr:template  "https://comptox.epa.gov/dashboard/chemical/details/{DTXSID}"
                         ]
] .

<ls_ice_data-source_ice_DART_Data.parquet>
        rdf:type                  rml:LogicalSource;
        dce:source                "ice";
        dce:title                 "data-source/ice/DART_Data.parquet";
        rml:referenceFormulation  ql:CSV;
        rml:source                "data-source/ice/DART_Data.parquet" .

[ rdf:type               rr:TriplesMap;
  rml:logicalSource      <ls_ice_data-source_ice_DART_Data.parquet>;
  rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "http://example.com/ice/DART_Data.parquet/record_id/{Record ID}/dtxsid/{DTXSID}/endpoint/{Endpoint}/Endpoint" ];
                           rr:predicate  OBI:0000299
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "http://example.com/ice/DART_Data.parquet/dtxsid/{DTXSID}/Chemical_Entity" ];
                           rr:predicate  RO:0000057
                         ];
  rr:subjectMap          [ rr:class     BAO:0000040;
                           rr:template  "http://example.com/ice/DART_Data.parquet/dtxsid/{DTXSID}/assay/{Assay}/Measure_Group"
                         ]
] .

[ rdf:type               rr:TriplesMap;
  rml:logicalSource      <ls_ice_data-source_ice_DART_Data.parquet>;
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Chemical Name" ];
                           rr:predicate  rdfs:label
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "https://comptox.epa.gov/dashboard/chemical/details/{DTXSID}" ];
                           rr:predicate  EDAM:has_identifier
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "http://example.com/ice/DART_Data.parquet/dtxsid/{DTXSID}/assay/{Assay}/Measure_Group" ];
                           rr:predicate  RO:0000056
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "http://identifiers.org/cas/{CASRN}" ];
                           rr:predicate  EDAM:has_identifier
                         ];
  rr:subjectMap          [ rr:class     CHEMINF:000000;
                           rr:template  "http://example.com/ice/DART_Data.parquet/dtxsid/{DTXSID}/Chemical_Entity"
                         ]
] .

[ rdf:type               rr:TriplesMap;
  rml:logicalSource      <ls_ice_data-source_ice_DART_Data.parquet>;
  rr:predicateObjectMap  [ rr:objectMap  [ rr:constant  "CAS" ];
                           rr:predicate  dce:source
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Chemical Name" ];
                           rr:predicate  rdfs:label
                         ];
  rr:subjectMap          [ rr:class     CHEMINF:000446;
                           rr:template  "http://identifiers.org/cas/{CASRN}"
                         ]
] .

[ rdf:type               rr:TriplesMap;
  rml:logicalSource      <ls_ice_data-source_ice_DART_Data.parquet>;
  rr:predicateObjectMap  [ rr:objectMap  [ rr:template  "http://example.com/ice/DART_Data.parquet/dtxsid/{DTXSID}/assay/{Assay}/Measure_Group" ];
                           rr:predicate  BAO:0000209
                         ];
  rr:predicateObjectMap  [ rr:objectMap  [ rml:reference  "Assay" ];
                           rr:predicate  rdfs:label
                         ];
  rr:subjectMap          [ rr:class     BAO:0000015;
                           rr:template  "http://example.com/ice/DART_Data.parquet/assay/{Assay}/Assay"
                         ]
] .
