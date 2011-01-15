#!/usr/bin/perl

use strict;
use warnings;
use XML::LibXML;
use XML::LibXML::XPathContext;
#I don't even Debug in here
#use Dancer::CommandLine qw/Debug Warning/;

use lib '/home/Mengel/projects/HTTP-OAI-DataProvider/lib';
use HTTP::OAI::DataProvider::SQLite;
use lib '/home/Mengel/projects/Salsa_OAI2/lib';
#use Salsa_OAI; #currently the place where the mapping resides
use Salsa_OAI::CommandLine qw/load_conf test_conf_var/;
use Salsa_OAI::Mapping;
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
# user input
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
# check dancer config
#

#Salsa home dir + conf file
my $conf = load_conf();
#croak after error if
test_conf_var(qw/dbfile ns_prefix ns_uri/);

#
# init
#

my $engine = new HTTP::OAI::DataProvider::SQLite(
	dbfile    => $conf->{dbfile},
	ns_prefix => $conf->{ns_prefix},
	ns_uri    => $conf->{ns_uri},
);

#
# do it
#

my $err = $engine->digest_single(
	source  => $ARGV[0],
	mapping => 'Salsa_OAI::Mapping::extractRecords',
);

if ($err) {
	die $err;
}
