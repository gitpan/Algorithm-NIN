#!perl

use strict; use warnings;
use Test::More tests => 3;

use Algorithm::NIN;
my ($got, $expected, $ni);

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', gross_per_week => 450, self_employed => 0 });
is($got, '37.40');

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', gross_per_week => 450, self_employed => 0, married => 0, sex => 'f' });
is($got, '37.40');

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', gross_per_week => 450, self_employed => 0, married => 1, sex => 'f' });
is($got, '16.49');