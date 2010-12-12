package SOL::Edge;

use strict;
use warnings;

use Class::XSAccessor::Array {
	accessors => {
		from => 0,
		to => 1,
	},
};

use SOL::C::Edge;

use SOL::Vertex;

sub new {
	my ($class, %args) = @_;
	bless([ $args{from}, $args{to} ], $class);
}

sub from_c {
	my ($class, $file, $cobj) = @_;
	$class->new(
		from => SOL::Vertex->from_c($file, $file->fetch_object("vertex", $cobj->vi)),
		to   => SOL::Vertex->from_c($file, $file->fetch_object("vertex", $cobj->vj))
	);
}

my %edge_cache;

sub to_c {
	my ($self, $file) = @_;

	my ($v0, $v1) = ($self->[0]->to_c($file), $self->[1]->to_c($file));
	if (!exists($edge_cache{"$v0/$v1"})) {
		$edge_cache{"$v0/$v1"} = SOL::C::Edge->new(
			vi => $v0, vj => $v1
		);
	}

	$file->store_object("edge", $edge_cache{"$v0/$v1"});
}

1;

__END__

=head1 NAME

SOL::C::Edge - s_edge

=head1 SYNOPSIS

 my $e = SOL::C::Edge->from_sol($reader);
 my $vi = $vertices[$e->vi];

 my $e = SOL::C::Edge->new(vi => 0, vj => 1);
 $e->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Edge is the exact representation of an s_edge structure. It
connects two vertices B<vi> and B<vj> which are identified by their
index in the SOL file.
