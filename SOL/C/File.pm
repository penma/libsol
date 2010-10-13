package SOL::C::File;

use strict;
use warnings;

use SOL::C::Dictionary;
use SOL::C::Material;
use SOL::C::Vertex;
use SOL::C::Edge;
use SOL::C::Side;
use SOL::C::TextureCoordinate;
use SOL::C::Geometry;
use SOL::C::Lump;
use SOL::C::Node;
use SOL::C::Path;
use SOL::C::Body;
use SOL::C::Item;
use SOL::C::Goal;
use SOL::C::Jump;
use SOL::C::Switch;
use SOL::C::Billboard;
use SOL::C::Ball;
use SOL::C::Viewpoint;

# SOL file format operations

sub get_raw {
	my ($self, $count) = @_;
	read($self->{fh}, my $buf, $count);
	return $buf;
}

sub get_index {
	my ($self, $count) = @_;
	$count //= 1;
	return unpack("l<*", $self->get_raw(4 * $count));
}

sub get_float {
	my ($self, $count) = @_;
	$count //= 1;
	return unpack("f<*", $self->get_raw(4 * $count));
}

sub put_raw {
	my ($self, $value) = @_;
	$self->{fh}->print($value);
}

sub put_index {
	my ($self, @values) = @_;
	$self->put_raw(pack("l<*", @values));
}

sub put_float {
	my ($self, @values) = @_;
	$self->put_raw(pack("f<*", @values));
}

# accessors

sub sol_version {
	my ($self) = @_;
	$self->{version};
}

# stuff..?

sub from_sol_fh {
	my ($class, $fh) = @_;
	my $self = bless({ fh => $fh }, $class);

	# read header
	($self->{magic}, $self->{version}) = $self->get_index(2);

	if ($self->{magic} != 1280267183) {
		die("This does not look like a SOL file");
	}

	# load the index
	my %counts;
	for my $field (qw(
		text dictionary
		material vertex edge side texture_coordinate
		geometry lump node path body
		item goal jump switch billboard
		ball viewpoint index
	)) {
		$counts{$field} = $self->get_index(1);
	}

	$self->{dictionary} = SOL::C::Dictionary->from_sol($self, textlen => $counts{text}, dictlen => $counts{dictionary});

	print STDERR "SOL reading objects:";
	for my $field (
		[ material           => "SOL::C::Material" ],
		[ vertex             => "SOL::C::Vertex" ],
		[ edge               => "SOL::C::Edge" ],
		[ side               => "SOL::C::Side" ],
		[ texture_coordinate => "SOL::C::TextureCoordinate" ],
		[ geometry           => "SOL::C::Geometry" ],
		[ lump               => "SOL::C::Lump" ],
		[ node               => "SOL::C::Node" ],
		[ path               => "SOL::C::Path" ],
		[ body               => "SOL::C::Body" ],
		[ item               => "SOL::C::Item" ],
		[ goal               => "SOL::C::Goal" ],
		[ jump               => "SOL::C::Jump" ],
		[ switch             => "SOL::C::Switch" ],
		[ billboard          => "SOL::C::Billboard" ],
		[ ball               => "SOL::C::Ball" ],
		[ viewpoint          => "SOL::C::Viewpoint" ],
	) {
		print STDERR " $field->[0]    %";
		$self->{$field->[0]} = [ map {
			print STDERR sprintf("\b\b\b\b%3d%%", 100 * $_ / $counts{$field->[0]});
			$field->[1]->from_sol($self)
		} 1..$counts{$field->[0]} ];
		print STDERR "\b\b\b\b\b     \b\b\b\b\b";
	}

	$self->{index} = [ $self->get_index($counts{index}) ];

	print STDERR ".\n";

	# delete unneeded fields
	delete($self->{fh});

	print STDERR "done loading\n";

	$self;
}

1;

__END__

package SOL::Writer;

use strict;
use warnings;
use 5.010;

use Data::Dump;
use Data::Rmap qw(:types rmap_to rmap_ref);
use List::Util qw(min);
use List::MoreUtils qw(first_index);
use Scalar::Util qw(blessed);

