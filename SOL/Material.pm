package SOL::Material;

use strict;
use warnings;
use 5.010;

use IO::File;
use Readonly;

use SOL::Flags;

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

sub new {
	my ($class, %args) = @_;
	my $self = {
		diffuse           => $args{diffuse}  // [1.0, 1.0, 1.0, 1.0],
		ambient           => $args{ambient}  // [0.2, 0.2, 0.2, 0.2],
		specular          => $args{specular} // [0.0, 0.0, 0.0, 1.0],
		emission          => $args{emission} // [0.0, 0.0, 0.0, 1.0],
		specular_exponent => $args{specular_exponent} // 0,
		flags             => $args{flags}    // ["opaque"],
		texture           => $args{texture},
	};
	bless($self, $class);
}

sub from_mtrl {
	my ($class, $mtrl_name) = @_;
	my $fh = IO::File->new($mtrl_name, "r") or die("unable to open mtrl file '$mtrl_name': $!");

	my @md = split(/\s+/, $fh->getline());
	my @ma = split(/\s+/, $fh->getline());
	my @ms = split(/\s+/, $fh->getline());
	my @me = split(/\s+/, $fh->getline());
	my $mh = $fh->getline();
	my $flags = SOL::Flags::decode($fh->getline(), \%mtrl_flags);

	$class->new(
		diffuse           => \@md,
		ambient           => \@ma,
		specular          => \@ms,
		emission          => \@me,
		specular_exponent => $mh,
		texture           => $mtrl_name,
		flags             => $flags,
	);
}

sub from_sol {
	my ($class, $sol) = @_;

	my @md = $sol->get_float(4);
	my @ma = $sol->get_float(4);
	my @ms = $sol->get_float(4);
	my @me = $sol->get_float(4);
	my $mh = $sol->get_float(1);
	my $flags = SOL::Flags::decode($sol->get_index(), \%mtrl_flags);
	my $texture = unpack("Z*", $sol->get_raw($path_max));

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
	my ($self, $sol) = @_;

	$sol->put_float(
		@{$self->{diffuse}},
		@{$self->{ambient}},
		@{$self->{specular}},
		@{$self->{emission}},
		$self->{specular_exponent},
	);

	$sol->put_index(SOL::Flags::encode($self->{flags}, \%mtrl_flags));

	$sol->put_raw(pack("Z$path_max", $self->{texture}));
}

1;

__END__

=head1 NAME

SOL::Material - represents a material

=head1 SYNOPSIS

=head1 DESCRIPTION


