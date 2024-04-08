# vi:set ft=perl:
use strict;
use warnings;

my $gen = 'PP.pm.PL';

return {
    NAME   => 'Sys::GetRandom::PP',
    AUTHOR => q{Lukas Mai <l.mai@web.de>},

    CONFIGURE_REQUIRES => {},
    BUILD_REQUIRES => {},
    TEST_REQUIRES => {
        'Test2::V0' => 0,
    },
    PREREQ_PM => {
        'Carp'     => 0,
        'Exporter' => '5.57',
        'strict'   => 0,
        'warnings' => 0,
    },

    PM => {
        'PP.pm' => '$(INST_ARCHLIB)/Sys/GetRandom/PP.pm',
    },
    clean => {
        FILES => 'PP.pm',
    },
    PL_FILES => {
        $gen => 'PP.pm',
    },

    ABSTRACT_FROM => $gen,
    VERSION_FROM  => $gen,

    REPOSITORY => [ github => 'mauke' ],
};
