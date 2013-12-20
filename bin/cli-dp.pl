#!/usr/bin/perl
#PODNAME: cli-dp.pl
#ABSTRACT: command line data provider for Salsa_OAI

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use HTTP::OAI;
use HTTP::Tiny;

our %opts;
sub verbose;

=head1 DESCRIPTION

A simple command line interface to Salsa_OAI to execute verbs 
for testing and debugging. 

N.B. CURRENTLY RESUMPTION (TOKENS) NOT SUPPORTED.

=head1 SYNOPSIS

	#OAI verbs and paramters
	cli-dp.pl --host --verb Identify
	cli-dp.pl --verb GetRecord --identifier 12342 --metadataPrefix oai_dc

	#default host is http:://localhost:3000/oai

	#other arguments
	--verbose #more 
	--config '/path/to/config.pl' [optional]
	
	If --config is not specified, this script looks for config.yml in the 
	module's main dir. 

=head1 INTERNAL INTERFACE

Normally, you should never need any of the following functions.

=cut


my %params   = getOpt();                     #from command line
executeVerb(%params);
exit;

#
# SUBS
#

=func my %params=getOpt();
=cut

sub getOpt {
	$opts{host} = 'http://localhost:3000/oai'; # default
	my %params;
	GetOptions(
		'config=s'          => \$opts{c},
		'help'              => \$opts{h},
		'host=s'			=> \$opts{host},
		'identifier=s'      => \$params{identifier},
		'from=s'            => \$params{from},
		'metadataPrefix=s'  => \$params{metadataPrefix},
		'resumptionToken=s' => \$params{resumptionToken},
		'set=s'             => \$params{set},
		'until=s'           => \$params{'until'},
		'verb=s'            => \$params{verb},
		'verbose'           => \$opts{v},
	);
	pod2usage(1) if ( $opts{h} );

	#cleanup the hash
	verbose "Input params";
	foreach my $key ( keys %params ) {
		if ( !$params{$key} ) {
			delete $params{$key};
		}
		else {
			verbose " $key: " . $params{$key};
		}
	}

	validateRequest(%params);
	return %params;
}

=func validateRequest
=cut

sub validateRequest {
	my %params = @_ or die "Need params!";
	if ( my @err = HTTP::OAI::Repository::validate_request_2_0(%params) ) {
		print "Input error: \n";
		foreach (@err) {
			print "\t" . $_->code . ' - ' . $_->message . "\n";
		}
		exit 1;
	}
	verbose " Input params validate";
}

=func my $response=executeVerb (%params);
=cut

sub executeVerb {
	my %params = @_ or die "Need params!";
	my $http=HTTP::Tiny->new;
	my $uri = $opts{host}.'?' . $http->www_form_urlencode(\%params);
	verbose "About to execute $uri";
	my $response = $http->get($uri);

	verbose "Failed!\n" unless $response->{success};

	verbose " response $response->{status} $response->{reason}\n";

	while ( my ( $k, $v ) = each %{ $response->{headers} } ) {
		for ( ref $v eq 'ARRAY' ? @$v : $v ) {
			verbose "\t$k: $_";
		}
	}

	print $response->{content}."\n" if length $response->{content};

	#new might die on error
	#	my $provider = new HTTP::OAI::DataProvider(%config)
	#	  or die "Cant create new object";

	#	return $provider->$verb(%params) or die "Cant execute verb!";
}

=func verbose "bla";
	prints message if $opt{v} defined
=cut

sub verbose {
	my $msg = shift or return;
	print '*' . $msg . "\n" if ( $opts{v} );
}
