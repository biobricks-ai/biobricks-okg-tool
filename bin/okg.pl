#!/usr/bin/env perl
# PODNAME: KG tool

use lib::projectroot qw(lib);

use Bio_Bricks::KG::App;

sub main {
	Bio_Bricks::KG::App->new->run;
}

main;
