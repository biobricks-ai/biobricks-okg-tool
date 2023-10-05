#!/usr/bin/env perl
# PODNAME: simple-rml-dump
# ABSTRACT: Dumps a simple RML

use lib::projectroot qw(lib);

use Bio_Bricks::KG::App::SimpleDumper;

sub main {
	Bio_Bricks::KG::App::SimpleDumper->new_with_options->run;
}

main;
