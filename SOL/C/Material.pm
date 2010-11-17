package SOL::C::Material;

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

use Readonly;

use SOL::Util::Flags;

Readonly my $path_max => 64;

Readonly my %mtrl_flags => (
	opaque      =>   1,
	transparent =>   2,
	reflective  =>   4,
	environment =>   8,
	additive    =>  16,
	clamped     =>  32,
	decal       =>  64,
	two_sided   => 128,
);

sub from_sol {
	my ($class, $reader) = @_;

	my @md = $reader->get_float(4);
	my @ma = $reader->get_float(4);
	my @ms = $reader->get_float(4);
	my @me = $reader->get_float(4);
	my $mh = $reader->get_float(1);
	my $flags = SOL::Util::Flags::decode($reader->get_index(), \%mtrl_flags);
	my $texture = unpack("Z*", $reader->get_raw($path_max));

	$class->new(
		diffuse           => \@md,
		ambient           => \@ma,
		specular          => \@ms,
		emission          => \@me,
		specular_exponent => $mh,
		texture           => $texture,
		flags             => $flags,
	);
}

sub to_sol {
	my ($self, $writer) = @_;

	$writer->put_float(
		@{$self->{diffuse}},
		@{$self->{ambient}},
		@{$self->{specular}},
		@{$self->{emission}},
		$self->{specular_exponent},
	);

	$writer->put_index(SOL::Util::Flags::encode($self->{flags}, \%mtrl_flags));

	$writer->put_raw(pack("Z$path_max", $self->{texture}));
}

1;

__END__

=head1 NAME

SOL::C::Material - s_mtrl

=head1 SYNOPSIS

 my $m = SOL::C::Material->from_sol($reader);
 display_image($m->texture);

 my $m = SOL::C::Material->new(...);
 $m->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Material is the exact representation of an s_mtrl structure.

