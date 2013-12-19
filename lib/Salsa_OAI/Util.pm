#ABSTRACT: Useful functions for common use
package Salsa_OAI::Util;
use strict;
use warnings;
use Path::Class;
use Carp 'croak';
require Exporter;
our @ISA = qw(Exporter);
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

1;
