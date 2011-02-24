use ExtUtils::MakeMaker;

WriteMakefile
(
    'NAME'           => 'Algorithm::NIN',
    'VERSION_FROM'   => 'lib/Algorithm/NIN.pm',
    'INSTALLDIRS'    => 'site',
    'EXE_FILES'      => [],
    'PL_FILES'       => {},
    'PREREQ_PM'      => {
        'Readonly'   => '0',
        'Test::More' => '0'
    },
);