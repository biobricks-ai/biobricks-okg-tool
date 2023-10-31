#!/usr/bin/env perl
# PODNAME: simple-sql-template-dump
# ABSTRACT: Dumps a simple SQL template

use lib::projectroot qw(lib);

use Bio_Bricks::KG::App::SQLTemplater;

sub main {
	Bio_Bricks::KG::App::SQLTemplater->new_with_options->run;
}

main;
