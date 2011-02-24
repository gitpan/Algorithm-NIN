#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($status, $got, $ni);

$ni = "TN321256M";
eval { $status = Algorithm::NIN::validate($ni); };
$got = $@;
chomp($got);
like($got, qr/ERROR: Validation failed \[Temporary NI number contains invalid date of birth\]/);