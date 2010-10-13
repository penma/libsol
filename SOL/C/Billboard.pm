package SOL::C::Billboard;

use strict;
use warnings;

use Readonly;

use SOL::Util::Flags;

Readonly my %bill_flags => (
	edge     => 1,
	flat     => 2,
	additive => 4,
	noface   => 8,
);

sub new {
	my ($class, %args) = @_;
	my $self = {
		flags       => $args{flags},
		material    => $args{material},
		repeat_time => $args{repeat_time},
		distance    => $args{distance},
		width       => $args{width},
		height      => $args{height},
		rotate_x    => $args{rotate_x},
		rotate_y    => $args{rotate_y},
		rotate_z    => $args{rotate_z},
		p           => $args{p},
	};
	bless($self, $class);
}

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

	# XXX figure out if and how these coordinates should be transformed.. leaving asis for now
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

sub flags {
	my ($self) = @_;
	@{$self->{flags}};
}

sub material {
	my ($self) = @_;
	$self->{material};
}

sub repeat_time {
	my ($self) = @_;
	$self->{repeat_time};
}

sub distance {
	my ($self) = @_;
	$self->{distance};
}

sub width {
	my ($self) = @_;
	@{$self->{width}};
}

sub height {
	my ($self) = @_;
	@{$self->{height}};
}

sub rotate_x {
	my ($self) = @_;
	@{$self->{rotate_x}};
}

sub rotate_y {
	my ($self) = @_;
	@{$self->{rotate_y}};
}

sub rotate_z {
	my ($self) = @_;
	@{$self->{rotate_z}};
}
i
sub p {
	my ($self) = @_;
	@{$self->{p}};
}

1;

__END__

=head1 NAME

SOL::C::Billboard - s_bill

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Billboard is the exact representation of an s_bill structure.
Its coordinates are returned in the Neverball coordinate system.
