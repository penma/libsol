package SOL::Body;

use strict;
use warnings;
use 5.010;

use Data::Rmap qw(:types rmap_to rmap_ref);
use List::MoreUtils qw(uniq);
use Scalar::Util qw(blessed);

use SOL::Unresolved;

sub new {
	my ($class, %args) = @_;
	my $self = {
		path       => $args{path},
		node       => $args{node},
		geometries => $args{geometries} // [],
	};
	bless($self, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my ($pi, $ni, $l0, $lc, $g0, $gc) = $sol->get_index(6);

	$class->new(
		path       => SOL::Unresolved->new("path", $pi),
		node       => SOL::Unresolved->new("node", $ni),
		geometries => SOL::Unresolved->new("geometry", [ $g0 .. ($g0 + $gc - 1) ]),
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	die("s_body storage not implemented yet (must ask parent object about indxv values+indices for node,path,lump,geom)");
}

sub unwrap {
	my ($self) = @_;

	# walk the node tree and collect all lumps.
	my @lumps = uniq(
		rmap_ref {
			(blessed($_) and $_->isa("SOL::Lump"))
			? $_
			: ()
		} $self->{node},
	);

	# walk the body geom list and the lumps and dump all geometry.
	# remove geom lists from them while iterating over them
	my @geoms = uniq(@{$self->{geometries}}, map { @{delete $_->{geometries}} } @lumps);

	# remove now useless things
	delete($self->{node});
	delete($self->{lumps});
	delete($self->{geometries});

	# store new flat lists of collected items
	$self->{lumps}      = \@lumps;
	$self->{geometries} = \@geoms;
}

1;

__END__

=head1 NAME

SOL::Lump - s_lump

=head1 SYNOPSIS

=head1 DESCRIPTION

