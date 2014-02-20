package Salsa_OAI::Updater;

# ABSTRACT: Update store partially
# will become part of HTTP::OAI::DataProvider when I have the time for that

use strict;
use warnings;
use XML::LibXML;
#use XML::LibXML::XPathContext;    #necessary to use?
use DBI;
use Carp 'croak';
use Encode qw (from_to);
use utf8;
use Debug::Simpler 'debug';
use Salsa_OAI::Updater::SQLite;
use Moo;
with 'Salsa_OAI::Updater::XML';

=head1 SYNOPSIS

 my $updater=new Salsa_OAI::Updater (dbfile=>$dbfile);
 $updater->rmres ($mpx_file);
 $updater->upres ($mpx_file);
 $updater->upagt ($mpx_file);

=head2 Background

The digester expects mpx data in one big file and loads it into the sqlite store.
Information is stored there in one xml metadata per sammlungsobjekt. Each object 
can have multiple agents and resources associated with it.

Later in the workflow, I might need to update agents or resources.

So far I had to dump the content of the store to one big file, work on that and
re-import it back to the store. This is cumbersome and error-prone, but didn't
require writing new tools.

Now I will have this task several times and this indicates that I need a more
generic solution.

The digester already updates objects. But it requires that during the update i
not only have the current object, but also current agent and resources all in
one file.

For trivial updates this is ok. Now, I need a way to update agents and
resources separately. I assume that I overwrite existing records which have the
same id.

A true update removes outdated information, thus I also need a way to delete
resources which are no longer needed.

=head2 Towards an algorithm

Attention:
 object points to related agent:
 sammlungsobjekt/personKörperschaftRef/@id = kueId

 resource points to related object:
 multimediaobjekt/verknüpftesObjekt = objId

Update agent
 1. parse mpx file containing new agents and keep all new kueId in mind
 2. walk thru all objects in store and examine personKörperschaftRef
 3.
	update only if exportdatum is newer

=cut

has dbfile => (is=>'ro',required=>1 );
has Debug => (is=>'ro');

sub BUILD {
	my $self=shift;

	if ( !-e $self->dbfile ) {
		die 'Dbfile not found: '.$self->dbfile.'!';
	}

	if ( $self->Debug && $self->Debug gt 0 ) {
		Debug::Simpler::debug_on();
	}
	else {
		Debug::Simpler::debug_off();
	}
	$self->{store}=Salsa_OAI::Updater::SQLite->new (dbfile=>$self->dbfile);
	$self->{store}->_connectDB( $self->dbfile );
	$self->{dbh}=$self->{store}{dbh}; #dirty, but I want to get it working
	#debug "dbfile exists: $args{dbfile}";
}

=method $updater->rmres ($mume_mpx);

Remove outdated mume. Removes multimediaobject mentioned in mume_mpx from
store. rmres does not check the content of multimediaobjekt. It simply
extracts mulId from mume_mpx and removes all occurences of multimedia with
this mulId.

TODO: there might still be a unicode problem that prevents the deletion of
some of them. Unclear at the moment!

Alogorithm.

 1. parse a mume.mpx and extract all mulIds
 2. walk thru store and delete resources with these mulIds

	exportdatum is irrelevant

=cut

sub rmres {
	my $self = shift;
	my $mpx = shift or die "Need mpx!";

	#debug "mpx:$mpx";
	my $doc = XML::LibXML->new->parse_file($mpx);

	$doc = _registerNS($doc);

	my @mulId =
	  $doc->findnodes('/mpx:museumPlusExport/mpx:multimediaobjekt/@mulId');

	my %delete;    #contains unique mulIds which need to be deleted

	my $msg = "rmres: remove resources mentioned in $mpx (";
	foreach (@mulId) {
		$delete{ $_->value } = 0;
		$msg .= $_->value . ';';
	}
	debug $msg. ')';
	debug "total: " . scalar keys %delete;

	#walk thru store
	my $sql = q/SELECT identifier,native_md FROM records;/;
	my $dbh = $self->{dbh};
	my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute() or croak $dbh->errstr();

	while ( my $aref = $sth->fetch ) {
		debug @{$aref}[0];

		#xml action
		my $md = $self->_rmres_single( @{$aref}[1], \%delete );
		if ($md) {

			#debug @{$aref}[1];
			#debug "---------------";
			#debug $ret;
			debug "update store - record: @{$aref}[0]";
			$sql = qq/UPDATE records SET native_md=? WHERE / . qq/identifier=?/;
			my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
			$sth->execute( $md, @{$aref}[0] ) or croak $dbh->errstr();
		}
	}
}

