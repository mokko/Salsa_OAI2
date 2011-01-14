package Salsa_OAI;
use Dancer ':syntax';
use HTTP::OAI;
use Carp qw/carp croak/;
use lib '/home/Mengel/projects/HTTP-OAI-DataProvider/lib';
use HTTP::OAI::DataProvider;
#necessary?
use HTTP::OAI::Repository qw/validate_request/;
#only for debugging
use Data::Dumper qw/Dumper/;


our $provider      = init_dp();    #do this when starting the webapp
our $VERSION = '0.2'; #sqlite


=head1 NAME

Salsa_OAI - Simple OAI data provider based on Dancer

=head1 SYNOPSIS

This is a small webapp which acts as a OAI data provider based on
HTTP::OAI::DataProvider::Simple and Tim Brody's HTTP::OAI.

=head1 FEATURES

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

any [ 'get', 'post' ] => '/oai'=> sub {
	my $ret;    # avoid perl's magic returns

	if ( my $verb = params->{verb} ) {
		#wd be nicer if this wd be part DataProvider
		my $error = validate_request(params);

		if ($error) {
			return err2XML_FN($error);
		}

		no strict "refs";
		$ret = $provider->$verb( params() );
		use strict "refs";

	} else {
		$ret = welcome();
	}
	warning "This dance is over. How long did it take?";
	return $ret;
};
dance;
true;

sub welcome {
	content_type 'text/html';
	send_file 'index.htm';
}

sub salsa_Identify {
	debug " Enter salsa_Identify ";

	#
	# Metadata handling
	#

	#take info from config
	#I should complain intelligble when info not there

	foreach my $test (
		qw/repositoryName adminEmail deletedRecord
		granularity/
	  )
	{
		if ( !config->{"oai_$test"} ) {

			#should not just be a debug
			die "oai_$test setting in Dancer's config missing !";
		}
	}

	my $early='0001-01-01';
	if (config->{oai_earliestDatestamp}) {
		$early=config->{oai_earliestDatestamp};
	}
	#SELECT MIN (datestamp) FROM records;


	#obligatory
	my $obj = new HTTP::OAI::Identify(
		adminEmail    => config->{oai_adminEmail},
		#take baseURL from dancer
		baseURL       => uri_for( request->path ),
		deletedRecord => config->{oai_deletedRecord},
		granularity   => config->{oai_granularity},
		repositoryName => config->{oai_repositoryName},
		earliestDatestamp => $early,
	  )
	  or return "Cannot create new HTTP::OAI::Identify ";

	return $obj;

	#$obj->xslt( config->{XSLT} );
	#	TODO: this needs to go somewhere in HTTP::OAI::DataProvider::Simple
	#	return $obj->Salsa_OAI::toString;
	#my $xml;
	#$obj->set_handler( XML::SAX::Writer->new( Output => \$xml ) );
	#$obj->generate;
	#return $xml;

}

=head2 err2XML_FN

FN indicates that this is a function, not a method.

Fake a DataProvider object and pass error message(s) to
HTTP::OAI::DataProvider::Simple. Return error msg from there.
Returns nothing (fails) if given nothing.

=cut

sub err2XML_FN {
	my $self = new HTTP::OAI::DataProvider::Simple( xslt => config->{XSLT} );
	if (@_) {
		return $self->err2XML(@_);
	}
}

=head2 $provider=init_dp();

Initialize the data provider with settings either from Dancer's config
if classic configuration information or from this file (callbacks).

=cut

sub init_dp {

	#if ( !config->{path} ) {
	#	croak "I need a path in dancer config, e.g. '/oai'";
	#}

	debug " data provider needs to be initialized ONCE ";

	#step 1 set up callbacks (mostly mapping related)
	my $provider = HTTP::OAI::DataProvider->new(
		Identify      => 'Salsa_OAI::salsa_Identify',
		locateXSL     => 'Salsa_OAI::salsa_locateXSL',
		setLibrary    => 'Salsa_OAI::salsa_setLibrary',
		xslt          => config->{XSLT},
		nativeFormatPrefix => 'mpx',    #not used at the moment
		                                #for listRecord disk cache
	);

	#step 2: init global metadata formats from Dancer config
	my %cnf;
	if ( config->{GlobalFormats} ) {
		%cnf = %{ config->{GlobalFormats} };
	}

	my $globalFormats=new HTTP::OAI::DataProvider::GlobalFormats;

	foreach my $prefix ( keys %cnf ) {
		debug " Registering global format $prefix";
		if ( !$cnf{$prefix}{ns_uri} or !$cnf{$prefix}{ns_schema} ) {
			die "GlobalFormat $prefix in yaml configuration incomplete";
		}

		$globalFormats->register(
			ns_prefix => $prefix,
			ns_uri    => $cnf{$prefix}{ns_uri},
			ns_schema => $cnf{$prefix}{ns_schema},
		);

	}
	#I am cheating here somewhat
	$provider->{globalFormats}=$globalFormats;

	$provider->{engine}=new HTTP::OAI::DataProvider::Sqlite(dbfile=>config->{dbfile});


	#debug "data provider initialized!";
	return $provider;
}


=head2 my xslt_fn=salsa_locateXSL($prefix);

locateXSL callback expects a metadataFormat prefix and will return the full
path to the xsl which is responsible for this transformation. On failure:
returns nothing.

=cut

sub salsa_locateXSL {
	my $prefix       = shift;
	my $nativeFormat = 'mpx';
	return config->{XSLT_dir} . '/' . $nativeFormat . '2' . $prefix . '.xsl';
}

=head2 my $library=salsa_setLibrary();

Reads the setLibrary from dancer's config file. setNames and setDescriptions
are not stored with OAI headers, but instead in the setLibrary.
HTTP::OAI::DataProvider::SetLibrary associates setSpecs with setNames
and setDescriptions. This callback parses the config file for the setLibrary
info and returns a HTTP::OAI::ListSets object which includes one or more
HTTP::OAI::Set objects.

On failure, should return nothing.

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
		warn "no setLibrary found in Dancer's config file";

		#return empty-handed and fail
	}
}

