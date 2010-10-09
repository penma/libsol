package SOL::Reader;

use strict;
use warnings;
use 5.010;

use Data::Dumper;
use Data::Rmap qw(:types rmap_to);
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

sub get_raw {
	my ($self, $count) = @_;
	read($self->{fh}, my $buf, $count);
	return $buf;
}

sub get_index {
	my ($self, $count) = @_;
	$count //= 1;
	return unpack("L<*", $self->get_raw(4 * $count));
}

sub get_float {
	my ($self, $count) = @_;
	$count //= 1;
	return unpack("f<*", $self->get_raw(4 * $count));
}

# accessors

sub version {
	my ($self) = @_;
	$self->{version};
}

# stuff..?

sub load {
	my ($class, $fh) = @_;
	my $self = bless({ fh => $fh }, $class);

	# read header
	# TODO verify header
	($self->{magic}, $self->{version}) = $self->get_index(2);

	# load the index
	my %counts;
	for my $field (qw(
		text dictionary
		material vertex edge side texture_coordinate
		geometry lump node path body
		item goal jump switch billboard
		ball view index
	)) {
		$counts{$field} = $self->get_index(1);
	}

	$self->{dictionary} = SOL::Dictionary->from_sol($self, $counts{text}, $counts{dictionary});

	for my $field (
		[ material => "SOL::Material" ],
		[ vertex   => "SOL::Vertex" ],
		[ edge     => "SOL::Edge" ],
		[ side     => "SOL::Side" ],
		[ texture_coordinate => "SOL::TextureCoordinate" ],
		[ geometry => "SOL::Geometry" ],
		[ lump     => "SOL::Lump" ],
		[ node     => "SOL::Node" ],
		[ path     => "SOL::Path" ],
		[ body     => "SOL::Body" ],
		[ item     => "SOL::Item" ],
		[ goal     => "SOL::Goal" ],
		[ jump     => "SOL::Jump" ],
		[ switch   => "SOL::Switch" ],
		[ billboard=> "SOL::Billboard" ],
		[ ball     => "SOL::Ball" ],
		[ view     => "SOL::View" ],
	) {
		$self->{$field->[0]} = [ map $field->[1]->from_sol($self), 1..$counts{$field->[0]} ];
	}

	$self->{index} = SOL::Index->from_sol($self, $counts{index});

	# resolve references
	rmap_to {
		if (blessed($_) and $_->isa("SOL::Unresolved")) {
			$_ = $_->resolve($self);
		}
	} ALL, $self;

	# flatten the BSP structure
	foreach my $body (@{$self->{body}}) {
		$body->unwrap();
	}

	# convert paths to path names.
	# this is about the only thing in SOL that would be insane with references.
	# TODO this could be written more nicely if Data::Rmap treated cyclic
	# references like Data::Walk
	my $work_path;
	$work_path = sub {
		my ($path) = @_;
		return undef if (!defined($path));
		if (my ($r) = grep { $self->{_path}->{$_} == $path } keys(%{$self->{_path}})) {
			return $r;
		}
		my $id = "path" . scalar(keys(%{$self->{_path}}));
		$self->{_path}->{$id} = $path;
		($path->{next_path}) = $work_path->($path->{next_path});
		return $id;
	};
	foreach my $ref (@{$self->{body}}, @{$self->{switch}}) {
		($ref->{path}) = $work_path->($ref->{path});
	}

	# delete all superfluous lists (all these elements are referenced through
	# a s_body)
	delete($self->{material});
	delete($self->{vertex});
	delete($self->{edge});
	delete($self->{side});
	delete($self->{texture_coordinate});
	delete($self->{geometry});
	delete($self->{lump});
	delete($self->{node});
	delete($self->{index});
	delete($self->{path});

	$self->{path} = $self->{_path};
	delete($self->{_path});

	# delete other unneeded fields
	delete($self->{fh});

	$self;
}

1;
