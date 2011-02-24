# -*- cperl -*-
use strict;
use ExtUtils::MakeMaker;

my $eumm_recent_enough = $ExtUtils::MakeMaker::VERSION >= 6.54;

if (!$eumm_recent_enough) {
    *MY::dist_core = sub {
	<<'EOF';
dist :
	$(NOECHO) $(ECHO) "Sorry, use a newer EUMM!"

EOF
    };
}

WriteMakefile(NAME =>         'Acme::PM::Berlin::Meetings',
	      VERSION_FROM => 'lib/Acme/PM/Berlin/Meetings.pm',
	      ($eumm_recent_enough ?
	       (META_ADD => { resources => { repository => 'git://github.com/eserte/acme-pm-berlin-meetings.git' },
			    }) : ()),
	      PREREQ_PM => { 'DateTime' => 0,
			     'DateTime::Event::Recurrence' => 0,
			     'Exporter' => 5.57,
			   },
	      EXE_FILES => ['script/berlin-pm'],
	     );
