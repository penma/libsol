package SOL::TextureCoordinate;

use strict;
use warnings;

use Class::XSAccessor::Array {
	accessors => {
		u => 0,
		v => 1,
	},
};

use SOL::C::TextureCoordinate;

sub new {
	my ($class, %args) = @_;
	bless([ @args{qw(u v)} ], $class);
}

sub from_c {
	my ($class, $file, $cobj) = @_;
	$class->new(
		u => $cobj->u,
		v => $cobj->v
	);
}

sub to_c {
	my ($self, $file) = @_;
	$file->store_object("texture_coordinate", SOL::C::TextureCoordinate->new(
		u => $self->[0],
		v => $self->[1]
	));
}

1;

__END__

=head1 NAME

SOL::C::TextureCoordinate - s_texc

=head1 SYNOPSIS

 my $t = SOL::C::TextureCoordinate->from_sol($reader);
 glTexCoord2f($t->u, $t->v);

 my $t = SOL::C::TextureCoordinate->new(u => 0.0, v => 1.0);
 $t->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::TextureCoordinate is the exact representation of an s_texc structure.
