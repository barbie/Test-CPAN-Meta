#!/usr/bin/perl -w
use strict;

use Test::More;
use IO::File;

# Skip if doing a regular install
plan skip_all => "Author tests not required for installation"
    unless ( $ENV{AUTOMATED_TESTING} );

my $fh = IO::File->new('Changes','r')   or plan skip_all => "Cannot open Changes file";

plan 'no_plan';

use Test::CPAN::Meta;
my $version = $Test::CPAN::Meta::VERSION;

my $latest = 0;
while(<$fh>) {
    next        unless(m!^\d!);
    $latest = 1 if(m!^$version!);
    like($_, qr!\d[\d._]+\s+\d{2}/\d{2}/\d{4}!,'... version has a date');
}

is($latest,1,'... latest version not listed');
