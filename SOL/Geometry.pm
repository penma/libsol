package SOL::Geometry;

use strict;
use warnings;
use 5.010;

use Class::XSAccessor {
	accessors => {
		material => "material",
	},
	getters => {
		vertices => "vertices",
		sides => "sides",
		texture_coordinates => "texture_coordinates",
	},
};

use SOL::C::Geometry;

use SOL::Vertex;
use SOL::Side;
use SOL::TextureCoordinate;
use SOL::Material;

sub new {
	my ($class, %args) = @_;
	bless({
		vertices            => $args{vertices} // [],
		sides               => $args{sides} // [],
		texture_coordinates => $args{texture_coordinates} // [],
		material            => $args{material},
	}, $class);
}

sub from_c {
	my ($class, $file, $cobj) = @_;
	my @cv = map $file->fetch_object("vertex",             $_), @{$cobj->vertices};
	my @cs = map $file->fetch_object("side",               $_), @{$cobj->sides};
	my @ct = map $file->fetch_object("texture_coordinate", $_), @{$cobj->texture_coordinates};
	$class->new(
		vertices            => [ map SOL::Vertex           ->from_c($file, $_), @cv ],
		sides               => [ map SOL::Side             ->from_c($file, $_), @cs ],
		texture_coordinates => [ map SOL::TextureCoordinate->from_c($file, $_), @ct ],
		material            => SOL::Material->from_c($file, $file->fetch_object("material", $cobj->material)),
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

