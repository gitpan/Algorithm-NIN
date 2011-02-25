#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($status, $got, $ni);

$ni = 'AA123456E';
eval { $status = Algorithm::NIN::validate($ni); };
$got = $@;
chomp($got);
like($got, qr/ERROR: Validation failed \[Last letter of NI number can only be A\,B\,C\,D or a number\]/);