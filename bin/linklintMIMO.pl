#!/usr/bin/perl
# PODNAME: linklintMIMO.pl
# ABSTRACT: remove freigabe if file is not online

use strict;
use warnings;
use Getopt::Std;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";    #works only under *nix, of course

use Dancer ':syntax';
use Salsa_OAI::Transformer; #????
use Cwd 'realpath';
use Encode qw(decode from_to);
use XML::LibXML;
use LWP::Simple qw(head);

getopts( 'vhp', my $opts = {} );
pod2usage() if ($opts->{h});

sub debug;

#no trailing slash
my $host="http://194.250.19.151/media/SPK";


=head1 SYNOPSIS

linklintMIMO.pl -v
linklintMIMO.pl -h

=head2 COMMAND LINE OPTIONS

=over 1

=item -h

help: this text

=item -p

plan: plan: show what would happen, don't change anything

=item -v

verbose: be more verbose

=back

=head1 DESCRIPTION

Loops thru store and checks every record in set 'MIMO'. For each record look at
every resource (multimediaobjekt). If this resource on MIMO Server in Paris
if necessary change to freigegeben=web; if resource is not on server change
freigabe to 'intern'.

=head2 TODO

=cut

Dancer::Config::setting( 'appdir', realpath("$FindBin::Bin/..") );
Dancer::Config::load();

#in case none are found;
$main::counter{id}=0;
$main::counter{updateDb}=0;
$main::counter{url}=0;

if (!$opts->{v}) {
	$opts->{v}=0;
}

#command line overwrites config.yml
if ($opts->{v}) {
	config->{debug}=1;
	debug "debug mode on";
} else {
	config->{debug}=0;
}

if ( $opts->{p} ) {
	debug "planning mode";
}

#
#
#

my $dbh = DBI->connect( 'dbi:SQLite:dbname='.config->{dbfile}, "", "" )
  or die "Cannot connect to sqlite";

my $sql = q(
	SELECT records.identifier, native_md
	FROM records LEFT JOIN sets ON records.identifier = sets.identifier
	WHERE sets.setSpec ='MIMO';
);

#debug 'debug: '.$sql;
my $sth = $dbh->prepare($sql);
$sth->execute() or croak $dbh->errstr();

while ( my $aref = $sth->fetch ) {
		print "$aref->[0]\n"; #print for progress
		$main::counter{id}++;

		if (! $aref->[1]){
			next; #for deleted records
		}
		# extrem schwere Geburt!
		my $md=$aref->[1];
		$md = decode( "UTF-8", $aref->[1] );
		from_to( $md, "utf8", "UTF-8" );
		#debug "$md\n";

		my $storeDoc = XML::LibXML->load_xml( string => $md )
		  or die "Have a problem loading xml from store";

		my $change=0;
		my $xpc=_registerNS($storeDoc);
		#debug "Dvorher:".$xpc->findvalue('mpx:museumPlusExport/mpx:multimediaobjekt/@freigabe');

		my $nlist=$xpc->find ('mpx:museumPlusExport/mpx:multimediaobjekt');
		foreach my $node ($nlist->get_nodelist) {
			my $url=mk_url ($node, $host);
			my $freigabe=$node->findvalue('@freigabe');
			#debug "  freigabe: $freigabe";
			my $exists=head($url);
			if (!$exists && $freigabe =~ /Web|web/ ) {
				debug "  url: $url";
				debug "  url does NOT exist, but freigabe is set -> unset";
				$change++;
				setFreigabe($storeDoc,$node,'intern');
			}

			if ($exists && $freigabe !~ /Web|web/ ) {
				debug "  url: $url";
				debug "  url does exist, but freigabe is unset -> set";
				$change++;
				setFreigabe($storeDoc, $node, 'Web');
			}
		}
		$xpc=_registerNS($storeDoc);
		#debug "Dnachher:".$xpc->findvalue('mpx:museumPlusExport/mpx:multimediaobjekt/@freigabe');


		if ($change>0) {
			print "  changed\n" if (config->{debug} == 0);
			updateDb ($aref->[0], $storeDoc); #save in db
		} else {
			#debug "  no change needed";
		}
}
report_results();
exit 0;

