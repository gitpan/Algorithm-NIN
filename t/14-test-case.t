#!perl

use Test::More tests => 2;

use Algorithm::NIN;
my ($got, $expected, $ni);

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', annual_profit => 10000, self_employed => 1, class => 4 });
is($got, '342.80');

$got = Algorithm::NIN::calculateNI({ fiscal_year => '2010-11', annual_profit => 50000, self_employed => 1, class => 4 });
is($got, 3604.05);