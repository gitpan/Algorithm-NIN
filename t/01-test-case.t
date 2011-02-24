#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($status, $got, $expected, $ni);

$ni = "AA1234567C";
eval { $status = Algorithm::NIN::validate($ni); };
$got = $@;
chomp($got);
like($got, qr/ERROR: Validation failed \[Given NI number is longer than 9 characters\]/);