#
# SUBs
#

sub report_results {
	print $main::counter{id}." oai records processed\n";
	print $main::counter{updateDb}." changed\n";
	print $main::counter{url}." urls checked\n";
	delete $main::counter{url};
	delete $main::counter{id};
	delete $main::counter{updateDb};
	foreach my $value (keys %main::counter) {
		print "set '$value' $main::counter{$value} times\n";
	}
	exit 0;
}

sub updateDb {
	my $identifier=shift or die "Need identifier";
	my $doc=shift or die "Need doc";
	if ( $opts->{p} ) {
		debug "  planning mode, no update";
		return;
	}

	my $md=$doc->toString;
	#transform back to stupid encoding error
	from_to( $md, "UTF-8", "utf8" );
	#i should write a variant that can open both wrong and correct encoding
	debug "  updateDb";

	$sql = qq/UPDATE records SET native_md=? WHERE identifier=?/;
	my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute( $md, $identifier ) or croak $dbh->errstr();
	$main::counter{updateDb}++;
}

sub setFreigabe {
	my $doc=shift or die "Need doc";
	my $node=shift or die "Need node";
	my $value=shift or die "Need freigabe value";
	debug "  setFreigabe to '$value'";
	#debug "DDvor:".$node->findvalue('@freigabe');
	my $freigabe=$node->find('@freigabe');
	my $newFreigabe = $doc->createAttribute('freigabe', $value);
	$main::counter{$value}++;
	foreach my $node ($freigabe->get_nodelist) {
		$node->replaceNode ($newFreigabe);
	}
	#debug "DDnach:".$node->findvalue('@freigabe');
}

sub mk_url {
	my $node=shift or die "Need node";
	my $host=shift or die "Need host";

	my $mulId=$node->findvalue('@mulId');
	$node=_registerNS($node);
	my $erw=$node->find('mpx:multimediaErweiterung');
	#debug "mulId:$mulId";
	#debug "erweiterung: $erw";

	my $file=mk_fn($mulId, $erw);
	#debug "file:$file";
	return "$host/$file";
}

sub mk_fn {
	#file conversion in multiple places of the work flow,
	#very bad architecture. Instead one program should do the
	#conversion and leave the data in xml for the other processes
	#to pick up
	my $mulId=shift or die "mulId missing";
	my $erw=shift;
	if (!$erw) {
		#erweiterng can be missing if only mulId is specified
		#this is not an error
		#for records produced by mpx-rif erweiterung should exist
		#warn "erweiterung missing, assume 'jpg'";
		$erw='jpg'
	}

	$erw=lc($erw);

	#konvertierung
	if ($erw=~/tif|tiff/) {
		$erw='jpg'
	}

	#guess folder
	my $folder='';
	if ($erw=~/tif|tiff|jpg|gif/) {
		$folder="IMAGE/";
	}

	if ($erw=~/mp3|wav/) {
		$folder="AUDIO/";
	}

	if ($erw=~/mpg|mpeg|avi/) {
		$folder="VIDEO/";
	}

	return "$folder$mulId.$erw";
}


sub _registerNS {
	my $doc  = shift;

	#Debug 'Enter _registerNS';

	if ( config->{nativePrefix} ) {
		if ( !config->{native_ns_uri} ) {
			die "ns_prefix specified, but ns_uri missing";
		}

		$doc = XML::LibXML::XPathContext->new($doc);
		$doc->registerNs( config->{nativePrefix}, config->{native_ns_uri} );
	}
	return $doc;
}

sub debug {
	my $msg = shift;
	if ( config->{debug} > 0 ) {
		print $msg. "\n";
	}
}