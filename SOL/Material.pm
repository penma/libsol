package SOL::Material;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		diffuse           => "diffuse",
		ambient           => "ambient",
		specular          => "specular",
		emission          => "emission",
		specular_exponent => "specular_exponent",
		flags             => "flags",
		texture           => "texture",
	},
	constructor => "new",
};

use SOL::C::Material;

sub from_c {
	my ($class, $file, $cobj) = @_;
	$class->new(
		diffuse           => $cobj->diffuse,
		ambient           => $cobj->ambient,
		specular          => $cobj->specular,
		emission          => $cobj->emission,
		specular_exponent => $cobj->specular_exponent,
		flags             => $cobj->flags,
		texture           => $cobj->texture,
	);
}

sub to_c {
	my ($self, $file) = @_;
	$file->store_object("material", SOL::C::Material->new(
		diffuse           => $self->{diffuse},
		ambient           => $self->{ambient},
		specular          => $self->{specular},
		emission          => $self->{emission},
		specular_exponent => $self->{specular_exponent},
		flags             => $self->{flags},
		texture           => $self->{texture},
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
