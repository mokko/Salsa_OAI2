package Salsa_OAI::Updater;

# ABSTRACT: Update store partially

use strict;
use warnings;
use XML::LibXML;
use XML::LibXML::XPathContext;
use DBI;
use Encode qw (from_to);
use Encode::Guess;

our $verbose = 0;    #default value
sub verbose;

=head1 SYNOPSIS

 my $updater=new Salsa_OAI::Updater (dbfile=>$dbfile, verbose=>1);
 $updater->rmres ($mpx_file);
 $updater->upres ($mpx_file);
 $updater->upagt ($mpx_file);

=head2 Background

The digester expects mpx data in one big file and loads it into the sqlite store.
Information is stored there in one xml metadata. Each object can have multiple
agents and resources associated with it.

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
resources with outdated.

=head2 Towards an algorithm

Attention:
 object points to related agent:
 sammlungsobjekt/personKörperschaftRef/@id = kueId

 resource points to related object:
 multimediaobjekt/verknüpftesObjekt = objId

Update resources
 1. parse a mume.mpx and extract verknüpftesObjekt
 2. walk thru objects referred to in verknüpftesObjekt
 3. add resource to that object in store

	update only if exportdatum is newer

Update agent
 1. parse mpx file containing new agents and keep all new kueId in mind
 2. walk thru all objects in store and examine personKörperschaftRef
 3.
	update only if exportdatum is newer

=cut

sub new {
	my $class = shift;
	my %args  = @_;

	my $self = {};

	if ( !$args{dbfile} ) {
		die "Dbfile not found!";
	}

	if ( !-e $args{dbfile} ) {
		die "Dbfile not found: $args{dbfile}!";
	}

	if ( $args{verbose} ) {

		#overwrites default
		$verbose = $args{verbose} = 1 if $args{verbose} gt 0;
	}

	bless $self, $class;
	$self->_connectDB( $args{dbfile} );

	#verbose "dbfile exists: $args{dbfile}";
	return $self;
}

=method $updater->rmres ($mume_mpx);

Remove outdated mume. Removes those which are mentioned in mume_mpx.

 1. parse a mume.mpx and extract all mulIds
 2. walk thru store and delete resources with these mulIds

	exportdatum is irrelevant

=cut

sub rmres {
	my $self = shift;
	my $mpx = shift or die "Need mpx!";

	#verbose "mpx:$mpx";
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
	verbose $msg. ')';
	verbose "total: " . scalar keys %delete;

	#walk thru store
	my $sql = q/SELECT identifier,native_md FROM records;/;
	my $dbh = $self->{dbh};
	my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute() or croak $dbh->errstr();

	while ( my $aref = $sth->fetch ) {
		verbose @{$aref}[0];

		#xml action
		my $md = $self->_rmres_single( @{$aref}[1], \%delete );
		if ($md) {
			#verbose @{$aref}[1];
			#verbose "---------------";
			#verbose $ret;
			verbose "update store - record: @{$aref}[0]";
			$sql = qq/UPDATE records SET native_md=? WHERE /
			  . qq/identifier=?/;
			my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
			$sth->execute($md,@{$aref}[0]) or croak $dbh->errstr();
		}
	}
}

sub upres {
	print "todo\n";
}

sub upagt {
	print "todo\n";
}

sub verbose {
	my $msg = shift or return;
	print "$msg\n" if $verbose gt 0;
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

		#verbose " store-mulIds: $store";
		foreach my $del (@deletes) {
			#TODO: i can't use == indicating that there might still be
			#a serious unicode problem. Grh!
			if ( $del eq $store ) {
				$i++;
				verbose "-->delete ";
				my @nodes =
				  $xpc->findnodes( "/mpx:museumPlusExport/mpx:multimediaobjekt"
					  . "[\@mulId = $store]" );
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

sub _connectDB {
	my $self = shift;
	my $dbfile = shift or die "Need dbfile!";

	$self->{dbh} = DBI->connect(
		"dbi:SQLite:dbname=$dbfile",
		"", "",
		{
			RaiseError     => 1,
			sqlite_unicode => 1,
		}
	) or die "Cant connect to sqlite";

	#verbose "DB connect successful: $self->{dbh}";
}

=func $doc=_registerNS ($doc);

=cut

sub _registerNS {
	my $doc = shift or die "Can't registerNS";
	my $xpc = XML::LibXML::XPathContext->new($doc);

	#should configurable, of course $self->{nativePrefix}, $self->{nativeURI}
	$xpc->registerNs( 'mpx', 'http://www.mpx.org/mpx' );

	return $xpc;
}
1;
