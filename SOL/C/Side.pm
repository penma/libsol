package SOL::C::Side;

use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	bless({ normal => $args{normal}, distance => $args{distance} }, $class);
}

sub from_sol {
	my ($class, $reader) = @_;
	my @n = $reader->get_float(3);
	my $d = $reader->get_float(1);
	$class->new(normal => [ @n ], distance => $d);
}

sub to_sol {
	my ($self, $writer) = @_;
	$writer->put_float(@{$self->{normal}}, $self->{distance});
}

sub normal {
	my ($self) = @_;
	@{$self->{normal}};
}

sub distance {
	my ($self) = @_;
	$self->{distance};
}

1;

__END__

=head1 NAME

SOL::C::Side - s_side

=head1 SYNOPSIS

 my $s = SOL::C::Side->from_sol($reader);
 my @n = $s->normal;
 my $d = $s->distance;

 my $s = SOL::C::Side->new(normal => [ 0.70, 0.70, 0 ], distance => -5);
 $s->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Side is the exact representation of an s_side structure. The
coordinates of the normal vector are in the Neverball coordinate system.
