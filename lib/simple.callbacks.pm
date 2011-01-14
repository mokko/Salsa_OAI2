package simple::callbacks;

use strict;
use warnings;

use Carp qw/carp croak/;


=head1 HEADLINE

I just thought i could package those callbacks away that are specific to the
simple implentation.


=head2 @oaiheaders=extractHeader ($doc)

$doc is an mpx, either one record per file or multiple. @oaiheaders is an array
of HTTP::OAI::Headers which contains
 oai identifier
 datestamp
 set information
=cut

sub salsa_extractHeader {

	#TODO: Currently not tested
	#where is documentation for the interface. Should be in DP::Simple

	my $doc = shift;    # this is an mpx from xml store.
	my @result;

	croak "Error: No doc" if !$doc;

	my @nodes = $doc->findnodes('/mpx:museumPlusExport/mpx:sammlungsobjekt');

	foreach my $node (@nodes) {
		my @objIds      = $node->findnodes('@objId');
		my $id_orig     = $objIds[0]->value;
		my $id_oai      = 'spk-berlin.de:EM-objId-' . $id_orig;
		my @exportdatum = $node->findnodes('@exportdatum');
		my $exportdatum = $exportdatum[0]->value . 'Z';

		print "\t$id_oai--$exportdatum\n";
		my $header = new HTTP::OAI::Header(
			identifier => $id_oai,
			datestamp  => $exportdatum,

			#TODO:status=> 'deleted', #deleted or none;
		);

		$node = XML::LibXML::XPathContext->new($node);
		$node->registerNs( 'mpx', 'http://' );

		#$node=_registerNS ($self,$node);

		#example of mapping set to simple mpx criteria
		my $objekttyp = $node->findvalue('mpx:objekttyp');
		print "\tobjekttyp: $objekttyp\n";
		if ( $objekttyp eq 'Musikinstrument' ) {
			$header->setSpec('MIMO');
		}
		push @result, $header;
	}
	return @result;
}

=head2 my $fn=id2file ($id);

id2file callback expects an identifier ($id) and will return full path to an xml
document which contains the full metadata for this record (and no other
record).

=cut

sub salsa_id2file {

	#debug "Enter salsa_id2file"
	my $identifier = shift;    #which kind of identifier is this?

	$identifier =~ /-(\d+)$/;

	my $id_no = $1;

	#debug " $identifier -> $id_no";

	if ( !$id_no ) {
		die "Could not find a file.";
	}

	#I do NOT test whether this file exists here!

	my $abs_path = config->{xml_store} . '/objId-' . $id_no . '.mpx';

	#debug "absolute path: $identifier -> $abs_path";

	return $abs_path;
}

1;