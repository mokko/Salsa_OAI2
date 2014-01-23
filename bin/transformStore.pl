#!/usr/bin/perl
# PODNAME: freigabe.pl
# ABSTRACT: freigabe that acts on SalsaOAI's data store

use strict;
use warnings;
use XML::LibXML;
use Getopt::Std;
use Pod::Usage;
use Dancer ':syntax';

use FindBin;
use lib "$FindBin::Bin/../lib";    #works only under *nix, of course
use Salsa_OAI::Transformer;
use Cwd 'realpath';

Dancer::Config::setting( 'appdir', realpath("$FindBin::Bin/..") );
Dancer::Config::load();

getopts( 'vhp', my $opts = {} );
pod2usage() if ( $opts->{h} );

=head1 SYNOPSIS

transformStore.pl -p -v tansform.xsl

=head2 COMMAND LINE OPTIONS

=over 1

=item -p

plan only: don't save the transform in the store

=item -v

verbose: be more verbose

=back

=head1 DESCRIPTION

Applies xslt 1 of your choice to each item in the data store.

=head2 TODO

?

=cut

#
#check general sanity
#
if ( !$opts->{v} ) {
	$opts->{v} = 0;
}

if ( !$opts->{p} ) {
	$opts->{p} = 0;
}

if ( !$ARGV[0] ) {
	print "Error: Need input file!\n";
	exit 1;
}

if ( !-f $ARGV[0] ) {
	print "Error: Specified input file not found!\n";
	exit 1;
}

#
#
#

debug "Expecting db at '".config->{engine}{dbfile}."'";

my $transformer = new Salsa_OAI::Transformer(
	dbfile  => config->{engine}{dbfile},
	verbose => $opts->{v},
	plan    => $opts->{p}
);

my $changed = $transformer->run( $ARGV[0] );
if ($opts->{p}) {
	print "$changed records would have been changed.\n";
} else {
	print "$changed records changed.\n";
}


