package SOL::Node;

use strict;
use warnings;
use 5.010;

use SOL::Unresolved;

sub new {
	my ($class, %args) = @_;
	my $self = {
		side   => $args{side},
		node_i => $args{node_i},
		node_j => $args{node_j},
		lumps  => $args{lumps} // [],
	};
	bless($self, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my ($si, $ni, $nj, $l0, $lc) = $sol->get_index(5);

	$class->new(
		side   => SOL::Unresolved->new("side", $si),
		node_i => SOL::Unresolved->new("node", $ni),
		node_j => SOL::Unresolved->new("node", $nj),
		lumps  => SOL::Unresolved->new("lump", [ $l0 .. ($l0 + $lc - 1) ]),
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	die("s_node storage not implemented yet (must ask parent object about indxv values+indices for side,nodei/j,lumps)");
}

1;

__END__

=head1 NAME

SOL::Lump - s_lump

=head1 SYNOPSIS

=head1 DESCRIPTION

