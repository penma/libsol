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
		timer         => $args{timer},
		state         => $args{state},
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
		timer         => $t0,
		state         => $f0,
		invisible     => $invis,
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(SOL::Coordinates::radiant_to_neverball(@{$self->{position}}), $self->{radius});
	$sol->put_index($self->{path} // -1);
	$sol->put_float($self->{timer}, $self->{timer});
	$sol->put_index($self->{state}, $self->{state}, $self->{invisible});
}

1;

__END__

=head1 NAME

SOL::Item - s_item

=head1 SYNOPSIS

=head1 DESCRIPTION

