#!/usr/bin/perl
# PODNAME: unwrap.pl
# ABSTRACT: Unwraps the metadata inside of a OAI response (ListRecord, GetRecord)

use strict;
use warnings;
use XML::LibXML;
use XML::LibXSLT;
use FindBin;
use Cwd 'realpath';
use Getopt::Std;
getopts( 'hv', my $opts = {} );

sub verbose;


#
# General Sanity
#

my $XSL = $FindBin::Bin . '/../xslt/unwrap.xsl';
$XSL = realpath($XSL);
verbose "Looking for unwrapper at $XSL";

if ( !-f $XSL ) {
	print "Error: $XSL does not exist";
	exit 1;
}

if ( !$ARGV[0] ) {
	print "Error: You did not specify source file!\n";
	exit 1;
}

if ( !-f $ARGV[0] ) {
	print "Error: Cannot find source file\n";
	exit 1;
}

if ( !$ARGV[1] ) {
	verbose "You didnot specify output, so will be using STDOUT!";
}

#
# MAIN
#

my $xslt = XML::LibXSLT->new();
my $source = XML::LibXML->load_xml( location => $ARGV[0] );
my $style_doc =
  XML::LibXML->load_xml( location => $XSL, no_cdata => 1 );
my $stylesheet = $xslt->parse_stylesheet($style_doc);
my $result = $stylesheet->transform($source) or die "Problems!".@!;
#print "result:".$result->toString."\n";
output ($result);
exit;


#
# SUBS
#
sub output {
	my $result=shift;
	if ($ARGV[1]) {
		$result->toFile ($ARGV[1], '1') or die "Cannot write $ARGV[1]";
		#1 is a readable format, use 0 to save space
		#$stylesheet->output_file($result, $ARGV[1]) or die "Cannot write file ($ARGV[1])";
	} else {
		print $result->toString;
	}
}


sub verbose {
	my $msg = shift;
	if ($msg) {
		if ( $opts->{v} ) {
			print $msg. "\n";
		}
	}
}

__END__
=pod

=head1 NAME

unwrap.pl - Unwraps the metadata inside of a OAI response (ListRecord, GetRecord)

=head1 VERSION

version 0.019

=head1 SYNOPSIS

unwrap.pl -v input.oai.xml output.xml

=head1 FUNCTIONS

=head2 output ($result);

=head2 verbose "message";

Print message to STDOUT if script is run with -v options.

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

