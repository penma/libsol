package SOL::C::Jump;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		position => "position",
		target   => "target",
		radius   => "radius",
	},
	constructor => "new",
};

sub from_sol {
	my ($class, $reader) = @_;
	$class->new(
		position => [ $reader->get_float(3) ],
		target   => [ $reader->get_float(3) ],
		radius   => $reader->get_float(1),
	);
}

sub to_sol {
	my ($self, $writer) = @_;
	$writer->put_float(
		@{$self->{position}},
		@{$self->{target}},
		$self->{radius}
	);
}

1;

__END__

=head1 NAME

SOL::C::Jump - s_jump

=head1 SYNOPSIS

 my $j = SOL::C::Jump->from_sol($reader);
 if ($ball->in_circle(position => $j->position, radius => $j->radius)) {
     $ball->teleport($z->target);
 }

 my $j = SOL::C::Jump->new(
     position => [ 5, 0, 0 ],
     target   => [ 5, 2, 0 ],
     radius   => 0.25,
 );
 $j->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Jump is the exact representation of an s_jump structure. Its
coordinates are returned in the Neverball coordinate system.
