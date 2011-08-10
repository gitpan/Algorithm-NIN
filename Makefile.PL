use ExtUtils::MakeMaker;

WriteMakefile
(
    'NAME'           => 'Algorithm::NIN',
    'VERSION_FROM'   => 'lib/Algorithm/NIN.pm',
    'clean'          => { FILES => 'Algorithm-NIN-*' },
    'PREREQ_PM'      => {
        'Readonly'   => '1.03',
        'Test::More' => '0'
    },
);