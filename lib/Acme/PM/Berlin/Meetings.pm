# -*- perl -*-

#
# Author: Slaven Rezic
#
# Copyright (C) 2010 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven@rezic.de
# WWW:  http://www.rezic.de/eserte/
#

package Acme::PM::Berlin::Meetings;

use strict;
our $VERSION = '201008.1602';

use Exporter 'import';
our @EXPORT = qw(next_meeting);

use DateTime;
use DateTime::Event::Recurrence;

our $NORMAL_RECURRENCE;
our $XMAS_FALLBACK_RECURRENCE;

sub next_meeting {
    my $count = shift || 1;
    my $dt = DateTime->now; # (time_zone => 'local');
    for (1 .. $count) {
	$dt = next_meeting_dt($dt);
	print $dt, "\n";
    }
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
    my $next_dt = $NORMAL_RECURRENCE->next($dt);
    if (($next_dt->month == 12 && $next_dt->day >= 24) ||
	($next_dt->month == 1  && $next_dt->day == 1)) {
	$XMAS_FALLBACK_RECURRENCE ||= do {
	    my $der = DateTime::Event::Recurrence->monthly(weeks =>  1, days => 'we', hours => 20, week_start_day => 'mo');
#	    $der->set_time_zone('Europe/Berlin');
	    $der;
	};
	$next_dt = $XMAS_FALLBACK_RECURRENCE->next($next_dt);
    }
    $next_dt;
}   

1;

__END__

=head1 NAME

Acme::PM::Berlin::Meetings - get the next date of the Berlin PM meeting

=head1 SYNOPSIS

    use Acme::PM::Berlin::Meetings;
    next_meeting(1)

=head1 AUTHOR

Slaven Rezic

=head1 SEE ALSO

L<Acme::PM::Barcelona::Meeting>, L<Acme::PM::Paris::Meetings>.

=cut
