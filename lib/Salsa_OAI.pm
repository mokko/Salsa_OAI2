# ABSTRACT: Simple OAI data provider
package Salsa_OAI;

use Dancer;
use HTTP::OAI::DataProvider;
use Salsa_OAI::Util;
use URI;            #for manual_rurl()
use XML::LibXML;    #for salsa_setLibrary();

our $prv = init_provider();    #do this when starting the webapp

=head1 SYNOPSIS

This is a small webapp which acts as a OAI data provider based on
L<HTTP::OAI::DataProvider|https://github.com/mokko/HTTP-OAI-DataProvider> and Tim Brody's L<HTTP::OAI>. It is simply since
it

=over 4

=back

* does not support all OAI features (see below)
* it's easy to configure
* it's easy to install
* it should be easy to maintain

For a list of OAI features, see L<HTTP::OAI::DataProvider|https://github.com/mokko/HTTP-OAI-DataProvider>

=head1 SEE ALSO

=over 4

=item *

L<Dancer|http://perldancer.org> or at cpan

=item *

Some ideas concerning inheritance and abstracion derived from OCLC's OAIcat.

=item *

L<HTTP::OAI>

=item *

L<HTTP::OAI::DataProvider|https://github.com/mokko/HTTP-OAI-DataProvider>

=back

=cut

#
# THE ONLY ROUTE
#

any [ 'get', 'post' ] => '/oai' => sub {
	content_type 'text/xml';

	my $verb = params->{verb} or return welcome();

	#check if verb is valid.
	$prv->validateRequest(params) or return $prv->asString( $prv->OAIerrors );
	$prv->requestURL( manual_rurl() );
	no strict "refs";
	my $response = $prv->$verb( params() );    #response for verb or error
	return $prv->asString($response);
};

hook after => sub {
	warning "This dance is over. How long did it take?";
};

dance;

##
##
##

=func $prv=init_provider();

Initialize the data provider with settings either from Dancer's config
if classic configuration information or from callbacks.

=cut

sub init_provider {

	#require conditions during start up or die
	#apply defaults, changes Dancer's config values
	my $config = Salsa_OAI::Util::configSanity();
	my $prv    = HTTP::OAI::DataProvider->new($config);

	#according to Demeter's law I should NOT access internal data
	#instead I should talk to provider's interface and hand over all
	#these values to the interface and let the provider deal with it

	debug "data provider initialized!";
	return $prv;
}

=func manual_rurl ();

Returns a version of the de facto requestURL in which host part is replaced 
by the value specified in the configuration for identify/baseURL.

If de-facto requestURL is 'http://127.0.0.1/oai?verb=Identify' and 
identify/baseURL is defined as 'http://localhost' then return valued is
'http://localhost/oai?verb=Identify'.

Background: Under the fabulous Starman server, requestURL doesn't get set 
correctly in HTTP::OAI, so that I have do it manually using this sub.

=cut

sub manual_rurl {

	my $env = request->env;

	#my $requestURL = 'http://' . $env->{'HTTP_HOST'} . $env->{'REQUEST_URI'};
	my $uri = URI->new( config->{identify}{baseURL} );
	my $requestURL =
	  'http://' . $uri->host . ':' . $uri->port . $env->{'REQUEST_URI'};
	return URI->new($requestURL)->canonical->as_string;
}

=func welcome()

Gets called from Dancer's routes to display html pages on Salsa_OAI

=cut

sub welcome {
	content_type 'text/html';
	send_file 'index.htm';
}

true;

#
# CALLBACKS
#

=Func my $library = salsa_setLibrary();

Reads the setLibrary from dancer's config file and returns it in form of a
HTTP::OAI::ListSet object (which can, of course, include one or more
HTTP::OAI::Set objects)
  .
Background: setNames and setDescriptions are not stored with OAI headers,
but instead in the setLibrary. HTTP::OAI::DataProvider::SetLibrary associates
setSpecs with setNames and setDescriptions.

=cut

sub salsa_setLibrary {

	#debug "Enter salsa_setLibrary";
	my $setLibrary = config->{setLibrary};

	if ( %{$setLibrary} ) {
		my $listSets = new HTTP::OAI::ListSets;

		foreach my $setSpec ( keys %{$setLibrary} ) {

			my $s = new HTTP::OAI::Set;
			$s->setSpec($setSpec);
			$s->setName( $setLibrary->{$setSpec}->{setName} );

			#debug "setSpec: $setSpec";
			#debug "setName: " . $setLibrary->{$setSpec}->{setName};

			if ( $setLibrary->{$setSpec}->{setDescription} ) {

				foreach
				  my $desc ( @{ $setLibrary->{$setSpec}->{setDescription} } )
				{

					#not sure if the if is necessary, but maybe there cd be an
					#empty array element. Who knows?

					my $dom = XML::LibXML->load_xml( string => $desc );
					$s->setDescription(
						new HTTP::OAI::Metadata( dom => $dom ) );
				}
			}
			$listSets->set($s);
		}
		return $listSets;
	}
	warn "no setLibrary found in Dancer's config file";

	#return empty-handed and fail
}

1;
