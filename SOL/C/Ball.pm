package SOL::C::Ball;

use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	bless({ position => $args{position}, radius => $args{radius} }, $class);
}

sub from_sol {
	my ($class, $reader) = @_;
	$class->new(
		position => [ $reader->get_float(3) ],
		radius   => $reader->get_float(1),
	);
}

sub to_sol {
	my ($self, $writer) = @_;
	$writer->put_float(@{$self->{position}}, $self->{radius});
}

sub position {
	my ($self) = @_;
	@{$self->{position}};
}

sub radius {
	my ($self) = @_;
	$self->{radius};
}

1;

__END__

=head1 NAME

SOL::C::Ball - s_ball

=head1 SYNOPSIS

 my $u = SOL::C::Ball->from_sol($reader);

 my $u = SOL::C::Ball->new(position => [ 5, 0, 0 ], radius => 0.75);
 $u->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Ball is the exact representation of an s_ball structure. Its
coordinates are returned in the Neverball coordinate system.
