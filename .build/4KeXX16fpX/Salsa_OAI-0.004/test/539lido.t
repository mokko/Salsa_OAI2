#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 5;
use Test::XPath;
use FindBin;

#change
my $id     = 539;
my $format = 'lido';

#derrived
my $wrapped   = "$id/oai.$format.xml";
my $unwrapped = "$id/$format.xml";

#commands
my $cmd = {
	extract  => $FindBin::Bin . '/../bin/extract.pl',
	unwrap   => $FindBin::Bin . '/../bin/unwrap.pl',
	validate => '/home/Mengel/projects/Harvester/bin/validate.pl'
};

foreach my $c (keys %{$cmd}) {
	die "cmd $cmd not found" if (! -f $cmd->{$c});
}

# prepare
if ( !-d $id ) {
	mkdir $id;
}
die "Cannot create dir $id" if ( !-d $id );

# extract from db
{

	#I should not test for existing file since could be left over from last time
	#ok( ( -f $wrapped eq 1 ), 'wrapped extracted' );
	system "$cmd->{extract} $id $format> $wrapped";
	ok( $? ne '-1', 'wrapped extracted' );
}

# unwrap
{

	#I should not test for existing file since could be left over from last time
	system "$cmd->{unwrap} $wrapped $unwrapped";
	ok( $? ne '-1', 'unwrapped ' );
	diag "unwrapped: $unwrapped ($?)";

}

# validate
{
	system "$cmd->{validate} $unwrapped $format";    #how do I test right return value?
	ok( $? eq '0', 'validates' );
	diag "validation: $?";
}

my $tx = Test::XPath->new(
	file  => $unwrapped,
	xmlns => { lido => 'http://www.lido-schema.org' }
);

ok( ref $tx eq 'Test::XPath', 'tx made successfully' );

#$tx->is( '/html/head/title', 'Hello', 'The title should be correct' );
$tx->is(
	'/lido:lidoWrap/lido:lido/lido:descriptiveMetadata'
	  . '/lido:objectIdentificationWrap/lido:titleWrap/'
	  . 'lido:titleSet/lido:appellationValue',
	'Tonpfeife',
	'title is correct'
);

