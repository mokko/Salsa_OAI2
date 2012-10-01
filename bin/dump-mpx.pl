#!/usr/bin/perl
# PODNAME: dump-mpx.pl
# ABSTRACT: dump all xml from Salsa_OAI's sqlite in one big mpx file

use strict;
use warnings;

#encoding problem when dealing with data from sqlite
use Encode qw(decode encode);

use XML::LibXML;
use XML::LibXML::XPathContext;
use Carp qw/croak/;
use DBD::SQLite;
use XML::LibXSLT;
use Getopt::Std;
getopts( 'd', my $opts = {} );

sub debug;

=head1 SYNOPSIS

dump-mpx.pl [-d] output.mpx

=head1 COMMAND LINE OPTIONS

-d  	print debug info to STDOUT

=cut


my $config = {
	dbfile => '/home/maurice/projects/Salsa_OAI2/data/db',
	debug  => 0,                                            #1 = on; 2 = off
	sortXSL => '/home/maurice/projects/Salsa_OAI2/xslt/mpx-sort.x1.xsl',
};

if ( $opts->{d} ) {
	$config->{debug} = 1;
}

#
# CONFIG SANITY
#

if ( !$ARGV[0] ) {
	print "Error: Need output file to proceed\n";
	exit 1;
}

if ( -f $ARGV[0] ) {
	print "Warning: Output file exists already. Will be overwritten.\n";
}

if ( !-f $config->{dbfile} ) {
	die "Error: Dbfile not found";
}

if ( !-f $config->{sortXSL} ) {
	die "Error: Cannot find xsl: $config->{sortXSL}!";
}

my $dbh = DBI->connect( "dbi:SQLite:dbname=$config->{dbfile}", "", "" )
  or die "Cannot connect to sqlite";

#
# MAIN
#

my $sql = 'SELECT native_md FROM records';
my $sth = $dbh->prepare($sql);
$sth->execute() or croak $dbh->errstr();

my $new;
my $first;
my $root;
while ( my $aref = $sth->fetch ) {

	#load xml from every db row to doc
	my $doc = init_mpx( decode( "utf-8", $aref->[0] ) );

	#deleted records have no md!
	if ($doc) {
		#only the first time
		if ( !$first ) {
			$first = 1;

			#root document
			my @list = $doc->findnodes('/mpx:museumPlusExport');
			if ( !$list[0] ) {
				die "Cannot find root element";
			}
			$new = XML::LibXML::Document->createDocument( "1.0", "UTF-8" );

			#add root
			$root = $list[0]->cloneNode(0);    #0 not deep copy. It works!
			$new->setDocumentElement($root);
		} else {
			debug "$doc";
			my @nodes = $doc->findnodes('/mpx:museumPlusExport/mpx:*');
			foreach (@nodes) {

				#debug "\t$_";
				$root->appendChild($_);
			}
		}
	}
}

#sort in right order
debug "sort elements in alphabetical order";
my $xslt      = XML::LibXSLT->new();
my $style_doc = XML::LibXML->load_xml(
	location => $config->{sortXSL},
	no_cdata => 1
);

my $stylesheet = $xslt->parse_stylesheet($style_doc);
$new = $stylesheet->transform($new);

debug "About to write to disk: $ARGV[0]";
$new->toFile( $ARGV[0] );

#
# SUBS
#

sub init_mpx {
	my $doc = shift;
	if ( !$doc ) {
		print "Warning: init_mpx called without document\n";
		return;

		#exit 1;
	}

	my $parser = XML::LibXML->new();
	my $dom    = $parser->load_xml( string => decode( "utf-8", $doc ) );
	my $xpc    = registerNS($dom);

	#debug "mpx successfully initialized";
	return $xpc;
}

sub registerNS {
	my $doc = shift;
	my $xpc = XML::LibXML::XPathContext->new($doc);
	$xpc->registerNs( 'mpx', 'http://www.mpx.org/mpx' );
	return $xpc;
}

sub debug {
	my $msg = shift;
	if ( $config->{debug} > 0 ) {
		print $msg. "\n";
	}
}

