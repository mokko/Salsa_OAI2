#ABSTRACT: Useful functions for common use
package Salsa_OAI::Util;
use strict;
use warnings;
use Path::Class;
use Carp 'croak';
use Dancer ':syntax';
use FindBin;
use Class::Load 'load_class';
require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(modDir);

=func $modDir=modDir();

Should returns what I call the module directory, i.e.

	$modDir/bin/script.pl

Optionally, you can add more paths to append to the directory. In this case, 
modDir croaks when a file does not exist:

	$modDir=modDir('additional','path');

Returned path is relative.

TODO: Test if this is relative to Salsa_OAI::Util or executing script...


=cut

sub modDir {

	my $modDir = file(__FILE__)->parent->parent->parent;
	if (@_) {
		$modDir = file( $modDir, @_ );

		if ( !-e $modDir ) {
			croak "File/dir  '$modDir' not found!";
		}
	}
	return $modDir;
}

sub loadConfig {

	#correct bug in current dancer
	Dancer::Config::setting( 'appdir', file($FindBin::Bin)->parent );
	Dancer::Config::load();
	config->{environment} =
	  'production';    #should make debug silent, but doesn't ey?
	return config;
}

=func my $config=configSanity ();

Run checks if Dancer's configuration make sense, e.g. if chunking enabled, it
should also have the relevant information (e.g. chunk_dir). This check should
run during initial start up and throw intelligble errors if it fails, so we can
fix them right there and then and do not have to test all possibilities to
discover them.

Gets called from Salso_OAI.pm and extract.pl.

=cut

sub configSanity {
	die "Error: Need baseURL" if ( !config->{identify}{baseURL} );

	#apply defaults, check conditionals
	if ( !config->{engine}{chunkCache}{maxChunks} ) {
		debug "Config check: set engine/chunkCache/maxChunks to default (100)";
		config->{engine}{chunkCache}{maxChunks} = 100;    #default
	}

	#interpret locateXSL as callback
	#not a particularly clean solution, but not sure how to avoid it
	die "Error: No locateXSL!" if ( !config->{engine}{locateXSL} );
	my $pkg = config->{engine}{locateXSL};
	$pkg =~ s/::[\w]+$//;
	debug "about to load '$pkg'";
	load_class($pkg)
	  or die
	  "Can't load '$pkg'"; #should I load the relevant package dynamically here?
	no strict "refs";
	config->{engine}{locateXSL} = &{ config->{engine}{locateXSL} };
	use strict "refs";

	#I am cheating here. Turn on debug in case there is debug in configuration
	if ( config->{debug} ) {
		config->{debug} = sub {
			if ( defined(&Dancer::Logger::debug) ) {
				goto &Dancer::Logger::debug;
			}
			else {
				foreach (@_) {
					print "$_\n";
				}
			}
		  }
	}
	if ( config->{warning} ) {
		config->{warning} = sub {
			if ( defined(&Dancer::Logger::warning) ) {
				goto &Dancer::Logger::warning;
			}
			else {
				warn @_;
			}
		  }
	}

	#write oai_baseURL also in explicit requestURL
	config->{requestURL} = config->{identify}{baseURL};

	#VALIDATE all xslts for conversion to target format during startup.
	#lasts too long
	return config;
}

=func Debug "Message";

Use Dancer's debug function if available or else write to STDOUT. Register this
callback during init_provider.

=func Warning "Message";

Use Dancer's warning function if available or pass message to perl's warn.

=cut

1;
