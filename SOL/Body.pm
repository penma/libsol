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
		foreach my $lump (map $file->fetch_object("lump", $_), $cobj->lump_first() .. $cobj->lump_first() + $cobj->lump_count() - 1) {
			next if (!defined($lump->geometry_first()));
			push(@geoms, map $file->fetch_object("geometry", $file->fetch_index($_)),
				$lump->geometry_first() .. $lump->geometry_first() + $lump->geometry_count() - 1
			);
		}
	}

	# 2. gv[iv[bp->g0..gc]]
	if (defined($cobj->geometry_first())) {
		push(@geoms, map $file->fetch_object("geometry", $file->fetch_index($_)),
			$cobj->geometry_first() .. $cobj->geometry_first() + $cobj->geometry_count() - 1
		);
	}

	$class->new(
		path => undef, # XXX
		lumps      => [ map SOL::Lump    ->from_c($file, $_), uniq @lumps ],
		geometries => [ map SOL::Geometry->from_c($file, $_), uniq @geoms ],
	);
}

sub to_c {
	my ($self, $file) = @_;

	$file->store_object("geometry", SOL::C::Geometry->new(
		vertices            => [ map $_->to_c($file), @{$self->{vertices}} ],
		sides               => [ map $_->to_c($file), @{$self->{sides}} ],
		texture_coordinates => [ map $_->to_c($file), @{$self->{texture_coordinates}} ],
		material            => $self->{material}->to_c($file),
	));
}

1;

__END__

=head1 NAME

SOL::Geometry - s_geom

=head1 SYNOPSIS

=head1 DESCRIPTION

