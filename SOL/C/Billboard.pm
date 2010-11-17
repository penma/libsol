package SOL::C::Billboard;

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

use Readonly;

use SOL::Util::Flags;

Readonly my %bill_flags => (
	edge     => 1,
	flat     => 2,
	additive => 4,
	noface   => 8,
);

sub from_sol {
	my ($class, $reader) = @_;

	my ($fl, $mi) = $reader->get_index(2);
	my ($t, $d) = $reader->get_float(2);
	my @w  = $reader->get_float(3);
	my @h  = $reader->get_float(3);
	my @rx = $reader->get_float(3);
	my @ry = $reader->get_float(3);
	my @rz = $reader->get_float(3);
	my @p  = $reader->get_float(3);

	$class->new(
		flags       => SOL::Util::Flags::decode($fl, \%bill_flags),
		material    => $mi,
		repeat_time => $t,
		distance    => $d,
		width       => \@w,
		height      => \@h,
		rotate_x    => \@rx,
		rotate_y    => \@ry,
		rotate_z    => \@rz,
		p           => \@p,
	);
}

sub to_sol {
	my ($self, $writer) = @_;

	$writer->put_index(SOL::Util::Flags::encode($self->{flags}, \%bill_flags));
	$writer->put_index($self->{material});
	$writer->put_float(
		$self->{repeat_time}, $self->{distance},
		@{$self->{width}}, @{$self->{height}},
		@{$self->{rotate_x}}, @{$self->{rotate_z}}, @{$self->{rotate_z}},
		@{$self->{p}},
	);
}

1;

__END__

=head1 NAME

SOL::C::Billboard - s_bill

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Billboard is the exact representation of an s_bill structure.
Its coordinates are returned in the Neverball coordinate system.
