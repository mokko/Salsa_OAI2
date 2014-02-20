#!/usr/bin/perl
# PODNAME: updateStore.pl
# ABSTRACT: update mpx store

use strict;
use warnings;
use Getopt::Std;
use Pod::Usage;
use Dancer ':syntax';

use Cwd 'realpath'; # not absolutely necessary I believe
use FindBin;
use lib "$FindBin::Bin/../lib";    #works only under *nix, of course
use Salsa_OAI::Updater;

=head1 SYNOPSIS

 #remove outdated resources:
 updateStore.pl rmres mume.mpx

 #update resources:
 updateStore.pl upres mume.mpx

 #update agents:
 updateStore.pl upagt mume.mpx

 The first parameter is called command.

=head2 Command Line Options

=over 1

=item -v

verbose output

=item -h

help text

=back

=cut

Dancer::Config::setting( 'appdir', realpath("$FindBin::Bin/..") );
Dancer::Config::load();

getopts( 'vh', my $opts = {} );
pod2usage() if ($opts->{h});

if (!$opts->{v}) {
	$opts->{v}=0;
}


if (!$ARGV[0]) {
	print "Error: Need command!\n";
	exit 1;
}

if ($ARGV[0]!~/^rmres$|^upres$|^upagt$/) {
	print "Error: Don't know command!\n";
	exit 1;
}


if (!$ARGV[1]) {
	print "Error: Need mpx file!\n";
	exit 1;
}

if (! -f $ARGV[1]) {
	print "Error: Need mpx file!\n";
	exit 1;
}

my $dbfile=config->{engine}{dbfile} || die "dbfile info missing!";

my $updater=new Salsa_OAI::Updater (
	dbfile=>$dbfile,
	Debug=>$opts->{v},
);

my $cmd=$ARGV[0];
$updater->$cmd ($ARGV[1]);
print "done\n";