=method $updater->upres ($mume_mpx);

Update resources
 1. parse a mume.mpx and extract verknüpftesObjekt
 2. open objects referred to in verknüpftesObjekt
 3. add resource to that object in store

 Update only if exportdatum is newer

 Report which objects were NOT found!

=cut

sub upres {
	my $self = shift;
	my $mpx = shift or die "Need mpx!";

	debug "update resources: read mume.mpx file and import it into store";

	#debug "mpx:$mpx";
	my $doc = XML::LibXML->new->parse_file($mpx);

	$doc = _registerNS($doc);

	#all vObj from file
	my @vObjs = $doc->findnodes( '/mpx:museumPlusExport/mpx:multimediaobjekt/'
		  . 'mpx:verknüpftesObjekt' );

	#distinct vObjs so I open each database rec only once
	my %vObjs;
	foreach my $vObj (@vObjs) {

		#debug "VVVVVVVVVV".$vObj->to_literal;
		$vObjs{ $vObj->to_literal }++;
		if ( $vObjs{ $vObj->to_literal } == 1 ) {
			debug "vObj:$vObj";
			my $md = $self->getMdfromStore($vObj);
			my $newMd = _upres_single( $vObj, $doc, $md ) if ($md);

			#update only if $md and $newMd are NOT the same
			if ( $newMd && $newMd ne $md ) {
				updateStoreMd($newMd);
			}
		}
	}
}

=method $self->upagt ($mpxFN)

	Update agent information in the store with perKör from a mpx file. Update
	only if perKör has newer exportDatum.

	Note: This requires the sammmlungsobjekt/personKörperschaftRef to have the
	correct id!

	Algorithm:
	-walk thru every sammlungsobjekt in store
	-look for personKörperschaftRef/@id
	-if file has a this perKör and the exportdatum is newer or same age
	 update this item

=cut

sub upagt {
	my $self = shift or die "Something's really wrong";
	my $file = shift or die "Need mpx!";

	debug 'update agent: Read mume.mpx file and import new '
	  . 'personKörperschaft records where they are newer';

	#debug "mpx:$mpx";
	my $doc = XML::LibXML->new->parse_file($file);

	#sql part
	my $sql = q/SELECT identifier, native_md FROM records/;
	my $dbh = $self->{dbh};
	my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute() or croak $dbh->errstr();

	#expect one or zero responses
	while ( my $aref = $sth->fetch ) {

		debug "oai-id:" . @{$aref}[0];
		my $md = _upagt_single( @{$aref}[1], $doc );

		if ($md) {
			debug " ->UPDATE ";    # . @{$aref}[0];

			$sql = qq/UPDATE records SET native_md=? WHERE identifier=?/;
			my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
			$sth->execute( $md, @{$aref}[0] ) or croak $dbh->errstr();
		}
	}
}

=method my $oaiId=$self->oaiId($objId);

Returns oaiId. Dies on failure

=cut

sub oaiId {
	my $self  = shift or die "Someting's really wrong!";
	my $objId = shift or die "need objId";

	#quick and very dirty production of oai-identifiers TODO
	#make this configurable in config.yml
	my $oaiId = "spk-berlin.de:EM-objId-$objId";

	#debug "objId->oaiId: $objid";
	return $oaiId;
}

=func $md=_upagt_single ($storeMd, $fileXpc);

	Expect the md from store and file xpc to compare.
	Compare the current store document with agent info in file.
	Update and add if necessary.

	Towards an Algorithm
	1. Read $sid=store/mpx/sammlungsobjekt/personKörperschaftRef/@id
		The people we are looking for are ONLY the ones mentioned in
		sammlungsobjekt.
	2. Read file/mpx/personKörperschaft/@kueId=$sid
		We need to see if we have any of those in the file. We can forget
		about those people who are wanted (1.), but not part of 2., so let's
		call the common elements of both sets the Wanted.
	3. In the Wanted group (or set), compare file with store
		store/mpx/personKörperschaft
		file/mpx/personKörperschaft
	   Update if
	   a) there is no person in store, but there is one in file
	   b) there is a person in store and one in file, and file exportdatum
	      is newer or the same

	STEPS
	upagt
	1 Make an Hash with kueIds in the file
		$perKorFile{$kueId}=1

	_upagt_single
	2 Walk thru store
	  for each perKorRef check if

	3

