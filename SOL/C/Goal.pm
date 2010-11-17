package SOL::C::Goal;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		position => "position",
		radius   => "radius",
	},
	constructor => "new",
};

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
