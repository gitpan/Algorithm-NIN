#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($status, $got, $ni);

$ni = 'DA123456C';
eval { $status = Algorithm::NIN::validate($ni); };
$got = $@;
chomp($got);
like($got, qr/ERROR: Validation failed \[First letter of NI number can't be D\,F\,I\,Q\,U or V\]/);