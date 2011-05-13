#!/usr/bin/perl

#a little tool that converts a two column csv into a dictionary file
#csv should
#-be in cp1252 (normal out put from excel)
#-have 2 columns (left one with M+Sachbegriff, right one with MIMO keyword)

#this test checks for uniqueness of terms Sachbegriff
#it outputs a simple xml dictionary

#-v verbose mode
#-h help gives you usage
# csv2dict.pl [-v] input.csv output.xml

use strict;
use warnings;

#use Encode qw/from_to/;
use Text::CSV;
use Getopt::Std;
use XML::Writer;
use IO::File;

sub verbose;

my $VERSION = '0.01';

my $opts = {};
getopts( 'hv', $opts );

#command line switches

if ( $opts->{h} ) {
	main::HELP_MESSAGE();
}

if ( $opts->{v} ) {
	verbose "Verbose mode on\n";
}

# command line sanity

if ( !$ARGV[0] ) {
	print "Error: Need input csv file!";
	exit 1;
}

if ( !-f $ARGV[0] ) {
	print "Error: Specified file not found!";
	exit 2;
}

if ( !$ARGV[1] ) {
	print "Error: Need output file!";
	exit 1;
}

if ( !-f $ARGV[1] ) {
	verbose "Warning: Output file exists and will be overwritten!";
}

#
# MAIN
#


my $dict = read_csv( $ARGV[0] );
my $writer = init_writer( $ARGV[1] );

#loop thru dict and write xml

my $i = 0;
foreach my $keyword ( sort keys %{$dict} ) {
	if ( $keyword =~ /\S+/ ) {
		$i++;
		$writer->startTag( 'concept', 'id', $i );
		$writer->dataElement( 'pref', $keyword );

		#weed out empty keywords
		verbose "keyword: '$keyword'";

		foreach my $sachbegriff ( sort keys %{ $dict->{$keyword} } ) {
			if ( $sachbegriff =~ /\S+/ ) {
				verbose "  sachbegriff: '$sachbegriff'";
				$writer->dataElement( 'synonym', $sachbegriff );
			}
		}
		$writer->endTag('concept');
	}
}
$writer->endTag('dictionary');
#writes to file
$writer->end();
exit 0;

#write and make sure it is utf8
#open(my $fh, '>:encoding(utf8)', "output.xml") or die $!;
#print $fh $output;
#close $fh;


#
# SUBS
#


sub HELP_MESSAGE {
	print "Usage: csv2dict.pl bla.csv bla.xml\n\n";
	print "For more info see perldoc csv2dict.pl\n";
	exit 0;
}

sub VERSION_MESSAGE {
	print "csv2dic.pl Version $VERSION\n";
	exit 0;
}

sub init_writer {
	my $output_fn = shift;

	my $dictURL = "http://www.mpx.org/dictionary";
	my $output  = new IO::File(">$ARGV[1]");

	my $writer = new XML::Writer(
		NEWLINES    => 0,
		NAMESPACES  => 1,
		PREFIX_MAP  => { $dictURL => '' },
		DATA_INDENT => 2,
		ENCODING    => 'utf-8',
		OUTPUT      => $output
	);

	$writer->xmlDecl("UTF-8");
	$writer->forceNSDecl($dictURL);
	$writer->startTag('dictionary');
	$writer->comment( 'Created by csv2dict.pl on ' . localtime() );

	return $writer;

}


sub read_csv {
	my $csv_file = shift;    #location
	my $dict     = {};
	my $csv = Text::CSV->new( { binary => 1 } )   # should set binary attribute.
	  or die "Cannot use CSV: " . Text::CSV->error_diag();

	my %unique;

	#<:encoding(utf8)
	open my $fh, "<:encoding(cp1252)", $csv_file or die "$csv_file: $!";
	while ( my $row = $csv->getline($fh) ) {

		#from_to( $row->[0], 'cp1252', 'UTF-8' );
		#from_to( $row->[1], 'cp1252', 'UTF-8' );

		if ( $row->[0] ne $row->[1] ) {
			$unique{ $row->[0] }++;

			if ( $unique{ $row->[0] } > 1 ) {

				warn "$row->[0] not unique!";

				#verbose "Left column NOT unique: $row->[0]\n";
			} else {

				#M+ sachbegriff: $row->[0]
				#MIMO keyword: $row->[1]
				#print "$row->[0]\t$row->[1]\n";

				#TODO
				#only if keyword contains something other than whitespace
				$dict->{ $row->[1] }{ $row->[0] }++;
			}
		}
	}
	$csv->eof or $csv->error_diag();
	close $fh;
	return $dict;
}

sub verbose {
	my $msg = shift;
	print $msg. "\n" if $opts->{v};
}