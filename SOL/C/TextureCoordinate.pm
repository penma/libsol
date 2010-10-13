package SOL::C::TextureCoordinate;

use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	bless([ @args{qw(u v)} ], $class);
}

sub from_sol {
	my ($class, $reader) = @_;
	$class->new(
		u => $reader->get_float(1),
		v => $reader->get_float(1),
	);
}

sub to_sol {
	my ($self, $writer) = @_;
	$writer->put_float(@{$self});
}

sub u {
	my ($self) = @_;
	$self->[0];
}

sub v {
	my ($self) = @_;
	$self->[1];
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
