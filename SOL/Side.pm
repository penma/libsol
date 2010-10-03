package SOL::Side;

use strict;
use warnings;
use 5.010;

sub new {
	my ($class, %args) = @_;
	bless({ normal => $args{normal}, distance => $args{distance} }, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my @n = $sol->get_float(3);
	my $d = $sol->get_float(1);
	$class->new(normal => [$n[0], -$n[2], $n[1]], distance => $d);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(
		 $self->{normal}->[0],
		 $self->{normal}->[2],
		-$self->{normal}->[1],
		$self->{distance},
	);
}

1;

__END__

=head1 NAME

SOL::Side - s_side

=head1 SYNOPSIS

=head1 DESCRIPTION

