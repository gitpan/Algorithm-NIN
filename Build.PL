use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Algorithm::NIN',
    license             => 'perl',
    dist_author         => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from   => 'lib/Algorithm/NIN.pm',
    build_requires => {
        'Test::More' => 0,
        'Readonly'   => 0,
    },
    add_to_cleanup      => [ 'Algorithm-NIN-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
