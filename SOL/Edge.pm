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

sub new {
	my ($class, %args) = @_;
	bless([ $args{from}, $args{to} ], $class);
}

sub from_c {
	my ($class, $file, $cobj) = @_;
	$class->new(
		from => $file->vertex($cobj->vi),
		to   => $file->vertex($cobj->vj)
	);
}

sub to_c {
	my ($self, $file) = @_;
	$file->store_object("edge", SOL::C::Edge->new(
		vi => $self->[0]->to_c($file),
		vj => $self->[1]->to_c($file)
	));
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
