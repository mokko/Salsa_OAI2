package Salsa_OAI::Transformer;
BEGIN {
  $Salsa_OAI::Transformer::VERSION = '0.019';
}

# ABSTRACT: Apply an XSLT 1 to each item in the store

use XML::LibXML;
use XML::LibXML::XPathContext;
use XML::LibXSLT;
use DBI;
use Encode qw (from_to);
use utf8;

our $verbose = 0;    #default value
sub verbose;



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

	if ( $args{plan} && $args{plan} > 0 ) {
		verbose "Planning mode on.";
		$self->{plan} = 1;
	}

	bless $self, $class;
	$self->_connectDB( $args{dbfile} );

	#verbose "dbfile exists: $args{dbfile}";
	return $self;
}

sub run {
	my $self   = shift or die "Error!";
	my $xsltFN = shift or die "Error!";

	#should I assume that existance has already be tested?
	if ( !-f $xsltFN ) {
		die "$xsltFN NOT FOUND!";
	}

	#prepare XSLT
	my $xslt = XML::LibXSLT->new();
	my $style_doc = XML::LibXML->load_xml( location => $xsltFN, no_cdata => 1 );
	my $stylesheet = $xslt->parse_stylesheet($style_doc);

	#walk thru store (sql part)
	my $sql = q/SELECT identifier, native_md FROM records/;
	my $dbh = $self->{dbh};
	my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
	$sth->execute() or croak $dbh->errstr();

	#expect one or zero responses
	while ( my $aref = $sth->fetch ) {
		verbose "oai-id:" . @{$aref}[0];

		#there can be items in the store without md!
		my $newMd;
		if ( @{$aref}[1] ) {
			$newMd = _transform( @{$aref}[1], $stylesheet );
		}

		if ( @{$aref}[1] eq $newMd ) {
			verbose "old and new md are identifcal";
		} else {
			if ( !$self->{plan} ) {
				verbose " ->UPDATE ";    # . @{$aref}[0];
				$sql = qq/UPDATE records SET native_md=? WHERE identifier=?/;
				my $sth = $dbh->prepare($sql) or croak $dbh->errstr();
				$sth->execute( $newMd, @{$aref}[0] ) or croak $dbh->errstr();
			} else {
				verbose "PLANNING MODE: SHOW ONLY";
				print $newMd."\n\n";
			}
		}
	}
}

sub _transform {
	my $storeMd    = shift or die "Error!";
	my $stylesheet = shift or die "Error!";

	from_to( $storeMd, "utf8", "UTF-8" );    # extrem schwere Geburt!
	my $storeDoc = XML::LibXML->load_xml( string => $storeMd )
	  or die "Have a problem loading xml from store";
	my $results = $stylesheet->transform($storeDoc);
	return $results->toString();
}

#
# UTILITY FUNCTIONS
#


sub verbose {
	my $msg = shift or return;
	print "$msg\n" if $verbose gt 0;
}

#
# PRIVATE SUBS
#


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

1;

__END__
=pod

=head1 NAME

Salsa_OAI::Transformer - Apply an XSLT 1 to each item in the store

=head1 VERSION

version 0.019

=head1 SYNOPSIS

	my $transformer = new Salsa_OAI::Transformer (
		dbfile=>'path/to/dbfile',
		verbose=>1,
		plan=>1,
	);

	$transformer->run($xslt_FN);

=head1 METHODS

=head2 my $transformer = new Salsa_OAI::Transformer (%opts);

TODO: This is a exact duplicate of the new from Updater. I should not duplicate
code like that. Should inherit it.

=head2 my $md=$self->_connectDB ($dbfileFN);

Return native_md only if it has changed. This is called on each metadata.

TODO: This is a exact duplicate of the new from Updater. I should not duplicate
code like that. Should inherit it.

=head1 FUNCTIONS

=head2 verbose "bla";

Outputs to STDOUT in case verbose is activated.

TODO: Should be inherited

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

