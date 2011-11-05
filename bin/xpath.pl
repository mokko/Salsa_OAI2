#!/usr/bin/perl
# PODNAME: xpath.pl
# ABSTRACT: apply xpath on xml files

use strict;
use warnings;
use XML::LibXML;
use Pod::Usage;
use Getopt::Std;

sub debug;

getopts( 'f:vh', my $opts = {} );
pod2usage() if ( $opts->{h} );

=head1 SYNOPSIS

xpath.pl -v -f file.xml '//xpath'
xpath.pl -h

=head2 COMMAND LINE OPTIONS

=over 1

=item -h

help: this text

=item -p

plan: plan: show what would happen, don't change anything

=item -v

verbose: be more verbose

=back

=head1 DESCRIPTION

Little tool that applies xpath queries to xml. Let's see how elegant I can make 
this within a few hours.

=head2 TODO

=cut

commandLineSanity($opts);

#
# SUBs
# 

sub commandLineSanity {
	my $opts = shift or die "Need opts";

	debug "Debug/verbose mode on";


	if ( !$opts->{f} ) {
		print "Error: Need xml file! Specify using -f\n";
		exit;
	}

	if ( ! -f $opts->{f} ) {
		print "Error: Input xml file not found!\n";
		exit;
	}

	if (!$ARGV[0]) {
		print "Error: No xpath specified\n";
	}

}

sub debug {
	my $msg = shift;
	if ( $opts->{v} ) {
		print $msg. "\n";
	}
}
