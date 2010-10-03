package SOL::Ball;

use strict;
use warnings;
use 5.010;

use SOL::Coordinates;

sub new {
	my ($class, %args) = @_;
	bless({
		position => $args{position},
		radius   => $args{radius},
	}, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my @p = $sol->get_float(3);
	my $r = $sol->get_float(1);

	$class->new(
		position => [ SOL::Coordinates::neverball_to_radiant(@p) ],
		radius   => $r,
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(SOL::Coordinates::radiant_to_neverball(@{$self->{position}}), $self->{radius});
}

1;

__END__

=head1 NAME

SOL::Item - s_item

=head1 SYNOPSIS

=head1 DESCRIPTION