use SOL::Dictionary;
use SOL::Material;
use SOL::Vertex;
use SOL::Edge;
use SOL::Side;
use SOL::TextureCoordinate;
use SOL::Geometry;
use SOL::Lump;
use SOL::Node;
use SOL::Path;
use SOL::Body;
use SOL::Item;
use SOL::Goal;
use SOL::Jump;
use SOL::Switch;
use SOL::Billboard;
use SOL::Ball;
use SOL::View;
use SOL::Index;

# SOL file format operations
sub put_raw {
	my ($self, $value) = @_;
	$self->{fh}->print($value);
}

sub put_index {
	my ($self, @values) = @_;
	$self->put_raw(pack("L<*", @values));
}

sub put_float {
	my ($self, @values) = @_;
	$self->put_raw(pack("f<*", @values));
}

# stuff..?

sub add_obj {
	my ($self, $type, $obj) = @_;
	# TODO also deep compare objects
	#my $i = first_index { $_ == $obj } @{$self->{$type}};
	my $i = $self->{"o_$type"}->{"$obj"} // -1;
	if ($i < 0) {
		push(@{$self->{$type}}, $obj);
		$i = @{$self->{$type}} - 1;
		$self->{"o_$type"}->{"$obj"} = $i;
	}
	return $i;
}

sub add_idx {
	my ($self, @v) = @_;
	my ($x0, $xc) = (scalar @{$self->{index}}, scalar @v);
	push(@{$self->{index}}, @v);
	return ($x0, $xc);
}

