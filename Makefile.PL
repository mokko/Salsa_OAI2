
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Simple OAI data provider",
  "AUTHOR" => "Maurice Mengel <mauricemengel\@gmail.com>",
  "BUILD_REQUIRES" => {
    "English" => 0,
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Salsa_OAI",
  "EXE_FILES" => [
    "bin/app.pl",
    "bin/csv2dict.pl",
    "bin/deleteRecord.pl",
    "bin/digest.pl",
    "bin/dump-mpx.pl",
    "bin/encodingTerror.pl",
    "bin/extract.pl",
    "bin/linklintMIMO.pl",
    "bin/querydb.pl",
    "bin/transformStore.pl",
    "bin/unwrap.pl",
    "bin/updateStore.pl"
  ],
  "LICENSE" => "perl",
  "NAME" => "Salsa_OAI",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Cwd" => 0,
    "DBD::SQLite" => 0,
    "DBI" => 0,
    "Dancer" => 0,
    "Date::Manip" => 0,
    "Encode" => 0,
    "FindBin" => 0,
    "Getopt::Std" => 0,
    "HTTP::OAI" => 0,
    "HTTP::OAI::DataProvider" => 0,
    "HTTP::OAI::DataProvider::SQLite" => 0,
    "HTTP::OAI::Metadata" => 0,
    "HTTP::OAI::Repository" => 0,
    "IO::File" => 0,
    "LWP::Simple" => 0,
    "Pod::Usage" => 0,
    "SOAP::DateTime" => 0,
    "Text::CSV" => 0,
    "XML::LibXML" => 0,
    "XML::LibXML::XPathContext" => 0,
    "XML::LibXSLT" => 0,
    "XML::Writer" => 0,
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.021",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



