package SOL::C::Node;

use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	my $self = {
		side           => $args{side},
		node_fore      => $args{node_fore},
		node_back      => $args{node_back},
		lump_first     => $args{lump_first},
		lump_count     => $args{lump_count},
	};
	bless($self, $class);
}

sub from_sol {
	my ($class, $reader) = @_;

	my ($si, $ni, $nj, $l0, $lc) = $reader->get_index(5);

	$class->new(
		side           => $si >= 0 ? $si : undef,
		node_fore      => $si >= 0 ? $ni : undef,
		node_back      => $si >= 0 ? $nj : undef,
		lump_first     => $lc > 0 ? $l0 : undef,
		lump_count     => $lc > 0 ? $lc : undef,
	);
}

sub to_sol {
	my ($self, $writer) = @_;

	if (defined($self->{side}) and $self->{side} >= 0) {
		$writer->put_index($self->{side}, $self->{node_fore}, $self->{node_back});
	} else {
		$writer->put_index(-1, -1, -1);
	}

	my ($l0, $lc) = ($self->{lump_first}, $self->{lump_count});
	if (defined($l0) and defined($lc) and $l0 >= 0 and $lc > 0) {
		$writer->put_index($l0, $lc);
	} else {
		$writer->put_index(0, 0);
	}
}

sub side {
	my ($self) = @_;
	$self->{side};
}

sub node_fore {
	my ($self) = @_;
	$self->{node_fore};
}

sub node_back {
	my ($self) = @_;
	$self->{node_back};
}

sub lump_first {
	my ($self) = @_;
	$self->{lump_first};
}

sub lump_count {
	my ($self) = @_;
	$self->{lump_count};
}

1;

__END__

=head1 NAME

SOL::C::Node - s_node

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Node is the exact representation of an s_node structure.
