#!perl 
#-T doesn't work with FindBin

use strict;
use warnings;
use Test::More tests => 1;
use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN {
    use_ok( 'Salsa_OAI::Updater::SQLite' ) || print "Bail out!";
}

diag( "Testing Salsa_OAI::Updater::SQLite $Salsa_OAI::Updater::SQLite::VERSION, Perl $], $^X" );