=cut

sub _upagt_single {
	my $storeMd = shift or die "No md!";
	my $fileDom = shift or die "No file!";
	my $fileXpc = _registerNS($fileDom);
	my $update  = 0;
	from_to( $storeMd, "utf8", "UTF-8" );    # extrem schwere Geburt!

	my $storeDoc = XML::LibXML->load_xml( string => $storeMd )
	  or die "Have a problem loading xml from store";
	my $storeXpc  = _registerNS($storeDoc);
	my @storeRoot = $storeXpc->findnodes('/mpx:museumPlusExport');
	my @storeSam =
	  $storeXpc->findnodes('/mpx:museumPlusExport/mpx:sammlungsobjekt');

	my @perKorRef =
	  $storeXpc->findnodes( '/mpx:museumPlusExport/mpx:sammlungsobjekt/'
		  . 'mpx:personKörperschaftRef/@id' );

	#perKorId from store's md
	foreach my $storeId (@perKorRef) {
		if ($storeId) {

			$storeId = $storeId->textContent;
			debug ' perkorRef/@id: "' . $storeId . '"';

			#check if storeXpc exists for this person
			#read exportdatum for both
			my $xpath = '/mpx:museumPlusExport/mpx:personKörperschaft'
			  . "[\@kueId = '$storeId']";
			debug '   ' . $xpath;
			my @storeAgt = $storeXpc->findnodes($xpath);
			my @fileAgt  = $fileXpc->findnodes($xpath);
			if ( scalar @storeAgt > 1 ) {
				warn "more than one Agent with kueId in store";
			}
			if ( scalar @fileAgt > 1 ) {
				warn "more than one Agent with kueId in file";
			}

			#if this agent is not in the file we do not need to continue
			if ( $fileAgt[0] ) {

				my $clone = $fileAgt[0]->cloneNode(1);
				if ( $storeAgt[0] ) {

					#import (replace) if storeDate older/equal
					debug "   perKor exists in file and store. check datum";
					my $fileDate  = $fileAgt[0]->findvalue('@exportdatum');
					my $storeDate = $storeAgt[0]->findvalue('@exportdatum');
					debug "   fileDate $fileDate";
					debug "   storeDate $storeDate";
					if ( $storeDate le $fileDate ) {
						debug "   storeDate older or equal";
						$storeRoot[0]->replaceChild( $clone, $storeAgt[0] );
						$update++;
					}
				}
				else {

					#import from file to store if perKor doesn't exist in store
					$storeRoot[0]->insertBefore( $clone, $storeSam[0] );
					debug "   store:no AND file:yes -> Insert from file!";
					$update++;
				}

			}
			else {
				debug " this perKor does not exist in file (kueId:$storeId)";
			}
		}
	}
	if ( $update > 0 ) {

		#debug "RETURN";
		return $storeDoc->toString;
	}
}

=method $updater->upObj ($mpx_file);

Work in progress.

Update sammlungsobjekte without deleting multimediaobjekte or 
personenKörperschaften.



=cut

sub _upObj {

	my $self = shift;
	my $mpx = shift or die "Need mpx!";    #INPUT document

	debug "update objects: read input file and import it into store";

	#debug "mpx:$mpx";
	my $doc = XML::LibXML->new->parse_file($mpx);
	$doc = _registerNS($doc);
	my @objIds =
	  $doc->findnodes('/mpx:museumPlusExport/mpx:sammlungsobjekt/@objId');

	#we enter here only those agents and resources come with the input doc
	#we leave it the outside world to ensure that the right res and agts
	#are part of the input document
	foreach my $objId (@objIds) {

		#query db for that specific record

		my $md = $self->getMdfromStore($objId);

		#else: insert new record
		#_insertObj($objId);
	}

}

#
# PRIVAtE SUBS
#

=method my $md=$self->_rmres_single (@{$aref}[1], \%delete);

