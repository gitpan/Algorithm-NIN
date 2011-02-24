#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($status, $got, $ni);

$ni = "TN123456C";
eval { $status = Algorithm::NIN::validate($ni); };
$got = $@;
chomp($got);
like($got, qr/ERROR: Validation failed \[Temporary NI number should always start with TN and ends with either M or F\]/);