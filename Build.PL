use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign                => 1,
    module_name         => 'Algorithm::NIN',
    license             => 'perl',
    dist_author         => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from   => 'lib/Algorithm/NIN.pm',
    add_to_cleanup      => [ 'Algorithm-NIN-*' ],
    build_requires      => {
        'Test::More'    => 0,
        'Readonly'      => 0,
        'Module::Build' => 0.36,
    },
);

$builder->create_build_script();