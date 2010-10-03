package SOL::Coordinates;

use strict;
use warnings;

sub radiant_to_neverball {
	my ($x, $y, $z) = @_;
	($x, $z, -$y);
}

sub neverball_to_radiant {
	my ($nx, $ny, $nz) = @_;
	($nx, -$nz, $ny);
}

1;
