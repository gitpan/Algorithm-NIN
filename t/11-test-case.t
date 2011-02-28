#!perl

use Test::More tests => 3;

use Algorithm::NIN;
my ($got, $expected, $ni);

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', gross_salary => 65000, self_employed => 0 });
is($got, 129.46);

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', gross_salary => 65000, self_employed => 0, married => 0, sex => 'f' });
is($got, 129.46);

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', gross_salary => 65000, self_employed => 0, married => 1, sex => 'f' });
is($got, 59.35);