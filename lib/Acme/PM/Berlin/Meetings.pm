# -*- perl -*-

#
# Author: Slaven Rezic
#
# Copyright (C) 2010,2012,2015 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven@rezic.de
# WWW:  http://www.rezic.de/eserte/
#

package Acme::PM::Berlin::Meetings;

use strict;
our $VERSION = '201501.05';

use Exporter 'import'; # needs Exporter 5.57
our @EXPORT = qw(next_meeting);

use DateTime;
use DateTime::Event::Recurrence;

our $NORMAL_RECURRENCE;
our $ADVANCE_ONE_WEEK_RECURRENCE;

sub next_meeting {
    my $count = shift || 1;
    my $dt = DateTime->now; # (time_zone => 'local');
    map { $dt = next_meeting_dt($dt) } (1 .. $count);
}

sub next_meeting_dt {
    my $dt = shift;
    $NORMAL_RECURRENCE ||= do {
	# XXX week_start_day shouldn't be needed to be specified,
	# but see https://rt.cpan.org/Ticket/Display.html?id=54166
	my $der = DateTime::Event::Recurrence->monthly(weeks => -1, days => 'we', hours => 20, week_start_day => 'mo');
#	$der->set_time_zone('Europe/Berlin');
	$der;
    };

    my $prev_dt = $NORMAL_RECURRENCE->previous($dt);
    if (_within_xmas_time($prev_dt)) {
	my $january_dt = _advance_to_january_date($prev_dt);
	if ($dt < $january_dt) {
	    return $january_dt;
	}
    }

    my $next_dt = $NORMAL_RECURRENCE->next($dt);
    if (_within_xmas_time($next_dt)) {
	$next_dt = _advance_to_january_date($next_dt);
    }
    $next_dt;
}

sub _within_xmas_time {
    my $dt = shift;
    ($dt->month == 12 && $dt->day >= 24) || ($dt->month == 1 && $dt->day <= 2);
}

sub _advance_to_january_date {
    my $dt = shift;
    while(_within_xmas_time($dt)) {
	$ADVANCE_ONE_WEEK_RECURRENCE ||= do {
	    my $der = DateTime::Event::Recurrence->weekly(days => 'we', hours => 20, week_start_day => 'mo');
#	    $der->set_time_zone('Europe/Berlin');
	    $der;
	};
	$dt = $ADVANCE_ONE_WEEK_RECURRENCE->next($dt);
    }
    $dt;
}

1;

__END__

=head1 NAME

Acme::PM::Berlin::Meetings - get the next date of the Berlin PM meeting

=head1 SYNOPSIS

    use Acme::PM::Berlin::Meetings;
    next_meeting(1)

=head1 NOTES

This module knows about special Berlin.PM traditions like postponing
the December meeting to the first or second week in January.

=head1 AUTHOR

Slaven Rezic

=head1 SEE ALSO

L<Acme::PM::Barcelona::Meeting>, L<Acme::PM::Paris::Meetings>.

=cut
