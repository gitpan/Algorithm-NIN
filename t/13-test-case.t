#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($got, $expected, $ni);

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', class => 3 });
is($got, 12.05);