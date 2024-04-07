# vi:set ft=perl:
use strict;
use warnings;

{
    package Sys_Macro;
    local $^W = 0;
    require 'syscall.ph';
    SYS_getrandom();
    require 'sys/random.ph';
    GRND_RANDOM();
    GRND_NONBLOCK();
}

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

    REPOSITORY => [ github => 'mauke' ],
};
