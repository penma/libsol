package SOL::C::Edge;

use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	bless([ $args{vi}, $args{vj} ], $class);
}

sub from_sol {
	my ($class, $reader) = @_;
	$class->new(vi => $reader->get_index(1), vj => $reader->get_index(1));
}

sub to_sol {
	my ($self, $writer) = @_;
	$writer->put_index(@{$self});
}

sub vi {
	my ($self) = @_;
	$self->[0];
}

sub vj {
	my ($self) = @_;
	$self->[1];
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
