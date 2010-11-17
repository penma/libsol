package SOL::C::Geometry;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		material            => "material",
		texture_coordinates => "texture_coordinates",
		sides               => "sides",
		vertices            => "vertices",
	},
	constructor => "new",
};

sub from_sol {
	my ($class, $reader) = @_;

	my $mi = $reader->get_index(1);
	my ($ti, $si, $vi, $tj, $sj, $vj, $tk, $sk, $vk) = $reader->get_index(9);

	$class->new(
		material            => $mi,
		texture_coordinates => [ $ti, $tj, $tk ],
		sides               => [ $si, $sj, $sk ],
		vertices            => [ $vi, $vj, $vk ],
	);
}

sub to_sol {
	my ($self, $writer) = @_;

	$writer->put_index(
		$self->{material},
		(map { ($self->{texture_coordinates}->[$_], $self->{sides}->[$_], $self->{vertices}->[$_]) } 0..2),
	);
}

1;

__END__

=head1 NAME

SOL::C::Geometry - s_geom

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Geometry is the exact representation of an s_geom structure.
