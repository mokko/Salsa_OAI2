#!/usr/bin/perl
# PODNAME: linklintMIMO.pl
# ABSTRACT: remove freigabe if file is not online

use strict;
use warnings;
use Getopt::Std;
use Pod::Usage;
use FindBin;
use DBI;
#use lib "$FindBin::Bin/../lib";    #works only under *nix, of course

use Dancer ':syntax';
#use Salsa_OAI::Transformer; #????
use Cwd 'realpath';
use Encode qw(decode from_to);
use XML::LibXML;

sub debug;

getopts( 'l:vh', my $opts = {} );
pod2usage() if ($opts->{h});


#
# INIT
#

Dancer::Config::setting( 'appdir', realpath("$FindBin::Bin/..") );
Dancer::Config::load();

if (!$opts->{v}) {
	config->{v}=0;
}

#command line overwrites config.yml
if ($opts->{v}) {
	config->{debug}=1;
	debug "debug mode on";
} else {
	config->{debug}=0;
}

if ($opts->{l}) {
	if ($opts->{l} !~ /^\d+$/ ) {
		print "Error: -a param is not an integer\n";
		exit 1;
	}
	config->{l}=$opts->{l};
	debug 'limit: '.$opts->{l};
}
#
# MAIN
#
readTest();
exit 0;
#
# SUBS
#

sub readTest {
	my $type=shift||'clear';
	debug "Enter readTest $type";
	my $dbh = DBI->connect( 'dbi:SQLite:dbname='.config->{dbfile}, "", "" )
  		or die "Cannot connect to sqlite";

	my $sql = q(
		SELECT records.identifier, native_md FROM records
	);
	if (config->{l}) {
		debug "LIMIT ".config->{l};
		$sql.=' LIMIT '.config->{l};
	}
	#debug $sql;


	my $sth = $dbh->prepare($sql);
	$sth->execute() or croak $dbh->errstr();

	while ( my $aref = $sth->fetch ) {
		my $identifier=$aref->[0];
		my $md=$aref->[1];
		print "$identifier\n"; #print for progress

		my $doc=loadDoc ($md, 'decode');
		#toString is supposed to return UTF-8 content!
		my $new_md=$doc->toString();

		writeDoc ($dbh,$identifier, $new_md,'clear');
		#print $md;
	}
}


sub writeDoc {
	my $dbh=shift or die "Need dbh";
	my $identifier=shift or die "Need identifier";
	my $md=shift or die "Need md";

	debug "  writeDoc";
	debug "md is utf8?".utf8::is_utf8($md);
	utf8::encode($md);
	debug "md is utf8?".utf8::is_utf8($md);

	#transform back to stupid encoding error
	#from_to( $md, "UTF-8", "utf8" );
	#i should write a variant that can open both wrong and correct encoding

	my $sql = qq/UPDATE records SET native_md=? WHERE identifier=?/;
	my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute( $md, $identifier ) or croak $dbh->errstr();
}


sub loadDoc {
	my $str=shift or die "need str!";
	my $type=shift;

	if ($type eq 'decode') {
		debug "  type: decode";
		#also encoding one too many
		#could be UTF8 flag issue

		$str = decode( "UTF-8", $str );
		from_to( $str, "utf8", "UTF-8" );
	}
	my $doc = XML::LibXML->load_xml( string => $str )
	  or die "Have a problem loading xml from store";
	return $doc;
}

sub debug {
	my $msg = shift;
	if ( config->{debug} > 0 ) {
		print $msg. "\n";
	}
}
__END__
=pod

=head1 NAME

linklintMIMO.pl - remove freigabe if file is not online

=head1 VERSION

version 0.020

=head1 SYNOPSIS

encodingTerror.pl -a 50 -v
encodingTerror.pl -h

=head2 COMMAND LINE OPTIONS

=over 1

=item -l

limit. integer. Specify number of oai records to be processed.

=item -h

=back

=head2 DESCRIPTION

HTTP::OAI::DataProvider has an encoding problem. Data is saved in sqlite in
wrong encoding. This tool is meant as diagnostic and also as a practice how to
remedy the error without having to rewrite all other parts of the data
provider.

1) iterate thru all/some oai records parsing the xml

2) rewrite xml in sqlite in new encoding

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

