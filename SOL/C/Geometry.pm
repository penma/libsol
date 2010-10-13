package SOL::C::Geometry;

use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	my $self = {
		material            => $args{material},
		texture_coordinates => $args{texture_coordinates},
		sides               => $args{sides},
		vertices            => $args{vertices},
	};
	bless($self, $class);
}

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

sub material {
	my ($self) = @_;
	$self->{material};
}

sub texture_coordinates {
	my ($self) = @_;
	@{$self->{texture_coordinates}};
}

sub sides {
	my ($self) = @_;
	@{$self->{sides}};
}

sub vertices {
	my ($self) = @_;
	@{$self->{vertices}};
}

1;

__END__

=head1 NAME

SOL::C::Geometry - s_geom

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Geometry is the exact representation of an s_geom structure.
