package SOL::Vertex;

use strict;
use warnings;

use Class::XSAccessor::Array {
	accessors => {
		x => 0,
		y => 1,
		z => 2,
	},
};

use SOL::C::Vertex;
use SOL::Util::Coordinates;

sub new {
	my ($class, %args) = @_;
	bless([ @args{qw(x y z)} ], $class);
}

sub from_c {
	my ($class, $reader, $cobj) = @_;
	$class->new(SOL::Util::Coordinates::neverball_to_radiant(
		x => $cobj->x,
		y => $cobj->y,
		z => $cobj->z
	));
}

my %vert_cache;

sub to_c {
	my ($self, $file) = @_;

	my $cn = "$self->[0]/$self->[1]/$self->[2]";
	if (!exists($vert_cache{$cn})) {
		$vert_cache{$cn} = SOL::C::Vertex->new(SOL::Util::Coordinates::radiant_to_neverball(
			x => $self->[0],
			y => $self->[1],
			z => $self->[2]
		));
	}

	$file->store_object("vertex", $vert_cache{$cn});
}

1;

__END__

=head1 NAME

SOL::Vertex - vertex

=head1 SYNOPSIS

 my $v = SOL::C::Vertex->from_sol($reader);
 my @nb_pos = ($v->x, $v->y, $v->z);

 my $v = SOL::C::Vertex->new(x => 2, y => 0.5, z => 2);
 $v->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Vertex is the exact representation of an s_vert structure. Its
coordinates are returned in the Neverball coordinate system.