Return native_md only if it has changed. This is called on each metadata.

=cut

sub _rmres_single {
	my $self     = shift or die "Really wrong!";
	my $md       = shift or die "No md!";
	my $del_href = shift or die "No deletes!";
	my @deletes  = keys %{$del_href};

	from_to( $md, "utf8", "UTF-8" );    # extrem schwere Geburt!
	my $doc = XML::LibXML->load_xml( string => $md );
	my $xpc = _registerNS($doc);

	my @store_mulIds =
	  $xpc->findnodes("/mpx:museumPlusExport/mpx:multimediaobjekt/\@mulId");

	my $i = 0;
	foreach my $store (@store_mulIds) {
		$store = $store->value;

		#debug " store-mulIds: $store";
		foreach my $del (@deletes) {

			#TODO: i can't use == indicating that there might still be
			#a serious unicode problem. Grh!
			if ( $del eq $store ) {
				$i++;
				debug "-->delete ";
				my @nodes =
				  $xpc->findnodes( "/mpx:museumPlusExport/mpx:multimediaobjekt"
					  . "[\@mulId = '$store']" );
				foreach my $node (@nodes) {
					$node->unbindNode();
				}
			}
		}
	}
	if ( $i > 0 ) {
		return $doc->toString();
	}
}

=func my $md=_upres_single ($objId, $doc, $md);

Gets called for each database record which needs change. Hands over the current
objId, the complete document which needs importing with multimedia objects, and
the current metadata from the respective record from the db.

This func rewrites the metadata, i.e. adds multimediaobjekt from file referring
to this record and returns it as string.

TODO: Currently, we add metadata no matter what. That means we can add multiple
multimedia records with the same mulId and we can add outdated info. We ddon't
want either of that.

What to do to avoid this?

Also we wanted to overwrite resources with respect to exportdatum

=cut

sub _upres_single {
	my $objId  = shift or die "Need objId!";
	my $impxpc = shift or die "Need doc!";
	my $md     = shift or die "Need md!";

	#debug "Enter _upres_single";

	from_to( $md, "utf8", "UTF-8" );    # extrem schwere Geburt!
	my $mddoc  = XML::LibXML->load_xml( string => $md );
	my $mdxpc  = _registerNS($mddoc);
	my @mdroot = $mdxpc->findnodes('/mpx:museumPlusExport');

	my @before;
	@before =
	  $mdxpc->findnodes('/mpx:museumPlusExport/mpx:personKörperschaft');
	if ( !$before[0] ) {
		@before =
		  $mdxpc->findnodes('/mpx:museumPlusExport/mpx:sammlungsobjekt');
	}
	warn "no root" if !$mdroot[0];      #if no md (record is deleted)

	#select multimediarecords linked with $objId
	my @new_mume =
	  $impxpc->findnodes( '/mpx:museumPlusExport/mpx:multimediaobjekt'
		  . "[mpx:verknüpftesObjekt = '$objId']" );

	if ( scalar @new_mume == 0 ) {
		die "Strange result!";          #should never happen
	}

	debug ' about to insert ' . scalar @new_mume;

	#insert resources from file into md
	foreach my $new_node (@new_mume) {

		#drop to overwrite (delete resources with same mulId)
		#check if exportdatum equal or newer

   #_updateResource ($new_node,$mdxpc)
   #sub _updateResource {
   #my $new_node =shift or die "Error!";
   #my $mdxpc=shift or die "Error!";
   #my @mdroot = $mdxpc->findnodes('/mpx:museumPlusExport');
   #my @mdsam  = $mdxpc->findnodes('/mpx:museumPlusExport/mpx:sammlungsobjekt');

		my @mulIds = $new_node->findnodes('@mulId');
		if (@mulIds) {

			foreach my $mulId (@mulIds) {
				$mulId = $mulId->value;

				my @overwrites = $mdxpc->findnodes(
					    '/mpx:museumPlusExport/mpx:multimediaobjekt'
					  . "[\@mulId = '$mulId']" );
				foreach (@overwrites) {
					debug " drop to overwrite $mulId";
					$_->unbindNode();
				}
			}
		}

		#add new one
		$mdroot[0]->insertBefore( $new_node, $before[0] );
	}
	return $mddoc->toString;
}

1;

