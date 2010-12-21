#!/usr/bin/perl

use Dancer ':syntax';
use lib path(dirname(__FILE__), 'lib');
load_app 'Salsa_OAI2';

print "test\n";
debug "test";


exit;

my $test=salsa_setLibrary();
