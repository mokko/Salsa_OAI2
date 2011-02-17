#!/usr/bin/perl

use lib '/home/Mengel/projects/Salsa_OAI2/lib';

#use Salsa_OAI;
use Dancer::CommandLine::Config;
use HTTP::OAI;
use HTTP::OAI::Repository;
use HTTP::OAI::Metadata;

use HTTP::OAI::DataProvider::SQLite;
use HTTP::OAI::DataProvider::GlobalFormats;
use HTTP::OAI::DataProvider::Transformer;
use FindBin;
use lib "$FindBin::Bin/../lib"; #works only under *nix, of course
use Salsa_OAI::MPX;
use Getopt::Std;

getopts( 'o:h', my $opts = {} );

if ( $opts->{h} ) {
	print "Usage example: transform.pl -o output.xml 538 lido\n";
	print "See 'perldoc transform.pl' for more\n";
	exit 0;
}

#use Data::Dumper qw/Dumper/;

=head1 NAME

transform.pl - apply a transformation to a record from the data store

=head1 SYNOPSIS

   transform.pl -o output.xml 538 lido
   transform.pl -h
	Get usage summary, for more try 'perldoc transform.pl'

=head1 VERSION

0.01

=cut

our $VERSION = 0.01;

=head1 PARAMETERS

=head2 identifier (required)

Identifier can be shortened (e.g. 538).

=head2 target metadataPrefix (required)

Metadata prefix indicating the format the record will be given out in.

=head2 o (option, optional)

Indicates to write output to file. If not specified, output is written to
STDOUT.

=head2 h (help, optional, exclusive)

Prints a little usage tip. For more info use perldoc transform.pl (this text).

=head1 NOTES / TODO
=cut

#
# CONFIGURATION
#

#not ideal to have the path here
my $c =
  new Dancer::CommandLine::Config(
	'/home/Mengel/projects/Salsa_OAI2/config.yml');
my $config = $c->get_config;
print "dbfile" . $config->{dbfile} . "\n";

#print Dumper $config;
#
# TODO I need to correct this debug
#
#from commandline

if ( !$ARGV[0] ) {
	print "Error: Need identifier!";

	#$config->{id}=$ARGV[0];
	exit 1;
}
if ( !$ARGV[1] ) {
	print "Error: Need target metadata prefix!";

	#$config->{target}=$ARGV[1];
	exit 1;
}

#if (! $opts->{o}) {
#	print "Error: Need output file";
#	exit 1;
#}

print "\nCommand line input:\n";
my $args = {};
if ( $ARGV[0] =~ /\d+/ ) {
	$ARGV[0] = 'spk-berlin.de:EM-objId-' . $ARGV[0];
	print "   identifier ='$ARGV[0]'\n";
	$args->{identifier} = $ARGV[0];
}

if ( $ARGV[1] ) {
	print "   metadataPrefix='$ARGV[1]'\n";
	$args->{metadataPrefix} = $ARGV[1];
}

if ( $ARGV[2] ) {
	print "   set='$ARGV[2]'\n";
	$args->{set} = $ARGV[2];
}

#
# test if metadataFormat supported
#
my $globalFormats = new HTTP::OAI::DataProvider::GlobalFormats;
registerFromConfig( $config, $globalFormats );
my $err = $globalFormats->check_format_supported( $args->{metadataPrefix} );

if ($err) {

	#error is HTTP::OAI::Error with code CannotDisseminateFormat
	print "Error: " . $err->code;
	$err->message ? print ':' . $err->message . "\n" : print "\n";
	exit 1;
}

my $engine = new HTTP::OAI::DataProvider::SQLite( dbfile => $config->{dbfile} );

#
#initialize transformer
#
$engine->{transformer} = new HTTP::OAI::DataProvider::Transformer(
	nativePrefix => $config->{nativePrefix},
	locateXSL    => 'main::salsa_locateXSL',
);

#
#test if identifier exists
#

my $header = $engine->findByIdentifier( $args->{identifier} );
if ( !$header ) {
	print "Error: id does not exist\n";
	exit 1;
}
print "\ntarget metadataPrefix from command line:"
  . $args->{metadataPrefix} . "!\n";
my $result = $engine->queryRecords($args);

#
#check result
#
my @records = $result->_returnRecords;
if ( @records != 1 ) {
	warn "One result expected, but got different result (" . @records . ')';
}

#
#display/write result
#

foreach my $record (@records) {
	my $fh = STDOUT;
	if ( $opts->{o} ) {

		#'>:encoding(UTF-8)' seems to work without it
		print "Will use UTF-8 file handle for output ($opts->{o})";
		open( $fh, '>:encoding(UTF-8)', $opts->{o} ) or die $!;
	}
	print $fh $record->metadata->dom->toString;
}

=head2 registerFromConfig( $config, $globalFormats );

TODO Redundant. This code is still in Salsa_OAI.pm
=cut

sub registerFromConfig {
	my $config        = shift;
	my $globalFormats = shift;

	my %cnf;
	if ( $config->{GlobalFormats} ) {
		%cnf = %{ $config->{GlobalFormats} };
	}

	foreach my $prefix ( keys %cnf ) {

		print " Registering global format $prefix\n";
		if ( !$cnf{$prefix}{ns_uri} or !$cnf{$prefix}{ns_schema} ) {
			die "GlobalFormat $prefix in yaml configuration incomplete";
		}

		$globalFormats->register(
			ns_prefix => $prefix,
			ns_uri    => $cnf{$prefix}{ns_uri},
			ns_schema => $cnf{$prefix}{ns_schema},
		);
	}
}

#
# It has to go. But where?
#

=head2 my xslt_fn=salsa_locateXSL($prefix);

locateXSL callback expects a metadataFormat prefix and will return the full
path to the xsl which is responsible for this transformation. On failure:
returns nothing.

=cut

sub salsa_locateXSL {
	my $prefix       = shift;
	my $nativeFormat = $config->{nativePrefix};
	return $config->{XSLT_dir} . '/' . $nativeFormat . '2' . $prefix . '.xsl';
}

