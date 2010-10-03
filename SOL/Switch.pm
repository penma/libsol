package SOL::Switch;

use strict;
use warnings;
use 5.010;

use SOL::Coordinates;
use SOL::Unresolved;

sub new {
	my ($class, %args) = @_;
	bless({
		position      => $args{position},
		radius        => $args{radius},
		path          => $args{path},
		timer_default => $args{timer_default},
		timer_current => $args{timer_current},
		state_default => $args{state_default},
		state_current => $args{state_current},
		invisible     => $args{invisible} // 0,
	}, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my @p = $sol->get_float(3);
	my $r = $sol->get_float(1);
	my $pi = $sol->get_index(1);
	my ($t0, $t) = $sol->get_float(2);
	my ($f0, $f, $invis) = $sol->get_index(3);

	$class->new(
		position      => [ SOL::Coordinates::neverball_to_radiant(@p) ],
		radius        => $r,
		path          => SOL::Unresolved->new("path", $pi),
		timer_default => $t0,
		timer_current => $t,
		state_default => $f0,
		state_current => $f,
		invisible     => $invis,
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	die("s_swch storage not implemented yet (must ask parent object about index for path)");
}

1;

__END__

=head1 NAME

SOL::Item - s_item

=head1 SYNOPSIS

=head1 DESCRIPTION

