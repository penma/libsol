package SOL::Lump;

use strict;
use warnings;
use 5.010;

use Class::XSAccessor {
	getters => {
		vertices => "vertices",
		edges => "edges",
		sides => "sides",
	},
};

use SOL::C::Lump;

use SOL::Vertex;
use SOL::Edge;
use SOL::Side;

sub new {
	my ($class, %args) = @_;
	bless({
		vertices            => $args{vertices} // [],
		edges               => $args{edges} // [],
		sides               => $args{sides} // [],
	}, $class);
}

sub from_c {
	my ($class, $file, $cobj) = @_;

	my ($v0, $vc, $e0, $ec, $s0, $sc) = (
		$cobj->vertex_first, $cobj->vertex_count,
		$cobj->edge_first,   $cobj->edge_count,
		$cobj->side_first,   $cobj->side_count,
	);

	my @cv = map $file->fetch_object("vertex", $file->fetch_index($_)), $v0 .. $v0 + $vc - 1;
	my @ce = map $file->fetch_object("edge",   $file->fetch_index($_)), $e0 .. $e0 + $ec - 1;
	my @cs = map $file->fetch_object("side",   $file->fetch_index($_)), $s0 .. $s0 + $sc - 1;

	$class->new(
		vertices => [ map SOL::Vertex->from_c($file, $_), @cv ],
		edges    => [ map SOL::Edge  ->from_c($file, $_), @ce ],
		sides    => [ map SOL::Side  ->from_c($file, $_), @cs ],
	);
}

sub to_c {
	my ($self, $file) = @_;

	$file->store_object("geometry", SOL::C::Geometry->new(
		vertices            => [ map $_->to_c($file), @{$self->{vertices}} ],
		sides               => [ map $_->to_c($file), @{$self->{sides}} ],
		texture_coordinates => [ map $_->to_c($file), @{$self->{texture_coordinates}} ],
		material            => $self->{material}->to_c($file),
	));
}

1;

__END__

=head1 NAME

SOL::Geometry - s_geom

=head1 SYNOPSIS

=head1 DESCRIPTION