sub store {
	my ($class, $sol, $fh) = @_;
	my $self = bless({ sol => $sol, fh => $fh }, $class);

	# put objects into flat lists, and replace them with indices.
	# final index lists will be built later, though

	# add a dummy first vertex. it will later be replaced with the lowest vertex
	# neverball uses the very first vertex as the fallout point
	$self->{vertex} = [ undef ];

	my @pathnames = keys(%{$self->{sol}->{path}});
	@{$self->{path}} = map { my $o = $_; bless({
		position    => $_->{position},
		orientation => $_->{orientation},
		travel_time => $_->{travel_time},
		enable      => $_->{enable},
		smooth      => $_->{smooth},
		flags       => $_->{flags},
		next_path   => defined($_->{next_path}) ? first_index { $_ eq $o->{next_path} } @pathnames : -1,
	}, "SOL::Path") } values %{$self->{sol}->{path}};
	@{$self->{switch}} = map { my $o = $_; bless({
		position  => $_->{position},
		radius    => $_->{radius},
		timer     => $_->{timer},
		state     => $_->{state},
		invisible => $_->{invisible},
		path      => defined($_->{path}) ? first_index { $_ eq $o->{path} } @pathnames : -1,
	}, "SOL::Switch") } @{$self->{sol}->{switch}};

	@{$self->{body}} = map { my $o = $_; bless({
		geometries => [ map { $self->add_obj("geometry", bless({
			vertices            => [ map { $self->add_obj("vertex",             $_) } @{$_->{vertices}} ],
			sides               => [ map { $self->add_obj("side",               $_) } @{$_->{sides}} ],
			texture_coordinates => [ map { $self->add_obj("texture_coordinate", $_) } @{$_->{texture_coordinates}} ],
			material            =>         $self->add_obj("material", $_->{material}),
		}, "SOL::Geometry")) } @{$_->{geometries}} ],
		lumps => [ map { $self->add_obj("lump", bless({
			vertices => [ map { $self->add_obj("vertex", $_) } @{$_->{vertices}} ],
			sides    => [ map { $self->add_obj("side",   $_) } @{$_->{sides}} ],
			edges    => [ map { $self->add_obj("edge", bless([ map { $self->add_obj("vertex", $_) } @{$_} ], "SOL::Edge")) } @{$_->{edges}} ],
			flags    => $_->{flags},
		}, "SOL::Lump")) } @{$_->{lumps}} ],
		path      => defined($_->{path}) ? first_index { $_ eq $o->{path} } @pathnames : -1,
	}, "SOL::Body") } @{$self->{sol}->{body}};

	@{$self->{ball}} = @{$self->{sol}->{ball}};
	@{$self->{goal}} = @{$self->{sol}->{goal}};
	@{$self->{item}} = @{$self->{sol}->{item}};
	@{$self->{jump}} = @{$self->{sol}->{jump}};
	@{$self->{view}} = @{$self->{sol}->{view}};

	$self->{dictionary} = $self->{sol}->{dictionary};

	@{$self->{billboard}} = map { bless({
		flags       => $_->{flags},
		repeat_time => $_->{repeat_time},
		distance    => $_->{distance},
		width       => $_->{width},
		height      => $_->{height},
		rotate_x    => $_->{rotate_x},
		rotate_y    => $_->{rotate_y},
		rotate_z    => $_->{rotate_z},
		p           => $_->{p},
		material    => $self->add_obj("material", $_->{material}),
	}, "SOL::Billboard") } @{$self->{sol}->{billboard}};

	delete($self->{sol});

	# now find out lowest z and update the vertex.
	shift(@{$self->{vertex}});
	unshift(@{$self->{vertex}}, SOL::Vertex->new(0, 0, min map { $_->[2] } @{$self->{vertex}}));

	# TODO: do actual BSP here.
	my $ni = 0;
	foreach my $body (@{$self->{body}}) {
		$body->{node} = $ni;
		$self->{node}->[$ni] = bless({
			node_i => -1,
			node_j => -1,
			side   => -1,
			lumps  => [ @{$body->{lumps}} ],
		}, "SOL::Node");
		$ni++;
	}

	# TODO: make sure that these elements are in order, because they are NOT
	# resolved over the index vector:
	# body->lumps, node->lumps

	# build the index
	$self->{index} = bless([], "SOL::Index");
	foreach my $lump (@{$self->{lump}}) {
		$lump->{vertices} = [ $self->add_idx(@{$lump->{vertices}}) ];
		$lump->{edges}    = [ $self->add_idx(@{$lump->{edges}}) ];
		$lump->{sides}    = [ $self->add_idx(@{$lump->{sides}}) ];
	}
	foreach my $body (@{$self->{body}}) {
		$body->{geometries} = [ $self->add_idx(@{$body->{geometries}}) ];
	}

	# write header: SOL magic + version
	$self->put_index(1280267183, 7);

	# object counts
	$self->put_index($self->{dictionary}->sol_count());
	for my $field (qw(
		material vertex edge side texture_coordinate
		geometry lump node path body
		item goal jump switch billboard
		ball view index
	)) {
		$self->put_index(scalar @{$self->{$field}});
	}

	# write objects
	$self->{dictionary}->to_sol($self);

	for my $field (qw(
		material vertex edge side texture_coordinate
		geometry lump node path body
		item goal jump switch billboard
		ball view
	)) {
		for my $elem (@{$self->{$field}}) {
			$elem->to_sol($self);
		}
	}

	$self->{index}->to_sol($self);

	# mapc-like information
	my $solid_lumps = 0;
	my $visib_geoms = 0;
	my $value_coins = 0;
	printf("%s (%d/%d/\$%d)\n"
		. "  mtrl  vert  edge  side  texc  geom  lump  path  node  body\n"
		. "%6d%6d%6d%6d%6d%6d%6d%6d%6d%6d\n"
		. "  item  goal  view  jump  swch  bill  ball  char  dict  indx\n"
		. "%6d%6d%6d%6d%6d%6d%6d%6d%6d%6d\n",
		"stdin", $solid_lumps, $visib_geoms, $value_coins,
		(map { scalar @{$self->{$_}} } qw(
			material vertex edge side texture_coordinate
			geometry lump path node body
			item goal view jump switch billboard ball)),
		$self->{dictionary}->sol_count(),
		scalar @{$self->{index}},
	);
}

1;
