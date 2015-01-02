use strict;
use Test::More 'no_plan';

use Acme::PM::Berlin::Meetings;

{
    my @dts = next_meeting(1);
    is scalar(@dts), 1;
    isa_ok $dts[0], 'DateTime';
}

{
    my $now = DateTime->new(day => 1, month => 12, year => 2014, time_zone => 'Europe/Berlin');
    my $dt = Acme::PM::Berlin::Meetings::next_meeting_dt($now);
    is $dt, '2015-01-07T20:00:00';
}

{
    my $now = DateTime->new(day => 29, month => 12, year => 2014, time_zone => 'Europe/Berlin');
    my $dt = Acme::PM::Berlin::Meetings::next_meeting_dt($now);
    is $dt, '2015-01-07T20:00:00';
}

{
    my $now = DateTime->new(day => 7, month => 1, year => 2015, hour => 21, time_zone => 'Europe/Berlin');
    my $dt = Acme::PM::Berlin::Meetings::next_meeting_dt($now);
    is $dt, '2015-01-28T20:00:00';
}

{
    my $now = DateTime->new(day => 8, month => 1, year => 2013, time_zone => 'Europe/Berlin');
    my $dt = Acme::PM::Berlin::Meetings::next_meeting_dt($now);
    is $dt, '2013-01-09T20:00:00', 'RT #61077';
}

__END__
