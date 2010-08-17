# -*- cperl -*-
use strict;
use ExtUtils::MakeMaker;

eval {
    if ((getpwuid($<))[0] eq 'eserte' && $ExtUtils::MakeMaker::VERSION < 6.54) {
	warn <<EOF;
**********************************************************************
* WARNING:
* ExtUtils::MakeMaker too old. META.yml will be imcomplete
**********************************************************************
EOF
    }
};

WriteMakefile(NAME =>         'Acme::PM::Berlin::Meetings',
	      VERSION_FROM => 'lib/Acme/PM/Berlin/Meetings.pm',
	      ($ExtUtils::MakeMaker::VERSION >= 6.54 ?
	       (META_ADD => { resources => { repository => 'git://github.com/eserte/acme-pm-berlin-meetings.git' },
			    }) : ()),
	      PREREQ_PM => { 'DateTime' => 0,
			     'DateTime::Event::Recurrence' => 0,
			     'Exporter' => 5.57,
			   },
	      EXE_FILES => ['script/berlin-pm'],
	     );
