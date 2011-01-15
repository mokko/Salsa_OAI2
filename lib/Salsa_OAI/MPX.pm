package Salsa_OAI::MPX;

use strict;
use warnings;
use Dancer::CommandLine qw/Debug Warning/;
use utf8;    #for verknupftesObjekt
use XML::LibXML;
use XML::LibXML::XPathContext;

=head1 NAME

Salsa_OAI::MPX

=head1 DESCRIPTION

This package contains everything that is specific to MPX as native format.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 FUNCTIONS

=head2 my @records=extractRecords ($doc);

Expects an mpx document as dom and returns an array of HTTP::OAI::Records.
Calls setRules on every record to ensure application OAI sets. Gets called from
digest_single at the moment.

Todo: What to do on failure?

Todo: Should be in Salsa_OAI

=cut

sub extractRecords {
	my $self = shift;
	my $doc  = shift;    #old document

	Debug "Enter extractRecords ($doc)";

	if ( !$doc ) {
		die "Error: No doc";
	}

	my @nodes = $doc->findnodes('/mpx:museumPlusExport/mpx:sammlungsobjekt');

	my $counter = 0;
	foreach my $node (@nodes) {

		#there can be only one objId
		my @objIds = $node->findnodes('@objId');
		my $objId  = $objIds[0]->value;

		#because xpath issues make md before header
		my $md = $self->Salsa_OAI::Mapping::_mk_md( $doc, $objId );

		#header stuff except sets
		my $header = _extractHeader($node);

		#setRules:mapping set to simple mpx rules
		$node = XML::LibXML::XPathContext->new($node);
		$node->registerNs( $self->{ns_prefix}, $self->{ns_uri} );

		( $node, $header ) = setRules( $node, $header );

		Debug "node:" . $node;
		my $record = new HTTP::OAI::Record(
			header   => $header,
			metadata => $md,
		);

		return $record;
	}
}

#includes the logic of how to extract OAI header information from the node
#expects libxml node (sammlungsobjekt) and returns HTTP::OAI::Header
#is called by extractRecord
sub _extractHeader {
	my $node = shift;

	my @objIds      = $node->findnodes('@objId');
	my $id_orig     = $objIds[0]->value;
	my $id_oai      = 'spk-berlin.de:EM-objId-' . $id_orig;
	my @exportdatum = $node->findnodes('@exportdatum');
	my $exportdatum = $exportdatum[0]->value . 'Z';

	Debug "  $id_oai--$exportdatum";
	my $header = new HTTP::OAI::Header(
		identifier => $id_oai,
		datestamp  => $exportdatum,

		#TODO:status=> 'deleted', #deleted or none;
	);

	#Debug 'NNNode:' . $node->toString;

	return $header;

}

#expects the whole mpx/xml document as dom and the current id (objId), returns
#metadata for one object including related data (todo) as HTTP::OAI::Metadata
#object
sub _mk_md {
	my $self      = shift;
	my $doc       = shift;    #original doc, a potentially big mpx/xml document
	my $currentId = shift;

	#get root element from original doc
	#speed is not mission critical since this is part of the digester
	#so I don't have to cache this operation
	my @list = $doc->findnodes('/mpx:museumPlusExport');
	if ( !$list[0] ) {
		die "Cannot find root element";
	}

	#make new doc
	my $new_doc = XML::LibXML::Document->createDocument( "1.0", "UTF-8" );

	#add root
	my $root = $list[0]->cloneNode(0);    #0 not deep. It works!
	$new_doc->setDocumentElement($root);

	#get current node
	my @nodes =
	  $doc->findnodes(
		qq(/mpx:museumPlusExport/mpx:sammlungsobjekt[\@objId = '$currentId']));
	my $node = $nodes[0];

	#related info: verknüpftesObjekt
	{
		my $xpath =
		  qw (/mpx:museumPlusExport/mpx:multimediaobjekt)
		  . qq([mpx:verknüpftesObjekt = '$currentId']);

		#Debug "DEBUG XPATH $xpath\n";

		my @mume = $doc->findnodes($xpath);
		foreach my $mume (@mume) {

			#Debug 'MUME' . $mume->toString . "\n";
			$root->appendChild($mume);
		}
	}

	#related info: personKörperschaft
	{
		my $node   = $self->_registerNS($node);
		my @kueIds = $node->findnodes('mpx:personKörperschaftRef/@id');

		foreach my $kueId (@kueIds) {

			my $id = $kueId->value;

			my $xpath =
			  qw (/mpx:museumPlusExport/mpx:personKörperschaft)
			  . qq([\@kueId = '$id']);

			#Debug "DEBUG XPATH $xpath\n";

			my @perKors = $doc->findnodes($xpath);
			foreach my $perKor (@perKors) {

				#Debug 'perKor' . $perKor->toString . "\n";
				$root->appendChild($perKor);
			}
		}
	}

	#attach the complete sammlungsdatensatz, there can be only one
	$root->appendChild($node);

	#should I also validate the stuff?

	#MAIN DEBUG
	#Debug "Debug output\n" . $new_doc->toString;

	#wrap into dom into HTTP::OAI::Metadata
	my $md = new HTTP::OAI::Metadata( dom => $new_doc );

	return $md;
}

=head2 $node=setRules ($node);

Gets called during extractRecords for every node (i.e. record) in the xml
source file to map OAI sets to simple criteria on per-node-based
rules.

Todo: Should be in Salsa_OAI

=cut

sub setRules {
	my $node   = shift;
	my $header = shift;

	Debug "Enter setRules";

	#setSpec: MIMO
	my $objekttyp = $node->findvalue('mpx:objekttyp');
	if ($objekttyp) {

		#Debug "   objekttyp: $objekttyp\n";
		if ( $objekttyp eq 'Musikinstrument' ) {
			my $setSpec='MIMO';
			$header->setSpec($setSpec);
			Debug "    set setSpec '$setSpec'";
		}
	}

	return $node, $header;
}

1; #Salsa_OAI::MPX;
