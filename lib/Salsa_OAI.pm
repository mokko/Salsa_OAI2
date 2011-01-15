package Salsa_OAI;
use Dancer ':syntax';
use Dancer::CommandLine qw/Debug Warning/;
use HTTP::OAI;
use Carp qw/carp croak/;
use lib '/home/Mengel/projects/HTTP-OAI-DataProvider/lib';
use HTTP::OAI::DataProvider::SQLite;
use HTTP::OAI::DataProvider;

#necessary?
use HTTP::OAI::Repository qw/validate_request/;

#only for debugging
use Data::Dumper qw/Dumper/;

our $provider = init_dp();    #do this when starting the webapp
our $VERSION  = '0.2';        #sqlite

=head1 NAME

Salsa_OAI - Simple OAI data provider based on Dancer

=head1 SYNOPSIS

This is a small webapp which acts as a OAI data provider based on
HTTP::OAI::DataProvider::Simple and Tim Brody's HTTP::OAI.

=head1 FEATURES

This data provider is just one notch up from a static repository:
- no database, instead header information is parsed to memory
- metadata format freedom: on the fly conversations from native format to
  whatever external format you supply an XSLT transformation for, see below.
- easy to maintain since simple
- deployment freedom with dancer, see Dancer::Deployment
- OAI-PMH Protocol version 2.0
- Sets: basically work, but not set hierarchies
- compression. If deployed right, e.g. with PLACK::Middleware::Deflate should
  take care of that.

=head1 NOT SUPPORTED
- streaming. Currently request has to be finished to start transmit.
- Resumption tokens
- Deleted Headers

Metadata Freedom: Salsa_OAI is agnostic concerning its metadata formats.
Use XSLT 1.0 to tranform your native format in whatever you like.

=head1 SEE ALSO

- Dancer at cpan or perldancer.org.
- Some ideas concerning inheritance and abstracion derived from OCLC's OAIcat.
- HTTP::OAI
- HTTP::OAI::DataProvider

=cut

#
# THE ONLY ROUTE
#

any [ 'get', 'post' ] => '/oai' => sub {
	my $ret;    # avoid perl's magic returns

	if ( my $verb = params->{verb} ) {

		#wd be nicer if this wd be part DataProvider
		my $error = validate_request(params);

		if ($error) {
			return err2XML_FN($error);
		}

		no strict "refs";
		$ret = $provider->$verb( params() );
		use strict "refs";

	} else {
		$ret = welcome();
	}
	warning "This dance is over. How long did it take?";
	return $ret;
};
dance;
true;

sub welcome {
	content_type 'text/html';
	send_file 'index.htm';
}

sub salsa_Identify {
	Debug " Enter salsa_Identify ";

	#
	# Metadata handling
	#

	#take info from config
	#I should complain intelligble when info not there

	foreach my $test (
		qw/repositoryName adminEmail deletedRecord
		granularity/
	  )
	{
		if ( !config->{"oai_$test"} ) {

			#should not just be a debug
			die "oai_$test setting in Dancer's config missing !";
		}
	}

	my $early = '0001-01-01';
	if ( config->{oai_earliestDatestamp} ) {
		$early = config->{oai_earliestDatestamp};
	}

	#TODO: I could do an sql to determine the earliest date
	#SELECT MIN (datestamp) FROM records;

	#obligatory
	my $obj = new HTTP::OAI::Identify(
		adminEmail => config->{oai_adminEmail},

		#take baseURL from dancer
		baseURL           => uri_for( request->path ),
		deletedRecord     => config->{oai_deletedRecord},
		granularity       => config->{oai_granularity},
		repositoryName    => config->{oai_repositoryName},
		earliestDatestamp => $early,
	  )
	  or return "Cannot create new HTTP::OAI::Identify";

	return $obj;

}

=head2 err2XML_FN

FN indicates that this is a function, not a method.

Fake a DataProvider object and pass error message(s) to
HTTP::OAI::DataProvider::Simple. Return error msg from there.
Returns nothing (fails) if given nothing.

=cut

sub err2XML_FN {
	my $self = new HTTP::OAI::DataProvider::Simple( xslt => config->{XSLT} );
	if (@_) {
		return $self->err2XML(@_);
	}
}

=head2 $provider=init_dp();

Initialize the data provider with settings either from Dancer's config
if classic configuration information or from this file (callbacks).

=cut

