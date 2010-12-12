package SOL::Body;

use strict;
use warnings;
use 5.010;

use List::MoreUtils qw(uniq);

use Class::XSAccessor {
	accessors => {
		path => "path",
	},
	getters => {
		lumps => "lumps",
		geometries => "geometries",
	},
};

use SOL::C::Body;

use SOL::Geometry;
use SOL::Lump;

sub new {
	my ($class, %args) = @_;
	bless({
		path       => $args{path},
		lumps      => $args{lumps} // [],
		geometries => $args{geometries} // [],
	}, $class);
}

sub _node_lumps {
	my ($file, $cobj) = @_;
	my @lumps;

	if (defined($cobj->lump_first())) {
		push(@lumps, map $file->fetch_object("lump", $_),
			$cobj->lump_first() .. $cobj->lump_first() + $cobj->lump_count() - 1
		);
	}

	if (defined($cobj->node_fore())) {
		push(@lumps, _node_lumps($file, $file->fetch_object("node", $cobj->node_fore())));
	}

	if (defined($cobj->node_back())) {
		push(@lumps, _node_lumps($file, $file->fetch_object("node", $cobj->node_back())));
	}

	@lumps;
}

sub from_c {
	my ($class, $file, $cobj) = @_;
	my (@lumps, @geoms);

	# search lumps in nodes.
	# lv[bp->n*->l0..lc]
	@lumps = _node_lumps($file, $file->fetch_object("node", $cobj->node));

	# search geometries in body->lumps and body.
	# 1. gv[iv[lv[bp->l0..lc]->g0..gc]]
	if (defined($cobj->lump_first())) {
		my ($l0, $lc) = ($cobj->lump_first, $cobj->lump_count);

		foreach my $lump (map $file->fetch_object("lump", $_), $l0 .. $l0 + $lc - 1) {
			my ($g0, $gc) = ($lump->geometry_first, $lump->geometry_count);
			next if (!defined($g0));

			push(@geoms, map $file->fetch_object("geometry", $file->fetch_index($_)),
				$g0 .. $g0 + $gc - 1
			);
		}
	}

	# 2. gv[iv[bp->g0..gc]]
	if (defined($cobj->geometry_first())) {
		my ($g0, $gc) = ($cobj->geometry_first, $cobj->geometry_count);

		push(@geoms, map $file->fetch_object("geometry", $file->fetch_index($_)),
			$g0 .. $g0 + $gc - 1
		);
	}

	$class->new(
		path => undef, # XXX
		lumps      => [ map SOL::Lump    ->from_c($file, $_), uniq @lumps ],
		geometries => [ map SOL::Geometry->from_c($file, $_), uniq @geoms ],
	);
}

{ # XXX

package SOLDUMMY::Node;

sub to_c {
	my ($self, $file) = @_;
	# HAX
	my @li = map $_->to_c($file), @{$self->{lumps}};
	$file->store_object("node", SOL::C::Node->new(
		lump_first => $li[0],
		lump_count => scalar(@li),
	));
}


} # /XXX

sub to_c {
	my ($self, $file) = @_;

	# XXX
	$self->{node} = bless({ lumps => [ @{$self->{lumps}} ] }, "SOLDUMMY::Node");
	# /XXX

	my @ig = map $_->to_c($file), @{$self->{geometries}};

	$file->store_object("body", SOL::C::Body->new(
		path => undef, # XXX
		node           => $self->{node}->to_c($file),
		geometry_first => $file->store_index(@ig),
		geometry_count => scalar(@ig),
	));
}

1;

__END__

=head1 NAME

SOL::Geometry - s_geom

=head1 SYNOPSIS

=head1 DESCRIPTION

