package Salsa_OAI;

# ABSTRACT: Simple OAI data provider

use Dancer ':syntax';    #!debug !warning
use Carp qw/carp croak/;
use XML::LibXML;         #for salsa_setLibrary;
use HTTP::OAI::DataProvider 0.007;
use HTTP::OAI::Repository qw/validate_request/;
our $provider = initProvider();    #do this when starting the webapp

#use Data::Dumper qw/Dumper/; #for debugging, not for production

=head1 DESCRIPTION

A small webapp which acts as a OAI data provider based on
L<HTTP::OAI::DataProvider|https://github.com/mokko/HTTP-OAI-DataProvider>. 

SalsaOAI is used within the MIMO project to provide musical instrument
data via OAI.

=cut

#
# THE ONLY ROUTE
#

any [ 'get', 'post' ] => '/oai' => sub {
	my $ret;    # avoid perl's magic returns
	content_type 'text/xml';

	#check if verb is valid
	my $params=params();
	if ( my $verb = params->{verb} ) {
		if ( validate_request(%{$params}) ) {
			return $provider->err2XML( validate_request(%{$params}) );
		}

		#I have problems with requestURL. With some servers it disappears from
		#HTTP::OAI::Response. Let's hand it over explicitly!
		my $env = request->env;
		my $request =
		  'http://' . $env->{'HTTP_HOST'} . $env->{'REQUEST_URI'};
		debug "request: " . $request;
		$provider->requestURL($request);

		no strict "refs";
		return $provider->$verb( %{$params} );
	}
	return welcome();
};

hook after => sub {
	warning "Initial request is danced. How long did it take?";
};

dance;

#
#
#

=func checkConfig ();

Run checks if Dancer's configuration make sense, e.g. if chunking enabled, it
should also have the relevant information (e.g. chunk_dir). This check should
run during initial start up and throw intelligble errors if it fails, so we can
fix them right there and then and do not have to test all possibilities to
discover them.

=cut

sub checkConfig {

	#write oai_baseURL also in explicit requestURL
	config->{requestURL} = config->{identify}{baseURL};

	print 'get here ' . sub { 1 }
	  . "\n";

	#rewrite references to callbacks from yaml as codeRefs
	no strict 'refs';
	my @list = qw(debug warning);
	foreach my $item (@list) {
		if ( config->{$item} && defined( config->{$item}() ) ) {
			debug 'initializing ' . config->{$item};
			config->{$item} = config->{$item}();
		}
		else {
			debug 'problem initializing ' . $item;
		}
	}

	if ( config->{engine}{locateXSL}
		&& defined( config->{engine}{locateXSL}() ) )
	{
		debug 'initializing locateXSL';
		config->{engine}{locateXSL} = config->{engine}{locateXSL}();
	}
	else {
		debug 'problem initializing locateXSL';
	}

}

=func $provider=initProvider();

Initialize the data provider with settings either from Dancer's config
if classic configuration information or from callbacks.

=cut

sub initProvider {

	checkConfig();    #require good conditions or die

	my $provider = HTTP::OAI::DataProvider->new(config);

	#VALIDATE nothing on startup as it takes too long
	#possibly i could validate a few random records TODO
	if ($provider) {
		debug "data provider initialized!";
		return $provider;
	}
	die "provider not initialized";
}

=func welcome()

Gets called from Dancer's routes to display html pages on Salsa_OAI

=cut

sub welcome {
	content_type 'text/html';
	send_file 'index.htm';
}

#
# CALLBACKS
#

=func Debug "Message";

Use Dancer's debug function if available or else write to STDOUT. Register this
callback during initProvider.

=cut

sub initDebug {
	if ( defined(&Dancer::Logger::debug) ) {
		return sub {
			goto &Dancer::Logger::debug;
		};
	}
	else {
		return sub {
			foreach (@_) {
				print "$_\n";
			}
		};
	}
}

=func Warning "Message";

Use Dancer's warning function if available or pass message to perl's warn.

=cut

sub initWarning {
	if ( defined(&Dancer::Logger::warning) ) {
		return sub {
			goto &Dancer::Logger::warning;
		};
	}
	else {
		return sub { warn @_; };
	}
}

=func my xslt_fn=initLocateXSL($prefix);

locateXSL callback expects a metadataFormat prefix and will return the full
path to the xsl which is responsible for this transformation. On failure:
returns nothing.

=cut

sub initLocateXSL {
	return sub {
		my $targetPrefix = shift;
		if ( !config ) { die "Info on config missing"; }
		my $nativePrefix = ( keys %{ config->{engine}{nativeFormat} } )[0]
		  or die "Info on nativePrefix missing";

		return
		    config->{XSLT_dir} . '/'
		  . $nativePrefix . '2'
		  . $targetPrefix . '.xsl';
	};
}

1;
__END__

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

