#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($status, $got, $expected, $ni);

$ni = "AA1234C";
eval { $status = Algorithm::NIN::validate($ni); };
$got = $@;
chomp($got);
like($got, qr/ERROR: Validation failed \[NI number can't be shorter than 8 characters\]/);