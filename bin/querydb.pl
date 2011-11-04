#!/usr/bin/perl
# PODNAME: querydb.pl
# ABSTRACT: Query OAI data provider db directly using xpath1

use strict;
use warnings;
use DBD::SQLite;
#encoding problem when dealing with data from sqlite
use Encode qw(from_to decode);

use Getopt::Std;
getopts( 'td', my $opts = {} );

sub debug;


#
# config (todo)
#

my $config = {
	xpath    => 0,
	debug    => 0,
	truncate => 0,

	#TODO: dbfile should come from dancer's config
	dbfile => '/home/Mengel/projects/Salsa_OAI2/data/db',
};

#
# getopt
#

if ( $opts->{d} ) {
	$config->{debug} = 1;
	debug "Debug mode on";

}

if ( $opts->{t} ) {
	debug "Truncate on. Will show only identifiers which match";
	$config->{truncate} = 1;
}

debug "Search for string in metadata: $ARGV[0]";

#
# command line options
#

if ( !$ARGV[0] ) {
	print "Error: Query missing!\n";
	exit 1;
}

#this is, of course, a stupid error in the digester
#and this is a bad work around, of course, but it is quick and works now
from_to( $ARGV[0], 'iso-8859-1', 'utf-8' );
debug "encoding problem: $ARGV[0]";

#
# MAIN
#
my $dbh = DBI->connect( "dbi:SQLite:dbname=$config->{dbfile}", "", "" )
  or die "Cannot connect to sqlite";

if ( $config->{xpath} == 0 ) {
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
		if ( $config->{truncate} == 0 ) {
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
		if ( $config->{truncate} == 0 ) {
			$aref->[1] = decode( "utf8", $aref->[1] );
			print $aref->[1] . "\n";
		}
	}
	exit 0;
}

sub debug {
	my $msg = shift;
	if ( $config->{debug} > 0 ) {
		print $msg. "\n";
	}
}


__END__
=pod

=head1 NAME

querydb.pl - Query OAI data provider db directly using xpath1

=head1 VERSION

version 0.015

=head1 SYNOPSIS

querydb.pl -t '//xpath'

//xpath is executed for every record for which has xml

=head1 OPTIONS

-t	truncated response, provide only identifier with matching xml

-d  debug

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

