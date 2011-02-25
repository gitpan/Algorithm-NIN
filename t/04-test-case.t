#!perl

use Test::More tests => 1;

use Algorithm::NIN;
my ($status, $got, $ni);

$ni = 'BG123456C';
eval { $status = Algorithm::NIN::validate($ni); };
$got = $@;
chomp($got);
like($got, qr/ERROR: Validation failed \[First two lettes of NI number can't be BG\,GB\,NK\,KN\,NT or ZZ\]/);