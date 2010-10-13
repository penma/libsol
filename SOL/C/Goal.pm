package SOL::C::Goal;

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

SOL::C::Goal - s_goal

=head1 SYNOPSIS

 my $z = SOL::C::Goal->from_sol($reader);
 move_to($z->position);

 my $z = SOL::C::Goal->new(position => [ 5, 0, 0 ], radius => 0.25);
 $z->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Goal is the exact representation of an s_goal structure. Its
coordinates are returned in the Neverball coordinate system.
