#!/usr/bin/perl -w
# -*- perl -*-

#
# Author: Slaven Rezic
#
# Copyright (C) 2013,2015,2016 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven@rezic.de
# WWW:  http://www.rezic.de/eserte/
#

use strict;
use Getopt::Long;
use autodie qw(:default);
use Org::Parser;

my $do_rev;
GetOptions("r" => \$do_rev)
    or die "usage: $0 [-r]\n";

my $file = shift
    or die "Please specify org file!";

my $orgp = Org::Parser->new;
# Org::Parser is too picky sometimes (returning errors like
# "Can't parse timestamp string: <2013-08-07 Mi 9:30 -15min>"
# and also slow, so manually find the interesting section using
# pure perl
open my $fh, "<:utf8", $file;
my $state = 0;
my $buf;
while(<$fh>) {
    if ($state == 0) {
	if (m{^\*.*all Berlin.pm meetings}) {
	    $state = 1;
	    $buf .= $_;
	}
    } elsif ($state == 1) {
	if (m{^\*}) {
	    last;
	} else {
	    $buf .= $_;
	}
    }
}

if (!length $buf) {
    die "Cannot find section!";
}

my $doc = $orgp->parse($buf);
my($table_elem) = $doc->find('Table');
my $table = $table_elem->as_aoa;

binmode STDOUT, ':utf8';
print <<'EOF';
#: encoding: utf-8
#: map: polar
#: 
EOF
my %column = do {
    my $col_i = 0;
    map { ($_, $col_i++) } @{ shift(@$table) };
};
my $wgs84_column = $column{"WGS84"}; die "No WGS84 column?" if !defined $wgs84_column;

if ($do_rev) {
    @$table = reverse @$table;
}

for my $row (@$table) {
    next if !$row->[$wgs84_column];
    my $coordinate = splice @$row, $wgs84_column, 1;
    my($lat,$lon) = split /,/, $coordinate;
    print join(" : ", @$row) . "\tX " . "$lon,$lat" . "\n";
}

__END__

=head1 NAME

pmmeetings2bbd.pl - convert Berlin.pm meetings to .gpx or .kml file

=head1 EXAMPLE

Create GPX file:

    pmmeetings2bbd.pl | ~/src/bbbike/miscsrc/bbd2gpx - >| /tmp/pm.gpx

Create KML file:

    pmmeetings2bbd.pl | ~/src/bbbike/miscsrc/bbd2kml - >| /tmp/pm.kml

Use option C<-r> to reverse the output.

=cut
