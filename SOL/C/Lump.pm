package SOL::C::Lump;

use strict;
use warnings;

use Readonly;

use SOL::Util::Flags;

Readonly my %lump_flags => (
	detail => 1,
);

sub new {
	my ($class, %args) = @_;
	my $self = {
		flags          => $args{flags},
		vertex_first   => $args{vertex_first},
		vertex_count   => $args{vertex_count},
		edge_first     => $args{edge_first},
		edge_count     => $args{edge_count},
		geometry_first => $args{geometry_first},
		geometry_count => $args{geometry_count},
		side_first     => $args{side_first},
		side_count     => $args{side_count},
	};
	bless($self, $class);
}

sub from_sol {
	my ($class, $reader) = @_;

	my ($flags, $v0, $vc, $e0, $ec, $g0, $gc, $s0, $sc) = $reader->get_index(9);

	$class->new(
		flags          => SOL::Util::Flags::decode($flags, \%lump_flags),
		vertex_first   => $vc > 0 ? $v0 : undef,
		vertex_count   => $vc > 0 ? $vc : undef,
		edge_first     => $ec > 0 ? $e0 : undef,
		edge_count     => $ec > 0 ? $ec : undef,
		geometry_first => $gc > 0 ? $g0 : undef,
		geometry_count => $gc > 0 ? $gc : undef,
		side_first     => $sc > 0 ? $s0 : undef,
		side_count     => $sc > 0 ? $sc : undef,
	);
}

sub _x0xc_to_sol {
	my ($x0, $xc) = @_;
	if (!defined($x0) or !defined($xc) or $x0 < 0 or $xc == 0) {
		(0, 0);
	} else {
		($x0, $xc);
	}
}

sub to_sol {
	my ($self, $writer) = @_;

	$writer->put_index(SOL::Util::Flags::encode($self->{flags}, \%lump_flags));
	$writer->put_index(
		_x0xc_to_sol($self->{  vertex_first}, $self->{  vertex_count}),
		_x0xc_to_sol($self->{    edge_first}, $self->{    edge_count}),
		_x0xc_to_sol($self->{geometry_first}, $self->{geometry_count}),
		_x0xc_to_sol($self->{    side_first}, $self->{    side_count}),
	);
}

sub flags {
	my ($self) = @_;
	@{$self->{flags}};
}

sub vertex_first {
	my ($self) = @_;
	$self->{vertex_first};
}

sub vertex_count {
	my ($self) = @_;
	$self->{vertex_count};
}

sub edge_first {
	my ($self) = @_;
	$self->{edge_first};
}

sub edge_count {
	my ($self) = @_;
	$self->{edge_count};
}

sub geometry_first {
	my ($self) = @_;
	$self->{geometry_first};
}

sub geometry_count {
	my ($self) = @_;
	$self->{geometry_count};
}

sub side_first {
	my ($self) = @_;
	$self->{side_first};
}

sub side_count {
	my ($self) = @_;
	$self->{side_count};
}

1;

__END__

=head1 NAME

SOL::C::Lump - s_lump

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Lump is the exact representation of an s_lump structure.
