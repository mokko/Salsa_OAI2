#!/usr/bin/perl
# PODNAME: digest.pl
# ABSTRACT: store mpx info (onebig file) in SQLite db

use strict;
use warnings;
use XML::LibXML;
use XML::LibXML::XPathContext;
use Carp qw/croak/;
use Dancer ':syntax';
use FindBin;
use lib "$FindBin::Bin/../lib";    #works only under *nix, of course
use HTTP::OAI::DataProvider;
use HTTP::OAI::DataProvider::SQLite;
use Salsa_OAI::MPX;
use Cwd 'realpath';
use Getopt::Std;
use Pod::Usage;

getopts( 'nvh', my $opts = {} );
pod2usage() if ($opts->{h});
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
	print "Try /home/Mengel/projects/Salsa_OAI2/data/fix-test.lvl2.mpx\n";
	exit 1;
}

#
# dancer config
#

Dancer::Config::setting( 'appdir', realpath("$FindBin::Bin/..") );
Dancer::Config::load();
config->{environment} = 'production';    #makes debug silent

#croak if vars missing in conf
test_conf_var(qw/dbfile nativePrefix native_ns_uri/);

#
# validate source file
#
if ( !$opts->{n} ) {
	if ( config->{nativeSchema} ) {
		verbose "About to validate source file before import";
		if ( !config->{nativeSchema} ) {
			die 'Schema not found (' . config->{nativeSchema} . ')';
		}

		my $doc = XML::LibXML->new->parse_file( $ARGV[0] );
		my $xmlschema =
		  XML::LibXML::Schema->new( location => config->{nativeSchema} );
		eval { $xmlschema->validate($doc); };

		if ($@) {
			die "$ARGV[0] failed validation: $@" if $@;
		} else {
			print "$ARGV[0] validates\n";
		}
	}
} else {
	debug "no validate option";
}

#
# init
#
my $provider = HTTP::OAI::DataProvider->new(config);

#
# call digest_single
#

#violates demeter's law
my $err = $provider->{engine}->digest_single(
	source  => $ARGV[0],
	mapping => config->{extractRecords},
);

#report errors if any
if ($err) {
	die $err;
}

print "done\n";

#
# SUBS
#

sub test_conf_var {
	foreach (@_) {
		if ( !config->{$_} ) {
			croak "Error:Config variable $_ missing";
		}
	}
}


sub verbose {
	my $msg = shift;
	if ($msg) {
		if ( $opts->{v} ) {
			print $msg. "\n";
		}
	}
}

__END__
=pod

=head1 NAME

digest.pl - store mpx info (onebig file) in SQLite db

=head1 VERSION

version 0.013

=head1 SYNOPSIS

digest.pl file.mpx

=head2 Command Line Options

=over 4

*-n:   no validation
*-v:   verbose

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

=head1 FUNCTIONS

=head2 test_conf_var ($var1, $var2);

Croaks if specified vars do not exist in config.

=head2 verbose 'message';

=head1 KNOWN ISSUES / TODO

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

