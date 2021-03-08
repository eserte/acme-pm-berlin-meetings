# -*- perl -*-

#
# Author: Slaven Rezic
#
# Copyright (C) 2021 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven@rezic.de
# WWW:  http://www.rezic.de/eserte/
#

package Acme::PM::Berlin::Meetings::GeoJSONCombiner;

use strict;
use warnings;
our $VERSION = '0.01';

sub new { bless { c2x => {} }, shift }

sub add_first {
    my($self, %args) = @_;
    my $r = delete $args{rec};
    my $feature = delete $args{feature};
    die "Unhandled arguments: " . join(" ", %args) if %args;
    my $coordstring = join(" ", @{ $r->[Strassen::COORDS()] });
    $self->{c2x}->{$coordstring} = { feature => $feature, name => [ $r->[Strassen::NAME()] ] };
}

sub maybe_append {
    my($self, %args) = @_;
    my $r = delete $args{rec};
    die "Unhandled arguments: " . join(" ", %args) if %args;
    my $coordstring = join(" ", @{ $r->[Strassen::COORDS()] });
    if (my $old_val = $self->{c2x}->{$coordstring}) {
        push @{ $old_val->{name} }, $r->[Strassen::NAME()];
        return 1;
    }
    return 0;
}

sub flush {
    my($self) = @_;
    while(my($coordstring, $record) = each %{ $self->{c2x} }) {
	my $old_place_spec;
	my @new_name;
	for my $name (@{ $record->{name} }) {
	    my($date, $place, $street, $citypart, $persons) = split / : /, $name;
	    $persons = 'N/A' if !defined $persons || $persons =~ /^\s*$/;
	    my $new_place_spec = "<b>$place</b> : $street : $citypart";
	    if (!defined $old_place_spec || $old_place_spec ne $new_place_spec) {
		push @new_name, $new_place_spec;
		$old_place_spec = $new_place_spec;
	    }
	    push @new_name, "* $date : $persons";
	}
        $record->{feature}->{properties}->{name} = join("<br>\n", @new_name);
    }
}

1;

__END__
