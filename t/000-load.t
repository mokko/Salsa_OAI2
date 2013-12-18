#!perl -T

use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
	use_ok( 'HTTP::OAI::DataProvider' ) || print "Bail out!";
	#I can't use_ok Salsa_OAI because that would start a dancer webapp
    #use_ok( 'Salsa_OAI' ) || print "Bail out!";
}


diag( "Testing HTTP::OAI::DataProvider; $HTTP::OAI::DataProvider::VERSION, Perl $], $^X" );
