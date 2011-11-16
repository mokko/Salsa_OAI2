#!perl 
#-T doesn't work with FindBin

use strict;
use warnings;
use Test::More tests => 2;
use Debug::Simpler 'debug';
Debug::Simpler::debug_on();
use FindBin;
use lib "$FindBin::Bin/../lib";    #works only under *nix

use Salsa_OAI::Updater::SQLite;

eval { my $store = new Salsa_OAI::Updater::SQLite; };
ok( $@, 'dies without dbfile' );

my $dir="$FindBin::Bin/data";
if (!-d $dir) {
	mkdir $dir;
}
my $dbfile = "$dir/testdb";
my $store = new Salsa_OAI::Updater::SQLite( $dbfile );

ok(
	ref $store eq 'Salsa_OAI::Updater::SQLite',
	'Salsa_OAI::Updater::SQLite created'
);


#SELECT records.identifier, records.datestamp, records.status, records.native_md, sets.setSpec 
#FROM records LEFT JOIN sets ON records.identifier = sets.identifier;
