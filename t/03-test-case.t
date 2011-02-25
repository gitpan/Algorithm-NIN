#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($status, $got, $ni);

$ni = 'AO123456C';
eval { $status = Algorithm::NIN::validate($ni); };
$got = $@;
chomp($got);
like($got, qr/ERROR: Validation failed \[Second letter of NI number can't be D\,F\,I\,O\,Q\,U or V\]/);