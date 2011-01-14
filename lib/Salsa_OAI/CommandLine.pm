package Salsa_OAI::CommandLine;

#this piece of config info seems out of place here
our $config_fn='/home/Mengel/projects/Salsa_OAI2/config.yml';

use YAML::Syck;
use strict;
use warnings;
use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT_OK = qw(load_conf test_conf_var);


=head2 my $conf=load_config;

Load config information from Dancer's config file

=cut

sub load_conf {

	#for load_config

	die "Cannot find config file" if ( !-e $config_fn );
	my $conf = LoadFile($config_fn) or die "Cannot load dancing config";
	return $conf;
}

=head2 test_config_var ($config, $var1, $var2, $var3);

	Reports an error and exists if variable is not specified in config file.

=cut

sub test_conf_var {
	my $conf=shift;

	foreach (@_) {

		if ( !$conf->{$_} ) {
			print "$_ info missing in dancer config";
			exit 1;
		}
	}
}


1; #Salsa_OAI::CommandLine;