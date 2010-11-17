package SOL::Util::Coordinates;

use strict;
use warnings;

sub radiant_to_neverball {
	if (@_ == 6) {
		my %r = @_;
		return (x => $r{x}, y => $r{z}, z => -$r{y});
	} else {
		my ($x, $y, $z) = @_;
		return ($x, $z, -$y);
	}
}

sub neverball_to_radiant {
	if (@_ == 6) {
		my %n = @_;
		return (x => $n{x}, y => -$n{z}, z => $n{y});
	} else {
		my ($nx, $ny, $nz) = @_;
		return ($nx, -$nz, $ny);
	}
}

1;
