package SOL::Item;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		position => "position",
		type => "type",
		value => "value",
	},
	constructor => "new",
};

use SOL::C::Item;
use SOL::Util::Coordinates;

sub from_c {
	my ($class, $file, $cobj) = @_;
	$class->new(
		position => [ SOL::Util::Coordinates::neverball_to_radiant(@{$cobj->position}) ],
		type     => $cobj->type,
		value    => $cobj->value,
	);
}

sub to_c {
	my ($self, $file) = @_;
	$file->store_object("item", SOL::C::Item->new(
		position => [ SOL::Util::Coordinates::radiant_to_neverball(@{$self->{position}}) ],
		type     => $self->{type},
		value    => $self->{value},
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
