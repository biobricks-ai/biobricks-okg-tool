#!/bin/sh

PERL_STRICT=1 perl -MCarp::Always ./bin/simple-rml-dump.pl --base-dir ../../../ctdbase-kg/ctdbase-kg --output-file test.ttl ;
clear;
< test.ttl $JENA_HOME/bin/riot --syntax=Turtle --formatted=Turtle
