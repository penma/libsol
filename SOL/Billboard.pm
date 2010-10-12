package SOL::Billboard;

use strict;
use warnings;
use 5.010;

use Readonly;

use SOL::Flags;
use SOL::Unresolved;

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
	my ($class, $sol) = @_;

	my ($fl, $mi) = $sol->get_index(2);
	my ($t, $d) = $sol->get_float(2);
	my @w  = $sol->get_float(3);
	my @h  = $sol->get_float(3);
	my @rx = $sol->get_float(3);
	my @ry = $sol->get_float(3);
	my @rz = $sol->get_float(3);
	my @p  = $sol->get_float(3);

	# XXX figure out if and how these coordinates should be transformed.. leaving asis for now
	$class->new(
		flags       => SOL::Flags::decode($fl, \%bill_flags),
		material    => SOL::Unresolved->new("material", $mi),
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
	my ($self, $sol) = @_;

	$sol->put_index(SOL::Flags::encode($self->{flags}, \%bill_flags));
	$sol->put_index($self->{material});
	$sol->put_float(
		$self->{repeat_time}, $self->{distance},
		@{$self->{width}}, @{$self->{height}},
		@{$self->{rotate_x}}, @{$self->{rotate_z}}, @{$self->{rotate_z}},
		@{$self->{p}},
	);
}

1;

__END__

=head1 NAME

SOL::Lump - s_lump

=head1 SYNOPSIS

=head1 DESCRIPTION

