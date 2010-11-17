package SOL::C::Node;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		side       => "side",
		node_fore  => "node_fore",
		node_back  => "node_back",
		lump_first => "lump_first",
		lump_count => "lump_count",
	},
	constructor => "new",
};

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

1;

__END__

=head1 NAME

SOL::C::Node - s_node

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Node is the exact representation of an s_node structure.
