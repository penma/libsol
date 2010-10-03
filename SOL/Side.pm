package SOL::Side;

use strict;
use warnings;
use 5.010;

use SOL::Coordinates;

sub new {
	my ($class, %args) = @_;
	bless({ normal => $args{normal}, distance => $args{distance} }, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my @n = $sol->get_float(3);
	my $d = $sol->get_float(1);
	$class->new(normal => [SOL::Coordinates::neverball_to_radiant(@n), distance => $d);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(
		SOL::Coordinates::radiant_to_neverball(@{$self->{normal}}),
		$self->{distance},
	);
}

1;

__END__

=head1 NAME

SOL::Side - s_side

=head1 SYNOPSIS

=head1 DESCRIPTION

