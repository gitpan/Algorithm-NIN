#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($got, $expected, $ni);

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', gross_salary => 65000, self_employed => 1, class => 2 });
is($got, '2.40');