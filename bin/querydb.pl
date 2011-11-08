#!/usr/bin/perl
# PODNAME: querydb.pl
# ABSTRACT: Query OAI data provider db directly using xpath1

use strict;
use warnings;

use FindBin;
use DBD::SQLite;
use Encode qw(from_to decode); #encoding problem when talking to sqlite
use Cwd 'realpath';
use Dancer ':syntax';

use Getopt::Std;
getopts( 'tdv', my $opts = {} );

sub debug;

=head1 SYNOPSIS

querydb.pl -t '//xpath'

//xpath is executed for every record for which has xml

=head1 OPTIONS

-t	truncated response, provide only identifier with matching xml

-d  debug

=cut



Dancer::Config::setting( 'appdir', realpath("$FindBin::Bin/..") );
Dancer::Config::load();
config->{xpath}= 0;
config->{debug}= 0;
config->{truncate}= 0;

#
# getopt and @ARGV
#

if ($opts->{v}) {
	$opts->{d}=$opts->{v};
}

if ( $opts->{d} ) {
	config->{debug} = 1;
	debug "Debug mode on";

}

if ( $opts->{t} ) {
	debug "Truncate on. Will show only identifiers which match";
	config->{truncate} = 1;
}

if ( !$ARGV[0] ) {
	print "Error: Query missing!\n";
	exit 1;
}

debug "Search for string in metadata: $ARGV[0]";


#this is, of course, a stupid error in the digester
#and this is a bad work around, of course, but it is quick and works now
from_to( $ARGV[0], 'iso-8859-1', 'utf-8' );
debug "encoding problem: $ARGV[0]";

#
# MAIN
#
my $dbh = DBI->connect( 'dbi:SQLite:dbname='.config->{dbfile}, "", "" )
  or die "Cannot connect to sqlite";

if ( config->{xpath} == 0 ) {
	fulltextSearch( $ARGV[0] );
} else {
	xpath( $ARGV[0] );
}

#
# SUBS
#

sub xpath {
	my $search = shift;

	my $sql = "SELECT identifier, native_md FROM records";
	debug $sql;

	my $sth = $dbh->prepare($sql);

	#don't know how $rows works
	#my $rows = $sth->execute() or croak $dbh->errstr();
	$sth->execute() or croak $dbh->errstr();

	#debug "$rows results";

	while ( my $aref = $sth->fetch ) {
		print $aref->[0] . "\n";

		#only print xml if truncate off
		if ( config->{truncate} == 0 ) {
			$aref->[1] = decode( "utf8", $aref->[1] );
			print $aref->[1] . "\n";
		}
	}
	exit 0;

}

sub fulltextSearch {
	my $search = shift;

	my $sql = "SELECT identifier, native_md FROM records WHERE native_md LIKE "
	  . "'%$ARGV[0]%'";
	debug $sql;
	my $sth = $dbh->prepare($sql);

	#don't know how $rows works
	#my $rows = $sth->execute() or croak $dbh->errstr();
	$sth->execute() or croak $dbh->errstr();

	#debug "$rows results";

	while ( my $aref = $sth->fetch ) {
		print $aref->[0] . "\n";

		#only print xml if truncate off
		if ( config->{truncate} == 0 ) {
			$aref->[1] = decode( "utf8", $aref->[1] );
			print $aref->[1] . "\n";
		}
	}
	exit 0;
}

sub debug {
	my $msg = shift;
	if ( config->{debug} > 0 ) {
		print $msg. "\n";
	}
}

1;
__END__

