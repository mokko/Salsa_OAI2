#!/usr/bin/perl
# PODNAME: transform.pl
# ABSTRACT: apply a transformation to a record from the data store

use FindBin;
use Cwd 'realpath';
use Dancer ':syntax';
use HTTP::OAI;
use HTTP::OAI::Repository 'validate_request';
use HTTP::OAI::Metadata;
use HTTP::OAI::DataProvider;
use lib "$FindBin::Bin/../lib";
use Pod::Usage;
use Salsa_OAI::MPX;
use Getopt::Std;

getopts( 'o:hv', my $opts = {} );
pod2usage() if ($opts->{h});

sub verbose;    #predeclare
sub output;

=head1 SYNOPSIS

   transform.pl -o output.xml 538 lido
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

=head1 NOTES / TODO
=cut


if ( $opts->{h} ) {
	print "Usage example: transform.pl -o output.xml 538 lido\n";
	print "See 'perldoc transform.pl' for more\n";
	exit 0;
}

#
# Dancer Config
#

#correct bug in current dancer
Dancer::Config::setting( 'appdir', realpath("$FindBin::Bin/..") );
Dancer::Config::load();
config->{environment}='production'; #also makes debug silent
#print 'appdir'.Dancer::Config::setting('appdir')."\n";
#print 'conffile'.Dancer::Config::conffile()."\n";

#use Data::Dumper qw/Dumper/;
#print Dumper config;
#verbose "here";
#exit;

#
# CONFIGURATION
#

#not ideal to have the path here
#print "dbfile" . config->{dbfile} . "\n";
#print "chunkCacheMaxSize: " . config->{chunkCacheMaxSize} . "\n";

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

verbose "\nCommand line input:";
my $params = {
	verb => 'GetRecord'
};
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
	$params->{Set} = $ARGV[2];
	$params->{verb} = 'ListRecords';
}

if ( $opts->{o} ) {
	verbose "Will print to file handle using UTF-8 for output ($opts->{o})\n";
	if (-f $opts->{o}) {
		verbose '   Overwriting '.$opts->{o};
		unlink $opts->{o};
	}
}

verbose '   verb: '.$params->{verb};

#
# MAIN
#

my $provider = HTTP::OAI::DataProvider->new(config);

if ( validate_request( %{$params} ) ) {
	output $provider->err2XML( validate_request( %{$params} ) );
	exit 1;
}

verbose '   request validates';

{
	no strict "refs";
	my $verb = $params->{verb};
	output $provider->$verb( config->{baseURL}, %{$params} );
}

exit 0;

=head1 INTERNAL METHODS AND FUNCTIONS

Documented here only for my own good

=head2 verbose "message";

Print message to STDOUT if script is run with -v options.

=cut

sub verbose {
	my $msg = shift;
	if ($msg) {
		if ( $opts->{v} ) {
			print $msg."\n";
		}
	}
}

=head2 output $string;

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
		} else {
			print $output;
		}
	}
}

=head2 debug

Overwrite Dancer's debug if you like

=cut

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



