use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'sony-tv',
    AUTHOR           => q{Christian Kühnel <christian.kuehnel@gmail.com>},
    VERSION		     => '0.1.0',
    #ABSTRACT_FROM    => 'lib/Venetian.pm',
    LICENSE          => 'Apache_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.010,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'JSON' => 0,
        'Test::More' => 0,
        'Test::MockModule' => 0,
        'Time::HiRes' => 0,
        'Test::Perl::Critic' => 0,
        'Test::Pod' => 0,
        'Devel::Cover::Report::Coveralls' => 0,
    },
    PREREQ_PM => {
        'experimental' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'fhem-venetian-*' },
);

#
 sub MY::postamble {
    return q{
ifndef FHEM_HOME
FHEM_HOME = ~fhem
endif

fhem: 
	$(NOECHO) $(ECHO) using fhem home directory: \"$(FHEM_HOME)\"
	$(CP) lib/SONYTV.pm $(FHEM_HOME)/FHEM/99_SONYTV.pm
	chown fhem:dialout $(FHEM_HOME)/FHEM/99_SONYTV.pm 

fhem_restart: fhem
	service fhem stop
	sleep 5
	service fhem start
}
};

