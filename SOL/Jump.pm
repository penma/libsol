package SOL::Jump;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		position => "position",
		target => "target",
		radius => "radius",
	},
	constructor => "new",
};

use SOL::C::Jump;
use SOL::Util::Coordinates;

sub from_c {
	my ($class, $file, $cobj) = @_;
	$class->new(
		position => [ SOL::Util::Coordinates::neverball_to_radiant(@{$cobj->position}) ],
		target   => [ SOL::Util::Coordinates::neverball_to_radiant(@{$cobj->target}) ],
		radius   => $cobj->radius
	);
}

sub to_c {
	my ($self, $file) = @_;
	$file->store_object("jump", SOL::C::Jump->new(
		position => [ SOL::Util::Coordinates::radiant_to_neverball(@{$self->{position}}) ],
		target   => [ SOL::Util::Coordinates::radiant_to_neverball(@{$self->{target}}) ],
		radius   => $self->{radius}
	));
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
