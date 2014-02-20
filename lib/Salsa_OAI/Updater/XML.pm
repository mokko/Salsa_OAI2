package Salsa_OAI::Updater::XML;
# ABSTRACT: libxml stuff for the Updater
# this should be in HTTP::OAI::DataProvider

use strict;
use warnings;
#use Salsa_OAI::Messages 'verbose';
use Carp 'croak', 'carp';
use XML::LibXML::XPathContext;
use Moo::Role;

$Salsa_OAI::Messages::verbose = 1;    #default value
=head2 $doc=_registerNS ($doc);

=cut

sub _registerNS {
	my $doc = shift or die "Can't registerNS";
	my $xpc = XML::LibXML::XPathContext->new($doc);

	#should configurable, of course $self->{nativePrefix}, $self->{nativeURI}
	$xpc->registerNs( 'mpx', 'http://www.mpx.org/mpx' );

	return $xpc;
}

42;