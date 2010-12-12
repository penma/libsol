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

use List::Util qw(sum);

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

# (de)serialization

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

sub to_sol_fh {
	my ($self, $fh) = @_;
	$self->{fh} = $fh;

	# write header: SOL magic + version
	$self->put_index(1280267183, 7);

	# object counts
	$self->put_index($self->{dictionary}->sol_count());
	for my $field (qw(
		material vertex edge side texture_coordinate
		geometry lump node path body
		item goal jump switch billboard
		ball viewpoint index
	)) {
		if (defined($self->{$field})) {
			$self->put_index(scalar @{$self->{$field}});
		} else {
			$self->put_index(0);
		}
	}

	# write objects
	$self->{dictionary}->to_sol($self);

	for my $field (qw(
		material vertex edge side texture_coordinate
		geometry lump node path body
		item goal jump switch billboard
		ball viewpoint
	)) {
		next if (!defined($self->{$field}));
		for my $elem (@{$self->{$field}}) {
			$elem->to_sol($self);
		}
	}

	$self->put_index(@{$self->{index}});

	# mapc-like information
	my $solid_lumps = 0;
	my $visib_geoms = 0;
	my $value_coins = 0;
	$value_coins = sum 0, map { $_->type eq "coin" ? $_->value : 0 } @{$self->{item}};
	printf("%s (%d/%d/\$%d)\n"
		. "  mtrl  vert  edge  side  texc  geom  lump  path  node  body\n"
		. "%6d%6d%6d%6d%6d%6d%6d%6d%6d%6d\n"
		. "  item  goal  view  jump  swch  bill  ball  char  dict  indx\n"
		. "%6d%6d%6d%6d%6d%6d%6d%6d%6d%6d\n",
		"stdin", $solid_lumps, $visib_geoms, $value_coins,
		(map { scalar @{$self->{$_} // []} } qw(
			material vertex edge side texture_coordinate
			geometry lump path node body
			item goal viewpoint jump switch billboard ball)),
		$self->{dictionary}->sol_count(),
		scalar @{$self->{index}},
	);
}

# index management

sub fetch_object {
	my ($self, $type, $idx) = @_;
	return $self->{$type}->[$idx];
}

sub store_object {
	my ($self, $type, $obj) = @_;

	# don't store the same (by reference) object twice.
	# except for lumps, which have to be stored sequentially
	if ($type ne "lump") {
		if (exists($self->{"_i_$type"}->{$obj})) {
			return $self->{"_i_$type"}->{$obj};
		}
	}

	my $i = scalar(@{$self->{$type} // []});
	push(@{$self->{$type}}, $obj);
	$self->{"_i_$type"}->{$obj} = $i if ($type ne "lump");
	return $i;
}

sub fetch_index {
	my ($self, $idx) = @_;
	return $self->{index}->[$idx];
}

sub store_index {
	my ($self, @idx) = @_;
	my $s = scalar(@{$self->{index}});
	push(@{$self->{index}}, @idx);
	return $s;
}

1;
