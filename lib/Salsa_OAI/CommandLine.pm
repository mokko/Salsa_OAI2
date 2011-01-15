package Salsa_OAI::CommandLine;

#this piece of config info seems out of place here
#deal with it later: put it in the caller namespace:
#use Salsa_OAI::CommandLine '/path/to/config.yml';
our $config_fn = '/home/Mengel/projects/Salsa_OAI2/config.yml';

use YAML::Syck;
use strict;
use warnings;
use Exporter;
use Carp qw/carp croak/;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(load_conf test_conf_var);

=head2 my $conf=load_config;

Load config information from Dancer's config file

=cut

sub load_conf {

	#for load_config

	if ( !-e $config_fn ) {
		carp "Cannot find config file";
	}
	my $conf = LoadFile($config_fn) or carp "Cannot load dancing config";
	return $conf;
}

=head2 test_config_var (qw /var1 var2 var3/);

If variable is not specified in config file,this function reports error and
exists.

=cut

sub test_conf_var {
	my $conf = load_conf();

	foreach (@_) {

		if ( !$conf->{$_} ) {
			print "$_ info missing in dancer config";
			exit 1;
		}
	}
}

1;    #Salsa_OAI::CommandLine;
