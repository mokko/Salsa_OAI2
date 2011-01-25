#!/usr/bin/perl

use strict;
use warnings;
use XML::LibXML;
use XML::LibXML::XPathContext;

#I don't even Debug in here
#use Dancer::CommandLine qw/Debug Warning/;
use Dancer::CommandLine::Config;

use FindBin;
use lib "$FindBin::Bin/../lib";
use HTTP::OAI::DataProvider::SQLite;
use Salsa_OAI::MPX;

#for dirty debugging
#use Data::Dumper qw/Dumper/;

=head1 NAME

digest_single.pl - store relevant from a single big mpx file into SQLite db

=head1 SYNOPSIS

digest_single.pl file.mpx

=head1 DESCRIPTION

This helper script reads in a big mpx lvl2 file, processes it and stores
relevant information into an SQLite database for use in OAI data provider.
At this point, I am not quite sure how I will call the data provider. See
Salsa_OAI anyways.

For development purposes, this file should have everything that is mpx
specific, so that HTTP::OAI::DataProvider doesn't have any of it. Later,
the mpx specific stuff should go into the Dancer front-end.

=head2 Database Structure

table 1 records
-ID
-identifier
-datestamp
-metadata

table 2 sets
-setSpec
-recordID

=head1 KNOWN ISSUES / TODO

=head2 Missing related info

Currently, this incarnation deals only with the mpx's sammlungobjekt, but the
later xslt will have to access related info from personKörperschaft and multi-
mediaobjekt as well. Hence, we need those two. I should store them in the same
xml blob as the main sammlungsobjekt. This requires rewriting extractRecords.
It no longer can parse sammlungsobjekt by sammlungsobjekt, but needs a
different loop with access to more or less the whole document.

=head2 Wrong package?

Currently, this script is part of HTTP::OAI::DataProvider, but its mpx specific
parts should later go to Dancer front end. When it exists.

=head1 AUTHOR

Maurice Mengel, 2011

=head1 LICENSE

This module is free software and is published under the same
terms as Perl itself.

=head1 SEE ALSO

todo


=cut

#
# command line input
#

if ( !$ARGV[0] ) {
	print "Error: Need to specify digest file\n";
	exit 1;
}

if ( !-f $ARGV[0] ) {
	print "Error: Specified digest files does not exist\n";
	print "Try /home/Mengel/projects/Salsa_OAI2/data/fix-test.lvl2.mpx\n";
	exit 1;
}

#
# dancer config
#

#Guesses the correct path
my $c = new Dancer::CommandLine::Config( $FindBin::Bin. '/../config.yml' );

#croak if vars missing in conf
$c->test_conf_var(qw/dbfile native_ns_prefix native_ns_uri/);
my $config = $c->get_config;

#
# init
#

my $engine = new HTTP::OAI::DataProvider::SQLite(
	dbfile    => $config->{dbfile},
	ns_prefix => $config->{native_ns_prefix},
	ns_uri    => $config->{native_ns_uri},
);

#
# call digest_single
#

my $err = $engine->digest_single(
	source  => $ARGV[0],
	mapping => $config->{extractRecords},
);

#report errors if any
if ($err) {
	die $err;
}
