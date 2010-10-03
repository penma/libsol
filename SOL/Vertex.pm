package SOL::Vertex;

use strict;
use warnings;
use 5.010;

use SOL::Coordinates;

sub new {
	my ($class, $x, $y, $z) = @_;
	bless([ $x, $y, $z], $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	$class->new(SOL::Coordinates::neverball_to_radiant($sol->get_float(3)));
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(SOL::Coordinates::radiant_to_neverball(@{$self}));
}

1;

__END__

=head1 NAME

SOL::Vertex - vertex

=head1 SYNOPSIS

=head1 DESCRIPTION

This class uses the coordinate system of Radiant, not that of Neverball. In
Neverball, the Y and Z axis are swapped, and the Radiant-Y axis is inverted.
Quoting rlk, "if Radiant and Neverball disagree, then Radiant is correct".

