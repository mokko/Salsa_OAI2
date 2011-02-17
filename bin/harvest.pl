#!/usr/bin/perl

use HTTP::OAI;
use HTTP::OAI::Repository;
use HTTP::OAI::Headers;
use YAML::Syck qw/LoadFile/;
use strict;
use warnings;

=head1 NAME

Simple OAI Harvest script

=head1 SYNOPSIS

harvest conf.yml

	Read the configuration in conf.yml and act accordingly.

=head1 CONFIGURATION FILE

Is in yaml format. Can have the following parameters. Use with sense according
to OAI Specification Version 2

	baseURL (required): URL
	from: oai datestamp
	metadataPrefix: prefix
	output: path, if specified output will be written to file
	set: setSpec
	to: oai datestamp
	verb (required): OAI verb

=head2 Config example

	baseURL: 'http://spk.mimo-project.eu:8080/oai'
	verb: 'Identify'
	output: 'test.xml'

=cut

if ( !$ARGV[0] ) {
	print "Error: Specify config file!";
	exit 1;
}

if ( !-f $ARGV[0] ) {
	print "Error: Specified file does not exist!";
	exit 1;
}

my $config = LoadFile( $ARGV[0] ) or die "Cannot load config file";

#use Data::Dumper qw/Dumper/;
#print Dumper $config;

my @required = qw/baseURL verb/;
foreach (@required) {
	if ( !$config->{$_} ) {
		print "Configuration error in $ARGV[0]: $_ missing";
		exit 1;
	}
}

if ( $config->{verb} !~
/ListIdentifiers|ListRecords|GetRecord|Identify|ListSets|ListMetadataFormats/
  )
{
	print "Error: Verb wrong";
	exit 1;
}

my $h = HTTP::OAI::Harvester->new( 'baseURL' => $config->{baseURL} );

my $response = $h->repository(
	#$h->Identify()
	$h->ListRecords( metadataPrefix => 'oai_dc' ),
);

print $response->toDOM->toString;

#	$h->ListRecords( metadataPrefix => 'oai_dc' ),
#	handlers => { metadata => 'HTTP::OAI::Metadata::OAI_DC' }

#if ( $response->is_error ) {
#	print "Error requesting Identify:\n",
#	  $response->code . " " . $response->message, "\n";
#	exit;
#}



#my $verb=$config->{verb}
#$harvester->$verb();
#my $Id=$harvester->identify();

