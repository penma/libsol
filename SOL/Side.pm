package SOL::Side;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		normal => "normal",
		distance => "distance",
	},
	constructor => "new",
};

use SOL::C::Side;
use SOL::Util::Coordinates;

sub from_c {
	my ($class, $file, $cobj) = @_;
	$class->new(
		normal   => [ SOL::Util::Coordinates::neverball_to_radiant(@{$cobj->normal}) ],
		distance => $cobj->distance
	);
}

my %side_cache;

sub to_c {
	my ($self, $file) = @_;

	my $cn = "@{$self->{normal}}/$self->{distance}";
	if (!exists($side_cache{$cn})) {
		$side_cache{$cn} = SOL::C::Side->new(
				normal   => [ SOL::Util::Coordinates::radiant_to_neverball(@{$self->{normal}}) ],
				distance => $self->{distance}
			);
	}

	$file->store_object("side", $side_cache{$cn});
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
