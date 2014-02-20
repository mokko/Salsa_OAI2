package Salsa_OAI::Updater::SQLite;
# ABSTRACT: handle store (db, sqlite)
# belongs into HTTP::OAI::DataProvider, but I can't clean up everywhere at once

use strict;
use warnings;
use Carp 'carp', 'croak';
use Debug::Simpler 'debug';
use DBI;
use Moo; #should I use this as a role instead? Well, let's just fix it as it is...
has dbfile => (is=>'ro',required=>1 );

#use lib "$FindBin::Bin/../lib";

=head2 SYNOPSIS

	my $store=Salsa_OAI::Updater::SQLite->new (dbfile=>$dbfile);
	my $md=$store->getMd($oaiId);
	$store->update($oaiId, $md);
	$store->insert($oaiId, $md);
	$store->updateOrinsert($oaiId, $md);

=method my $store=Salsa_OAI::Updater->new (dbfile=>$dbfile);

=cut

sub BUILD {
	my $self=shift;
	Debug::Simpler::debug_on();

	$self->_connectDB; 
	$self->_initDB;
}

=method my $md=$self->getMd ($objId);

I expect that I get only one md for each $objId. getMdfromStore only ever 
returns the first existing md. 

=cut

sub getMd {
	my $self  = shift or die "Someting's really wrong!";
	my $objId = shift or return;

	debug "objId:$objId (from mpx)";
	my $sql = q/SELECT native_md FROM records WHERE identifier=?/;
	my $dbh = $self->{dbh};

	my $oaiId = $self->OAIID($objId);
	debug "oaiId: $oaiId";

	my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute($oaiId) or croak $dbh->errstr();

	#expect one or zero responses
	my $aref = $sth->fetch;
	my $md   = @{$aref}[0];
	if ( !$md ) {
		return;
	}
	return $md;
}

=method updateStoreMd ($objId, $md);

dies or croaks on failure, return 0 on success

=cut

sub update {
	my $self  = shift or carp "Something's really wrong";
	my $oaiId = shift or carp "Need oaiId to update store";
	my $md    = shift or carp "Need metadata to update store";

	#debug "updateStoreMd: md: $md";
	my $sql   = qq/UPDATE records SET native_md=? WHERE identifier=?/;
	my $dbh   = $self->{dbh};
	my $sth   = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute( $md, $oaiId ) or croak $dbh->errstr();
	return 0;
}


sub insert {
	my $self  = shift or carp "Something's really wrong";
	my $oaiId = shift or carp "Need oaiId to update store";
	my $md    = shift or carp "Need metadata to update store";

	my ($identifier, $timestamp, $status, $native_md, $setSpec);
	#to begin with: I don't even know where to get these values from
	#can I take timestamp from native_md @exportdatum?
	#can I assume status somehow? It is only deleted if it is deleted
	#native_md I definitely need...


#TODO: keep the sets in mind!
#INSERT INTO table_name VALUES (value1, value2, value3,...)
#
#INSERT INTO tableNew (col1, col2)
#  SELECT tbl1.col1, tbl2.col2
# FROM tbl1 JOIN tbl2

#BEGIN TRANSACTION;
#INSERT INTO table VALUES (1,1,1,1);
#INSERT INTO table VALUES (2,2,2,2);
#...
#COMMIT;


	my $sql   = q/INSERT INTO 
		SELECT records.identifier, records.timestamp, records.status, records.native_md, 
		sets.setSpec
		FROM records LEFT JOIN ON records.identifier = sets.identifier/;
	my $dbh   = $self->{dbh};
	my $sth   = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute( $md, $oaiId ) or croak $dbh->errstr();
	return 0;
}

sub insertOrUpdate {
	#todo;
}

=head2 $self->_connectDB($dbfile);

=cut

sub _connectDB {
	my $self = shift;

	debug 'dbfile: '.$self->dbfile;

	$self->{dbh} = DBI->connect(
		'dbi:SQLite:dbname='.$self->dbfile,
		"", "",
		{
			RaiseError     => 1,
			sqlite_unicode => 1,
		}
	) or carp "Cant connect to sqlite";
	
	#debug "DB connect successful: $self->{dbh}";
}

sub _initDB {

	#Debug "Enter _init_db";
	my $self = shift;
	my $dbh = $self->{dbh} or carp "No dbh!";

	if ( !$dbh ) {
		carp "Error: database handle missing";
	}
	$dbh->do("PRAGMA foreign_keys");
	$dbh->do("PRAGMA cache_size = 8000");    #doesn't make a big difference
	                                         #default is 2000

	my $sql = q / CREATE TABLE IF NOT EXISTS sets( 'setSpec' STRING NOT NULL,
			'identifier' TEXT NOT NULL REFERENCES records(identifier) ) /;

	#Debug $sql. "\n";
	$dbh->do($sql) or die $dbh->errstr;

	#TODO: Status not yet implemented
	$sql = q/CREATE TABLE IF NOT EXISTS records (
  		'identifier' TEXT PRIMARY KEY NOT NULL ,
  		'datestamp'  TEXT NOT NULL ,
  		'status'     INTEGER,
  		'native_md'  BLOB)/;

	# -- null or 1
	#Debug $sql. "\n";
	$dbh->do($sql) or die $dbh->errstr;
	return 1;
}


1;
