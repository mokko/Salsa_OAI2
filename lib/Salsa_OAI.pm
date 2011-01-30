package Salsa_OAI;
use Dancer ':syntax';

#Frontend does not need to be called outside of it, right?
#use Dancer::CommandLine qw/Debug Warning/;
use Carp qw/carp croak/;
use lib '/home/Mengel/projects/HTTP-OAI-DataProvider/lib';
use HTTP::OAI::DataProvider::GlobalFormats;
use HTTP::OAI::DataProvider::Transformer;
use HTTP::OAI::DataProvider::SQLite;
use HTTP::OAI::DataProvider;
use HTTP::OAI::Repository qw/validate_request/;
use HTTP::OAI;      #for salsa_identify, salsa_setLibrary
use XML::LibXML;    #for salsa_setLibrary;

#use Data::Dumper qw/Dumper/; #for debugging, not for production

our $provider = init_provider();    #do this when starting the webapp
our $VERSION  = '0.2';              #sqlite

=head1 NAME

Salsa_OAI - Simple OAI data provider based on Dancer

=head1 SYNOPSIS

This is a small webapp which acts as a OAI data provider based on
HTTP::OAI::DataProvider::Simple and Tim Brody's HTTP::OAI.

=head1 FEATURES

TODO Write new text

This data provider is just one notch up from a static repository:
- no database, instead header information is parsed to memory
- metadata format freedom: on the fly conversations from native format to
  whatever external format you supply an XSLT transformation for, see below.
- easy to maintain since simple
- deployment freedom with dancer, see Dancer::Deployment
- OAI-PMH Protocol version 2.0
- Sets: basically work, but not set hierarchies
- compression. If deployed right, e.g. with PLACK::Middleware::Deflate should
  take care of that.

=head1 NOT SUPPORTED
- streaming. Currently request has to be finished to start transmit.
- Resumption tokens
- Deleted Headers

Metadata Freedom: Salsa_OAI is agnostic concerning its metadata formats.
Use XSLT 1.0 to tranform your native format in whatever you like.

=head1 SEE ALSO

- Dancer at cpan or perldancer.org.
- Some ideas concerning inheritance and abstracion derived from OCLC's OAIcat.
- HTTP::OAI
- HTTP::OAI::DataProvider

=cut

#
# THE ONLY ROUTE
#

any [ 'get', 'post' ] => '/oai' => sub {
	my $ret;    # avoid perl's magic returns

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
		if ( my $error = validate_request(params) ) {
			return $provider->err2XML($error);
		}

		no strict "refs";
		return $provider->$verb( $request, params() );
	} else {
		return welcome();
	}
};
dance;

after sub {
	warning "This dance is over. How long did it take?";

	#my $response = shift; do something with request
};

#
#
#

sub welcome {
	content_type 'text/html';
	send_file 'index.htm';
}

sub salsa_Identify {
	my $self = shift;

	#debug " Enter salsa_Identify ";

	#take info from config
	#Who am I complying to? Just a debug?

	foreach my $test (qw/repositoryName adminEmail deletedRecord/) {
		if ( !config->{"oai_$test"} ) {
			die "oai_$test setting in Dancer's config missing !";
		}
	}

   #I can try to identify baseURL automatically, but having the data provider
   #some kind of reverse proxy can easily confuse the url, so better hardwire it
   #baseURL        => uri_for( request->path ),

	my $baseURL;
	config->{oai_baseURL}
	  ? $baseURL =
	  config->{oai_baseURL}
	  : $baseURL = uri_for( request->path );

	my $identify = {
		adminEmail     => config->{oai_adminEmail},
		baseURL        => $baseURL,
		deletedRecord  => config->{oai_deletedRecord},
		repositoryName => config->{oai_repositoryName},
	};

	return $identify;
}

=head2 $provider=init_provider();

Initialize the data provider with settings either from Dancer's config
if classic configuration information or from callbacks.

=cut

