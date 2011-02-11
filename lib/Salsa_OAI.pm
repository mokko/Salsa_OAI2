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
		if ( my $error = validate_request(params) ) {
			return $provider->err2XML($error);
		}

		no strict "refs";
		return $provider->$verb( $request, params() );
	} else {
		return welcome();
	}
};

before sub {
	if ( $provider->{engine}->{chunkRequest} ) {
		delete $provider->{engine}->{chunkRequest};
		debug "DELETE CHUNK REQUEST";
	}
	#warning "I was here" ;
};

after sub {
	warning "Initial request is danced. How long did it take?";

	#write chunks to disk cache if necessary
	my $engine = $provider->{engine};
	#not elegant to pass over the provider, isn't it?
	$engine->completeChunks( $provider );
	warning "Post-dance chunks done. How long did this take?";
};
dance;

#
#
#


=head2 config_check ();

Run checks if Dancer's configuration make sense, e.g. if chunking enabled, it
should also have the relevant information (e.g. chunk_dir). This check should
run during initial start up and throw intelligble errors if it fails, so we can
fix them right there and then and do not have to test all possibilities to
discover them.

=cut

sub config_check {
	my @required = qw/
	  oai_adminEmail identify_cb oai_baseURL oai_repositoryName setLibrary_cb
	  XSLT XSLT_dir/;

	foreach (@required) {
		if ( !$_ ) {
			die "Configuration Error: Required config value $_ missing";
		}
	}

	#defaults, conditionals, corrections
	if ( config->{chunking} ) {
		if ( !config->{chunk_size} ) {
			debug "Config check: set chunk_size to default (100)";
			config->{chunk_size} = 100;    #default
		}
		if ( config->{chunk_dir} ) {
			config->{chunk_dir} =~ s|\/$||;    #remove trailing slash if any
		} else {
			die 'Configuration Error: Need chunk_dir for temporary '
			  . 'storage of chunks';
		}
	}
}


=head2 $provider=init_provider();

Initialize the data provider with settings either from Dancer's config
if classic configuration information or from callbacks.

=cut

sub init_provider {

	config_check();    #require conditions during start up or die

	#
	# init provider
	#

	my %args = (
		debug	=> 'Salsa_OAI::salsa_debug', #not sure about this
		Identify   => config->{identify_cb},
		requestURL => config->{oai_baseURL},
		setLibrary => config->{setLibrary_cb},
		warning	   => 'Salsa_OAI::salsa_debug', #not sure about this
		xslt       => config->{XSLT},

		#nativeFormatPrefix => 'mpx',    #not used at the moment
	);

	my $provider = HTTP::OAI::DataProvider->new(%args);

	#
	# init global metadata formats
	#

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

	#
	# intit engine
	#

	$provider->{engine} =
	  new HTTP::OAI::DataProvider::SQLite( dbfile => config->{dbfile} );

	if ( config->{chunking} ) {
		if ( config->{chunking} ne 'false' ) {

			#debug "Set chunking params in engine";
			#two values in Dancer's config become one in DataProvider
			#chunking and chunk_size
			$provider->{engine}->{chunking}  = config->{chunk_size};
			$provider->{engine}->{chunk_dir} = config->{chunk_dir};

			#debug "test: chunk_size" . $provider->{engine}->{chunking};
		}
	}

	#
	# init transformer
	#

	$provider->{engine}->{transformer} =
	  new HTTP::OAI::DataProvider::Transformer(
		nativePrefix => config->{native_ns_prefix},
		locateXSL    => 'Salsa_OAI::salsa_locateXSL',
	  );

	#debug "data provider initialized!";
	return $provider;
}


=head2 welcome()

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

=head2 Debug "Message";

Use Dancer's debug function if available or else write to STDOUT. Register this
callback during init_provider.

=cut

sub salsa_debug {
	if ( defined(&Dancer::Logger::debug) ) {
		goto &Dancer::Logger::debug;
	} else {
		foreach (@_) {
			print "$_\n";
		};
	}
}

=head2 Warning "Message";

Use Dancer's warning function if available or pass message to perl's warn.

=cut

sub salsa_warning {
	if ( defined(&Dancer::Logger::warning) ) {
		goto &Dancer::Logger::warning;
	} else {
		warn @_;
	}
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

=head2 Chunking Implementation History

I wonder how I should implement chunking. My first attempt was a disk cache.
Disadvantage was that the whole request had to be processed before I could
start sending out the first chunk. New approach is to cache the "question" and
not the result. This way, I should be able to distribute the database work
and everything that comes after it to each chunk request.

=head2 New Approach Caching request

So if request first comes in, we check for chunking configuration. If chunking
on, we plan chunking for this request, save the result in the chunkCache and
return the first chunk. On subsequent requests (using resumptionTokens), we
perform new db requests and return the result accordingly, i.e. we do not need
to plan again. (In other words: planning is only part of the first request.)

FIRST REQUEST
   check chunking config
a) plan chunking + save plan into chunkCache + return first token
b) return first chunk

SUBSEQUENT REQUESTS
b) return the chunk that is indicated by token (rt)

WHERE DOES CONFIG GO?
Configuration in config.yml. Salsa_OAI parses configuration and saves it in
$engine:
	chunking (true/false): if chunking on or off
	chunk_size (an integer): no of reslts (records or headers) per chunk
	maxCacheSize (an integer): max no of chunks stored in chunkCache

These parameters are constant as long as data provider runs. But there are also
request specific bits. I need to know which chunk and how big the total size
is. So where do I store that? Gets stored in chunkCache

HOW TO STORE REQUEST INFO
	chunkCache (an integer): object that stores queries per token

A) PLAN CHUNKING
config value:ChunkCacheSize. Number of tokens that can be stored simultaneously
must be greater than max number of chunks.

a) check max size of chunk cache and delete old chunks if maxNoChunksCache is
reached. How can I make sure that none of the current chunks are deleted?
current_Chunk_size + maxChunkNo of current request is total after caching
if this total is greater than ChunkCacheSize delete however many are necessary
to have the right size.

check that ChunkCacheSize is bigger than maxChunkNo and warn if not. If
maxChunkNo is bigger than we can have a cache that is bigger than
chuckCacheSize which is irritating, but not a major problem.

b) get totalResults from current query
c) calculate maxChunkNo for current query
c) create a tokens. current token and token to reach the following chunk (next)
d) save info under token for each chunk:
e) return first token

my $token=mk_token;
%chunkCache->{$token}={
		chunkNo=>$chunkNo,
		maxChunkNo=>$maxChunkNo,
		next=>$token,
		sql=>$sql,
		total=>$total
};

FromRecordId and ToRecordId: At some point I have to determine which records to
handle back. For this I need to know either first and last or the ChunkNo. Why
don't I save the chunkNo. It is only one number. Then I calculate these no.s
inside of queryChunk.

B) RETURN CHUNK INDICATED BY TOKEN

check if token exists in chunkCache
if not return error
if exists return corresponding chunk

$response=queryChunk (sql=>$sql,$maxChunkNo);

make sure we add correct token, xslt and requestURL
#$response->resumptionToken ($rt);
#$response->requestURL ($request);
#etc.

=cut

