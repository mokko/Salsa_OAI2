package Salsa_OAI::MPX;
BEGIN {
  $Salsa_OAI::MPX::VERSION = '0.014';
}
# ABSTRACT: MPX-specific extensions

use strict;
use warnings;
use Dancer ':syntax';
use utf8;    #for verknupftesObjekt
use XML::LibXML;
use XML::LibXML::XPathContext;


sub extractRecords {
	my $self = shift;
	my $doc  = shift;    #old document

	debug "Enter extractRecords!";

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
		#my $md = $self->_mk_md( $doc, $objId );
		my $md = $self->Salsa_OAI::MPX::_mk_md( $doc, $objId );

		#complete header including sets
		my $header = $self->Salsa_OAI::MPX::extractHeader($node);

		#debug "node:" . $node;
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


sub extractHeader {
	my $self = shift;
	my $node = shift;

	my @objIds      = $node->findnodes('@objId');
	my $id_orig     = $objIds[0]->value;
	my $id_oai      = 'spk-berlin.de:EM-objId-' . $id_orig;
	my @exportdatum = $node->findnodes('@exportdatum');
	my $exportdatum = $exportdatum[0]->value . 'Z';

	debug "  $id_oai--$exportdatum";
	my $header = new HTTP::OAI::Header(
		identifier => $id_oai,
		datestamp  => $exportdatum,

		#TODO:status=> 'deleted', #deleted or none;
	);

	( $node, $header ) = $self->Salsa_OAI::MPX::setRules( $node, $header );

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
	my @nodes = $doc->findnodes(
		qq(/mpx:museumPlusExport/mpx:sammlungsobjekt[\@objId = '$currentId']));
	my $node = $nodes[0];

	#related info: verknüpftesObjekt
	{
		my $xpath = qw (/mpx:museumPlusExport/mpx:multimediaobjekt)
		  . qq([mpx:verknüpftesObjekt = '$currentId']);

		#debug "debug XPATH $xpath\n";

		my @mume = $doc->findnodes($xpath);
		foreach my $mume (@mume) {

			#debug 'MUME' . $mume->toString . "\n";
			$root->appendChild($mume);
		}
	}

	#related info: personKörperschaft
	{
		my $node   = $self->_registerNS($node);
		my @kueIds = $node->findnodes('mpx:personKörperschaftRef/@id');

		foreach my $kueId (@kueIds) {

			my $id = $kueId->value;

			my $xpath = qw (/mpx:museumPlusExport/mpx:personKörperschaft)
			  . qq([\@kueId = '$id']);

			#debug "debug XPATH $xpath\n";

			my @perKors = $doc->findnodes($xpath);
			foreach my $perKor (@perKors) {

				#debug 'perKor' . $perKor->toString . "\n";
				$root->appendChild($perKor);
			}
		}
	}

	#attach the complete sammlungsdatensatz, there can be only one
	$root->appendChild($node);

	#should I also validate the stuff?

	#MAIN debug
	#debug "debug output\n" . $new_doc->toString;

	#wrap into dom into HTTP::OAI::Metadata
	my $md = new HTTP::OAI::Metadata( dom => $new_doc );

	return $md;
}


sub setRules {
	my $self   = shift;
	my $node   = shift;
	my $header = shift;

	#debug "Enter setRules";

	#setRules:mapping set to simple mpx rules
	$node = XML::LibXML::XPathContext->new($node);
	$node->registerNs( $self->{nativePrefix}, $self->{nativeURI} );

	#for testing the setSpec test and setSpecs in general
	#$header->setSpec('test');
	#debug "    set setSpec 'test'";

	#setSpec: MIMO
	my $objekttyp = $node->findvalue('mpx:objekttyp');
	if ($objekttyp) {

		#debug "   objekttyp: $objekttyp\n";
		if ( $objekttyp eq 'Musikinstrument' ) {
			my $setSpec = 'MIMO';
			$header->setSpec($setSpec);
			debug "    set setSpec '$setSpec'";
		}
	}

	my $sachbegriff = $node->findvalue('mpx:sachbegriff');
	if ($sachbegriff) {

		#debug "   objekttyp: $objekttyp\n";
		if ( $sachbegriff eq 'Schellackplatte' ) {
			my $setSpec = '78';
			$header->setSpec($setSpec);
			debug "    set setSpec '$setSpec'";
		}
	}
	return $node, $header;
}

#
# not sure where this should go. It is not strictly speaking mpx, but it belongs
# to transformation.


sub locateXSL {
	my $prefix       = shift;
	my $nativeFormat = config->{nativePrefix};
	$nativeFormat
	  ? return config->{XSLT_dir} . '/'
	  . $nativeFormat . '2'
	  . $prefix
	  . '.xsl'
	  : return ();
}

1;                #Salsa_OAI::MPX;

__END__
=pod

=head1 NAME

Salsa_OAI::MPX - MPX-specific extensions

=head1 VERSION

version 0.014

=head1 DESCRIPTION

This package contains everything that is specific to MPX as native format.

=head1 FUNCTIONS

=head2 my @records=extractRecords ($doc);

Expects an mpx document as dom and returns an array of HTTP::OAI::Records. Gets
called from digest_single.

Recent changes:
- was a function, became a method lately.
- DOES NOT Call setRules ANYMORE on every record to ensure OAI sets get set. It
  now leaves that to extractHeaders.

Todo: What to do on failure?

=head2 my $header=extractHeader ($node);

extractHeader is a function, not a method. It expects a XML::LibXML object.
(I am not sure which. Maybe XML::LibXML::Node) and returns a complete
HTTP::OAI::Header. (I emphasize complete, because an earlier version did not
deal with sets.) This FUNCTION gets called from extractRecord, but also from
DataProvider::$Engine::findByIdentifier

=head2 my ($node, $header) = setRules ($node, $header);

Gets called during extractRecords for every node (i.e. record) in the xml
source file to map OAI sets to simple criteria on per-node-based
rules. Returns node and header. Header can have multiple sets

=head2 my xsl_fn=locateXSL($prefix);

locateXSL callback expects a metadataFormat prefix and will return the full
path to the xsl which is responsible for this transformation. On failure:
returns nothing.

=head1 NAME

Salsa_OAI::MPX

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

