#!/usr/bin/perl
# PODNAME: extract.pl
# ABSTRACT: extracts a single record or a named set of records from the data store

use HTTP::OAI;
use HTTP::OAI::Repository 'validate_request';
use HTTP::OAI::Metadata;
use HTTP::OAI::DataProvider;
#use lib "$FindBin::Bin/../lib";
use Pod::Usage;
use Salsa_OAI::Util;
use Getopt::Std;

getopts( 'o:hv', my $opts = {} );
pod2usage() if ( $opts->{h} );

sub verbose;    #predeclare
sub output;

=head1 SYNOPSIS

   extract.pl identifier_required metadataPrefix_required [set_optional]
 
   extract.pl -o output.xml 538 lido set
   transform.pl -h
	Get usage summary, for more try 'perldoc transform.pl'

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

=cut

if ( $opts->{h} ) {
	print "Usage example: extract.pl -o output.xml 538 lido\n";
	print "See 'perldoc extract.pl' for more\n";
	exit 0;
}

#
# Dancer Config
#

my $config=Salsa_OAI::Util::loadConfig();
$config=Salsa_OAI::Util::configSanity($config);

#use Data::Dumper qw/Dumper/;
#print Dumper config;

#
# CONFIGURATION
#

#from commandline

if ( !$ARGV[0] ) {
	print "Error: Need identifier!\n";

	#$config->{id}=$ARGV[0];
	exit 1;
}
if ( !$ARGV[1] ) {
	print "Error: Need target metadata prefix!\n";

	#$config->{target}=$ARGV[1];
	exit 1;
}

verbose "\nCommand line input:";
my $params = { verb => 'GetRecord' };
if ( $ARGV[0] =~ /\d+/ ) {
	$ARGV[0] = 'spk-berlin.de:EM-objId-' . $ARGV[0];
	verbose "   identifier ='$ARGV[0]'";
	$params->{identifier} = $ARGV[0];
}

if ( $ARGV[1] ) {
	verbose "   metadataPrefix='$ARGV[1]'";
	$params->{metadataPrefix} = $ARGV[1];
}

if ( $ARGV[2] ) {
	verbose "   set='$ARGV[2]'";
	$params->{Set}  = $ARGV[2];
	$params->{verb} = 'ListRecords';
}

if ( $opts->{o} ) {
	verbose "Will print to file handle using UTF-8 for output ($opts->{o})\n";
	if ( -f $opts->{o} ) {
		verbose '   Overwriting ' . $opts->{o};
		unlink $opts->{o};
	}
}

verbose '   verb: ' . $params->{verb};

#
# MAIN
#

my $provider = HTTP::OAI::DataProvider->new($config);

if ( validate_request( %{$params} ) ) {
	output $provider->err2XML( validate_request( %{$params} ) );
	exit 1;
}

verbose '   request validates';

{
	no strict "refs";
	my $verb = $params->{verb};
	output $provider->$verb( %{$params} );
}

exit 0;

##
## SUBS
##

=func verbose "message";

Print message to STDOUT if script is run with -v options.

=cut

sub verbose {
	my $msg = shift;
	if ($msg) {
		if ( $opts->{v} ) {
			print $msg. "\n";
		}
	}
}

=func output $string;

Print $string either to STDOUT or to filehandle provided by -o commandline
option.

=cut

sub output {
	my $output = shift;
	if ($output) {

		#encoding terror
		utf8::encode($output);

		if ( $opts->{o} ) {

			#'>:encoding(UTF-8)' seems to work without it
			open( my $fh, '>>', $opts->{o} ) or die $!;
			print $fh $output;

			#close file automatically if this script ends
		}
		else {
			print $output."\n";
		}
	}
}

#=func debug
#Overwrite Dancer's debug if you like
#=cut
#sub debug {
#	print "Get Here";
#if ( defined(&Dancer::Logger::debug) ) {
#	goto &Dancer::Logger::debug;
#} else {
#	foreach (@_) {
#		print "$_\n";
#	};
#}
#}
