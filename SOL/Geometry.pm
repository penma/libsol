package SOL::Geometry;

use strict;
use warnings;
use 5.010;

use SOL::Unresolved;

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
	my ($class, $sol) = @_;

	my $mi = $sol->get_index(1);
	my ($ti, $si, $vi, $tj, $sj, $vj, $tk, $sk, $vk) = $sol->get_index(9);

	$class->new(
		material            => SOL::Unresolved->new("material", $mi),
		texture_coordinates => [ map SOL::Unresolved->new("texture_coordinate", $_), $ti, $tj, $tk ],
		sides               => [ map SOL::Unresolved->new("side"              , $_), $si, $sj, $sk ],
		vertices            => [ map SOL::Unresolved->new("vertex"            , $_), $vi, $vj, $vk ],
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_index(
		$self->{material},
		(map { ($self->{texture_coordinates}->[$_], $self->{sides}->[$_], $self->{vertices}->[$_]) } 0..2),
	);
}

1;

__END__

=head1 NAME

SOL::Geometry - s_geom

=head1 SYNOPSIS

=head1 DESCRIPTION