sub init_provider {

	config_check();

	#debug " data provider needs to be initialized ONCE ";
	my %args = (
		Identify   => config->{identify_cb},
		requestURL => config->{oai_baseURL},
		setLibrary => config->{setLibrary_cb},
		xslt       => config->{XSLT},

		#nativeFormatPrefix => 'mpx',    #not used at the moment
	);

	#step 1 basic traits which do not change per request
	my $provider = HTTP::OAI::DataProvider->new(%args);

	#step 2: init global metadata formats from Dancer config
	#parse formats from config in GlobalFormats object
	my $globalFormats = new HTTP::OAI::DataProvider::GlobalFormats;
	my %cnf;
	if ( config->{GlobalFormats} ) {
		%cnf = %{ config->{GlobalFormats} };
	}
	foreach my $prefix ( keys %cnf ) {

		#debug " Registering global format $prefix";
		if ( !$cnf{$prefix}{ns_uri} or !$cnf{$prefix}{ns_schema} ) {
			die "GlobalFormat $prefix in yaml configuration incomplete";
		}
		$globalFormats->register(
			ns_prefix => $prefix,
			ns_uri    => $cnf{$prefix}{ns_uri},
			ns_schema => $cnf{$prefix}{ns_schema},
		);
	}
	$provider->{globalFormats} = $globalFormats;

	#step 3: intialize engine
	$provider->{engine} =
	  new HTTP::OAI::DataProvider::SQLite( dbfile => config->{dbfile} );

	#optional arguments
	if ( config->{chunking} ) {

		#two values in Dancer's config become one in DataProvider
		if ( config->{chunking} eq 'true' ) {
			my $chunk_size = 100;    #default
			if ( config->{chunk_size} ) {
				$chunk_size = config->{chunk_size};
			}
			$provider->{engine}->{chunk_dir} = config->{chunk_dir};
			$provider->{engine}->{resumption} = $chunk_size;
		}
	}

	#step 4: initialize transformer
	$provider->{engine}->{transformer} =
	  new HTTP::OAI::DataProvider::Transformer(
		nativePrefix => config->{native_ns_prefix},
		locateXSL    => 'Salsa_OAI::salsa_locateXSL',
	  );

	#debug "data provider initialized!";
	return $provider;
}

=head2 config_check ();

Run checks if Dancer's configuration make sense, e.g. if chunking enabled, it
should also have the relevant information (e.g. chunk_dir). This check should
run during initial start up and throw intelligble errors if it fails, so we can
fix them right there and then and do not have to test all possibilities to
discover them.

=cut

sub config_check {
	if ( config->{chunking} ) {
		if ( config->{chunk_dir} ) {
			config->{chunk_dir}=~s|\/$||; #remove trailing slash if any
		} else {
			die 'Configuration Error: Need chunk_dir for temporary '
			  . 'storage of chunks';
		}
	}
}

=head2 my $library = salsa_setLibrary();

Reads the setLibrary from dancer's config file
  and returns it in form of a HTTP::OAI::ListSet object(
	     which can, of course, include one
	  or more HTTP::OAI::Set objects
  )
  .

  Background: setNames
  and setDescriptions are not stored with OAI headers,
  but instead in the setLibrary
  . HTTP::OAI::DataProvider::SetLibrary associates setSpecs with setNames
  and setDescriptions
  .

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

=head2 my xslt_fn=salsa_locateXSL($prefix);

locateXSL callback expects a metadataFormat prefix and will return the full
path to the xsl which is responsible for this transformation. On failure:
returns nothing.

=cut

sub salsa_locateXSL {
	my $prefix       = shift;
	my $nativeFormat = config->{native_ns_prefix};
	return config->{XSLT_dir} . '/' . $nativeFormat . '2' . $prefix . '.xsl';
}

=head1 CHUNKING

I wonder how I should implement chunking.

1) Configuration in config.yml. Salsa_OAI parses configuration and saves it in
$engine. I need chunking true/false, chunk_dir and chunk_size.

2) If chunking is on queryHeader and queryRecord return only the first chunk.
We need to make resumptionToken for the 2nd chunk though to return the first
chunk. Return to Salsa_OAI/Dancer as usual

3) in AFTER we need to test for chunking. Maybe we need query db again and save
   the remaining chunks to disk. The problem
a) Is AFTER reliable? Is seems to me that it is not really called all the time
b) How to communicate between queryResult and AFTER. So far I have save info
   in $result, but result is not accessible from AFTER, right? I can save data
   in $engine, but then I need to make sure it is deleted before next request.
   The only way to do so seems to be delete it before the next request.
c) AFTER has to apply


=cut

true;
