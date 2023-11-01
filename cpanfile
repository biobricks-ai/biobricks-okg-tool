requires 'Attean';
requires 'Attean::IRI';
requires 'Attean::RDF';
requires 'CLI::Osprey';
requires 'Capture::Tiny';
requires 'Data::Dumper';
requires 'Data::TableReader';
requires 'Devel::StrictMode';
requires 'Exporter::Tiny';
requires 'Feature::Compat::Try';
requires 'File::Spec';
requires 'Function::Parameters';
requires 'IO::String';
requires 'Import::Into';
requires 'List::Util';
requires 'MooX::Struct';
requires 'MooX::TypeTiny';
requires 'Mu';
requires 'Mu::Role';
requires 'Object::Util';
requires 'Path::Iterator::Rule';
requires 'Path::Tiny';
requires 'Return::Type::Lexical';
requires 'Search::Fzf';
requires 'String::CamelCase';
requires 'Text::ANSITable';
requires 'Text::CSV';
requires 'Type::Libraries';
requires 'Type::Library', '0.008';
requires 'Type::Utils';
requires 'Types::Attean';
requires 'Types::Common';
requires 'Types::Common::Numeric';
requires 'Types::Path::Tiny';
requires 'Types::URI';
requires 'URI::Encode';
requires 'URI::NamespaceMap';
requires 'With::Roles';
requires 'aliased';
requires 'autodie';
requires 'base';
requires 'constant';
requires 'curry';
requires 'feature';
requires 'lib::projectroot';
requires 'namespace::clean';
requires 'strict';
requires 'warnings';

on test => sub {
    requires 'LWP::Protocol::https';
    requires 'LWP::UserAgent';
    requires 'Test2::V0';
};
