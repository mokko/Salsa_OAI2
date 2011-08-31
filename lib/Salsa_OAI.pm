package Salsa_OAI;
BEGIN {
  $Salsa_OAI::VERSION = '0.013';
}
# ABSTRACT: Simple OAI data provider

#still useful?
#use lib '/home/Mengel/projects/HTTP-OAI-DataProvider/lib';

use Dancer ':syntax';
use Carp qw/carp croak/;
use XML::LibXML;    #for salsa_setLibrary;
use HTTP::OAI;      #for salsa_identify, salsa_setLibrary
use HTTP::OAI::DataProvider;
use HTTP::OAI::Repository qw/validate_request/;
use Salsa_OAI::MPX;

#use Data::Dumper qw/Dumper/; #for debugging, not for production

our $provider = init_provider();    #do this when starting the webapp


#
# THE ONLY ROUTE
#

any [ 'get', 'post' ] => '/oai' => sub {
	my $ret;    # avoid perl's magic returns
	content_type 'text/xml';

	#I have problems with requestURL. With some servers it disappears from
	#from DataProvider's HTTP::OAI::Response. Therefore, let's hand it over to
	#the data provider explicitly!
	my $env     = request->env;
	my $request = 'http://' . $env->{'HTTP_HOST'} . $env->{'REQUEST_URI'};
	debug "request: " . $request;

	#I am not sure this is the best way to reconstruct the real request
	#but it should work for me

	#this needs to stay here to check if verb is valid
	if ( my $verb = params->{verb} ) {
		if ( validate_request(params) ) {
			return $provider->err2XML(validate_request(params));
		}

		no strict "refs";
		return $provider->$verb( $request, params() );
	} else {
		return welcome();
	}
};

after sub {
	warning "Initial request is danced. How long did it take?";
};
dance;

#
#
#


sub config_check {

	#1) check whether all required config data is available
	my @required = qw/
	  adminEmail
	  baseURL
	  chunkCacheMaxSize
	  repositoryName
	  setLibrary
	  xslt
	  XSLT_dir/;

	foreach (@required) {
		if ( !$_ ) {
			die "Configuration Error: Required config value $_ missing";
		}
	}

	#2) apply defaults, check conditionals
	if ( !config->{chunkSize} ) {
		debug "Config check: set chunk_size to default (100)";
		config->{chunkSize} = 100;    #default
	}

	#3) correct config data

	#write oai_baseURL also in explicit requestURL
	config->{requestURL} = config->{baseURL};

	#VALIDATE all xslts for conversion to target format during startup.
	#lasts too long

}


sub init_provider {

	#require conditions during start up or die
	#apply defaults, return as hashref
	config_check();

	my $provider = HTTP::OAI::DataProvider->new(config);

	#according to Demeter's law I should NOT access internal data
	#instead I should talk to provider's interface and hand over all
	#these values to the interface and let the provider deal with it

	debug "data provider initialized!";
	return $provider;
}


sub welcome {
	content_type 'text/html';
	send_file 'index.htm';
}

true;

#
# CALLBACKS
#


sub salsa_debug {
	if ( defined(&Dancer::Logger::debug) ) {
		goto &Dancer::Logger::debug;
	} else {
		foreach (@_) {
			print "$_\n";
		}
	}
}


sub salsa_warning {
	if ( defined(&Dancer::Logger::warning) ) {
		goto &Dancer::Logger::warning;
	} else {
		warn @_;
	}
}


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


sub salsa_locateXSL {
	my $prefix       = shift;
	my $nativeFormat = config->{nativePrefix};

	if ( !$nativeFormat ) {
		die "Info on nativeFormat missing";
	}

	return config->{XSLT_dir} . '/' . $nativeFormat . '2' . $prefix . '.xsl';
}

__END__
=pod

=head1 NAME

Salsa_OAI - Simple OAI data provider

=head1 VERSION

version 0.013

=head1 SYNOPSIS

This is a small webapp which acts as a OAI data provider based on
L<HTTP::OAI::DataProvider|https://github.com/mokko/HTTP-OAI-DataProvider> and Tim Brody's L<HTTP::OAI>. It is simply since
it

=over 4



=back

* does not support all OAI features (see below)
* it should be easy to maintain
* easy to configure
* easy to install

For a list of OAI features, see L<HTTP::OAI::DataProvider|https://github.com/mokko/HTTP-OAI-DataProvider>

=head1 FUNCTIONS

=head2 config_check ();

Run checks if Dancer's configuration make sense, e.g. if chunking enabled, it
should also have the relevant information (e.g. chunk_dir). This check should
run during initial start up and throw intelligble errors if it fails, so we can
fix them right there and then and do not have to test all possibilities to
discover them.

=head2 $provider=init_provider();

Initialize the data provider with settings either from Dancer's config
if classic configuration information or from callbacks.

=head2 welcome()

Gets called from Dancer's routes to display html pages on Salsa_OAI

=head2 Debug "Message";

Use Dancer's debug function if available or else write to STDOUT. Register this
callback during init_provider.

=head2 Warning "Message";

Use Dancer's warning function if available or pass message to perl's warn.

=head2 my $library = salsa_setLibrary();

Reads the setLibrary from dancer's config file and returns it in form of a
HTTP::OAI::ListSet object (which can, of course, include one or more
HTTP::OAI::Set objects)
  .
Background: setNames and setDescriptions are not stored with OAI headers,
but instead in the setLibrary. HTTP::OAI::DataProvider::SetLibrary associates
setSpecs with setNames and setDescriptions.

=head2 my xslt_fn=salsa_locateXSL($prefix);

locateXSL callback expects a metadataFormat prefix and will return the full
path to the xsl which is responsible for this transformation. On failure:
returns nothing.

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

=head1 AUTHOR

Maurice Mengel <mauricemengel@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Maurice Mengel.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

