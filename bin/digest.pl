#!/usr/bin/perl
# PODNAME: digest.pl
# ABSTRACT: store mpx info (one big file) in SQLite db

use strict;
use warnings;
use XML::LibXML;
use XML::LibXML::XPathContext;
use Carp qw/croak/;
use Dancer ':syntax';

#use FindBin;
#use lib "$FindBin::Bin/../lib";    #works only under *nix, of course
use HTTP::OAI::DataProvider::Ingester;

#use HTTP::OAI::DataProvider;
#use HTTP::OAI::DataProvider::Engine::SQLite;
use Salsa_OAI::MPX;
use Cwd 'realpath';
use Getopt::Std;
use Pod::Usage;

=head1 SYNOPSIS

digest.pl file.mpx

=head2 Command Line Options

=over 4

=item *-n:   no validation

=item *-v:   verbose

=back

=head1 DESCRIPTION

This helper script reads in a big mpx lvl2 file, processes it and stores
relevant information into an SQLite database for use in OAI data provider.

=head2 Database Structure

table 1 records
-ID
-identifier
-datestamp
-metadata

table 2 sets
-setSpec
-recordID

=cut

getopts( 'nvh', my $opts = {} );
pod2usage() if ( $opts->{h} );
sub verbose;

#for dirty debugging
#use Data::Dumper qw/Dumper/;

#
# command line input
#

if ( !$ARGV[0] ) {
	print "Error: Need to specify digest file\n";
	exit 1;
}

if ( !-f $ARGV[0] ) {
	print "Error: Specified digest files does not exist\n";
	print "Try /home/Maurice/projects/Salsa_OAI2/data/fix-test.lvl2.mpx\n";
	exit 1;
}

#
# dancer config
#

Dancer::Config::setting( 'appdir', realpath("$FindBin::Bin/..") );
Dancer::Config::load();
config->{environment} = 'production';    #makes debug silent


my $nativePrefix = ( keys %{ config->{engine}{'nativeFormat'} } )[0];
my $nativeURI    = config->{engine}{nativeFormat}{$nativePrefix}
  || die "No schema uri for validation specified!";

#
# validate source file
#


if ( !$opts->{n} ) {
	verbose "Validateing source file before import ...";

	my $doc = XML::LibXML->new->parse_file( $ARGV[0] );
	my $xmlschema = XML::LibXML::Schema->new( location => $nativeURI );
	eval { $xmlschema->validate($doc); };

	if ($@) {
		die "$ARGV[0] failed validation: $@" if $@;
	}
	else {
		print "$ARGV[0] validates\n";
	}
}
else {
	debug "no validate option active, so no validation attempted";
}

#
# init
#
my $ingester = HTTP::OAI::DataProvider::Ingester->new(
	engine       => config->{engine}{engine},
	dbfile       => config->{engine}{dbfile},
	nativePrefix => $nativePrefix,
	nativeURI    => $nativeURI,
);
#
# call digest_single
#

#Salsa_OAI::MPX::extractRecords is not propper. Should be loaded from config
$ingester->digest( source => $ARGV[0], mapping => \&Salsa_OAI::MPX::extractRecords )
  or die "Can't digest";

print "done\n";
exit;

#
# SUBS
#


=func verbose 'message';
=cut

sub verbose {
	my $msg = shift;
	if ($msg) {
		if ( $opts->{v} ) {
			print $msg. "\n";
		}
	}
}