sub init_dp {

	#if ( !config->{path} ) {
	#	croak "I need a path in dancer config, e.g. '/oai'";
	#}

	Debug " data provider needs to be initialized ONCE ";

	#step 1 set up callbacks (mostly mapping related)
	my $provider = HTTP::OAI::DataProvider->new(
		Identify   => 'Salsa_OAI::salsa_Identify',
		locateXSL  => 'Salsa_OAI::salsa_locateXSL',
		setLibrary => 'Salsa_OAI::salsa_setLibrary',
		xslt       => config->{XSLT},
		nativeFormatPrefix => 'mpx',    #not used at the moment
		                                #for listRecord disk cache
	);

	#step 2: init global metadata formats from Dancer config
	my %cnf;
	if ( config->{GlobalFormats} ) {
		%cnf = %{ config->{GlobalFormats} };
	}

	my $globalFormats = new HTTP::OAI::DataProvider::GlobalFormats;

	foreach my $prefix ( keys %cnf ) {
		debug " Registering global format $prefix";
		if ( !$cnf{$prefix}{ns_uri} or !$cnf{$prefix}{ns_schema} ) {
			die "GlobalFormat $prefix in yaml configuration incomplete";
		}

		$globalFormats->register(
			ns_prefix => $prefix,
			ns_uri    => $cnf{$prefix}{ns_uri},
			ns_schema => $cnf{$prefix}{ns_schema},
		);

	}

	#I am cheating here somewhat
	$provider->{globalFormats} = $globalFormats;

	$provider->{engine} =
	  new HTTP::OAI::DataProvider::SQLite( dbfile => config->{dbfile} );

	#do I need to provide ns_uri etc.?

	#debug "data provider initialized!";
	return $provider;
}

=head2 my xslt_fn=salsa_locateXSL($prefix);

locateXSL callback expects a metadataFormat prefix and will return the full
path to the xsl which is responsible for this transformation. On failure:
returns nothing.

=cut

sub salsa_locateXSL {
	my $prefix       = shift;
	my $nativeFormat = 'mpx';
	return config->{XSLT_dir} . '/' . $nativeFormat . '2' . $prefix . '.xsl';
}

=head2 my $library=salsa_setLibrary();

Reads the setLibrary from dancer's config file. setNames and setDescriptions
are not stored with OAI headers, but instead in the setLibrary.
HTTP::OAI::DataProvider::SetLibrary associates setSpecs with setNames
and setDescriptions. This callback parses the config file for the setLibrary
info and returns a HTTP::OAI::ListSets object which includes one or more
HTTP::OAI::Set objects.

On failure, should return nothing.

=cut

sub salsa_setLibrary {

	#Debug "Enter salsa_setLibrary";
	my $setLibrary = config->{setLibrary};

	if ( %{$setLibrary} ) {
		my $listSets = new HTTP::OAI::ListSets;

		foreach my $setSpec ( keys %{$setLibrary} ) {

			my $s = new HTTP::OAI::Set;
			$s->setSpec($setSpec);
			$s->setName( $setLibrary->{$setSpec}->{setName} );

			#Debug "setSpec: $setSpec";
			#Debug "setName: " . $setLibrary->{$setSpec}->{setName};

			if ( $setLibrary->{$setSpec}->{setDescription} ) {

				foreach
				  my $desc ( @{ $setLibrary->{$setSpec}->{setDescription} } )
				{

					#not sure if the if is necessary, but maybe there cd be an
					#empty array element. Who knows?

					my $dom = XML::LibXML->load_xml( string => $desc );
					$s->setDescription(
						new HTTP::OAI::Metadata( dom => $dom ) );
				}
			}
			$listSets->set($s);
		}
		return $listSets;
		warn "no setLibrary found in Dancer's config file";

		#return empty-handed and fail
	}
}

#
# sqlite mapping - not sure if it deserves its own pacakge!?
#


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
		my $md = $self->main::_mk_md( $doc, $objId );

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

	#$Debug = 0;
	Debug "Enter setRules";

	#setSpec: MIMO
	my $objekttyp = $node->findvalue('mpx:objekttyp');
	if ($objekttyp) {

		#Debug "   objekttyp: $objekttyp\n";
		if ( $objekttyp eq 'Musikinstrument' ) {
			$header->setSpec('MIMO');
			Debug "    set setSpec MIMO";
		}
	}

	return $node, $header;
}
