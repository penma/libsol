package SOL::Vertex;

use strict;
use warnings;
use 5.010;

sub new {
	my ($class, $x, $y, $z) = @_;
	bless([ $x, $y, $z], $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my ($nx, $ny, $nz) = $sol->get_float(3);

	$class->new($nx, -$nz, $ny);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(
		 $self->[0],
		 $self->[2],
		-$self->[1],
	);
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

