#!/usr/bin/perl
# PODNAME: deleteRecord.pl
# ABSTRACT: Delete one record from Salsa_OAI's sqlite db

use strict;
use warnings;
use DBD::SQLite;
use Getopt::Std;
use Date::Manip;
use SOAP::DateTime;

getopts( 'v', my $opts = {} );

sub debug;


my $config = {

	#identifierBase is added in front of ARGV[0] if not already there
	baseIdentifier => 'spk-berlin.de:EM-objId-',

	#dbfile - instead I should read that from dancer's config file TODO
	dbfile => '/home/Mengel/projects/Salsa_OAI2/data/db',

};

if ( $opts->{v} ) {
	$config->{debug} = 1;
}

debug "Debug mode on";

if ( !$ARGV[0] ) {
	print "Error: Need identifier!\n";
	exit 1;
}

#shortcut for input
if ( $ARGV[0] !~ /^$config->{baseIdentifier}/ ) {
	$ARGV[0] = $config->{baseIdentifier} . $ARGV[0];
}

if ( !-f $config->{dbfile} ) {
	die "Error: Dbfile not found";
}

my $dbh = DBI->connect( "dbi:SQLite:dbname=$config->{dbfile}", "", "" )
  or die "Cannot connect to sqlite";

debug "Trying to delete record $ARGV[0]";

#
# MAIN
#

#UPDATE table_name
#SET column1=value, column2=value2,...
#WHERE some_column=some_value
my $sql = 'UPDATE records SET status=1, native_md=\'\', datestamp=? WHERE identifier=?';

my $time=time;
my $datestamp=ConvertDate(ParseDateString("epoch $time"));
$datestamp.='Z';
debug "datestamp: $datestamp";

#debug "SQL:$sql";
my $sth = $dbh->prepare($sql);
my $rows = $sth->execute( $datestamp, $ARGV[0] ) or croak $dbh->errstr();

debug "rows affected: $rows";

if ( $rows == 1 ) {
	my $sql = 'DELETE FROM sets WHERE identifier=?';

	#debug "SQL:$sql";
	my $sth = $dbh->prepare($sql);
	my $rows = $sth->execute( $ARGV[0] ) or croak $dbh->errstr();
	if ( $rows ne '0E0' ) {
		debug "set deleted for this record: $rows";
	}
	#exit gracefully
	exit 0;
}
debug "something went wrong";
exit 1;

#
# SUBS
#
sub debug {
	my $msg = shift;
	if ( $config->{debug} > 0 ) {
		print $msg. "\n";
	}
}


__END__
=pod

=head1 NAME

deleteRecord.pl - Delete one record from Salsa_OAI's sqlite db

=head1 VERSION

version 0.014

=head1 SYNOPSIS

deleteRecord.pl [-v] spk-berlin.de:1234

=head1 FUNCTIONS

=head2 debug "msg";

=head1 QUOTE FROM OAI 2.0 SPECIFICATION

If a repository does not keep track of deletions then such records will simply
vanish from responses and there will be no way for a harvester to discover
deletions through continued incremental harvesting. If a repository does keep
track of deletions then the datestamp of the deleted record must be the date
and time that it was deleted. Responses to GetRecord request for a deleted
record must then include a header with the attribute status="deleted", and
must not include metadata or about parts. Similarly, responses to selective
harvesting requests with set membership and date range criteria that include
deleted records must include the headers of these records. Incremental
harvesting will thus discover deletions from repositories that keep track of
them.

If a record is deleted,
-we have to change status=1,
-put the datestamp of now.
-delete native_md for that record
-delete all sets with the same identifier

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

