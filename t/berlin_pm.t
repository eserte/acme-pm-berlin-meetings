use strict;
use FindBin;
use Test::More tests => 3;

my $script = "$FindBin::RealBin/../blib/script/berlin-pm";

my $next_date = `$script`;
my $next_two_dates = `$script 2`;

for my $date ($next_date, (split /\n/, $next_two_dates)) {
    chomp $date;
    like $date, qr{^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$}, "$date looks like an ISO date";
}

__END__
