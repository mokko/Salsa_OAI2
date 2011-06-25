#!/usr/bin/env perl
use Plack::Runner;
use Dancer ':syntax';
my $psgi = path(dirname(__FILE__), '..', 'Salsa_OAI2.pl');
Plack::Runner->run($psgi);
