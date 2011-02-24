#!perl

use Test::More tests => 2;

use Algorithm::NIN;
my ($got, $expected, $ni);

$ni  = 'AA123456C';
$got = Algorithm::NIN::format($ni);
$expected = 'AA 12 34 56 C';
is($got, $expected);

$ni  = 'AA123456';
$got = Algorithm::NIN::format($ni);
$expected = 'AA 12 34 56';
is($got, $expected);