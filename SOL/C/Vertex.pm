package SOL::C::Vertex;

use strict;
use warnings;

use Class::XSAccessor::Array {
	accessors => {
		x => 0,
		y => 1,
		z => 2,
	},
};

sub new {
	my ($class, %args) = @_;
	bless([ @args{qw(x y z)} ], $class);
}

sub from_sol {
	my ($class, $reader) = @_;
	$class->new(
		x => $reader->get_float(1),
		y => $reader->get_float(1),
		z => $reader->get_float(1)
	);
}

sub to_sol {
	my ($self, $writer) = @_;
	$writer->put_float(@{$self});
}

1;

__END__

=head1 NAME

SOL::C::Vertex - s_vert

=head1 SYNOPSIS

 my $v = SOL::C::Vertex->from_sol($reader);
 my @nb_pos = ($v->x, $v->y, $v->z);

 my $v = SOL::C::Vertex->new(x => 2, y => 0.5, z => 2);
 $v->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Vertex is the exact representation of an s_vert structure. Its
coordinates are returned in the Neverball coordinate system.
