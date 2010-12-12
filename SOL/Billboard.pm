package SOL::Billboard;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		flags       => "flags",
		material    => "material",
		repeat_time => "repeat_time",
		distance    => "distance",
		width       => "width",
		height      => "height",
		rotate_x    => "rotate_x",
		rotate_y    => "rotate_y",
		rotate_z    => "rotate_z",
		p           => "p",
	},
	constructor => "new",
};

use SOL::C::Billboard;
use SOL::Util::Coordinates;

use SOL::Material;

sub from_c {
	my ($class, $file, $cobj) = @_;
	$class->new(
		flags       => $cobj->flags,
		material    => SOL::Material->from_c($file, $file->fetch_object("material", $cobj->material)),
		repeat_time => $cobj->repeat_time,
		distance    => $cobj->distance,
		width       => $cobj->width,
		height      => $cobj->height,
		rotate_x    => $cobj->rotate_x,
		rotate_y    => $cobj->rotate_y,
		rotate_z    => $cobj->rotate_z,
		p           => $cobj->p,
	);
}

sub to_c {
	my ($self, $file) = @_;
	$file->store_object("billboard", SOL::C::Billboard->new(
		flags       => $self->{flags},
		material    => $self->{material}->to_c($file),
		repeat_time => $self->{repeat_time},
		distance    => $self->{distance},
		width       => $self->{width},
		height      => $self->{height},
		rotate_x    => $self->{rotate_x},
		rotate_y    => $self->{rotate_y},
		rotate_z    => $self->{rotate_z},
		p           => $self->{p},
	));
}

1;

__END__

=head1 NAME

SOL::C::Side - s_side

=head1 SYNOPSIS

 my $s = SOL::C::Side->from_sol($reader);
 my @n = $s->normal;
 my $d = $s->distance;

 my $s = SOL::C::Side->new(normal => [ 0.70, 0.70, 0 ], distance => -5);
 $s->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Side is the exact representation of an s_side structure. The
coordinates of the normal vector are in the Neverball coordinate system.
