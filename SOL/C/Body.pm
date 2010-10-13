package SOL::C::Body;

use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	my $self = {
		path           => $args{path},
		node           => $args{node},
		lump_first     => $args{lump_first},
		lump_count     => $args{lump_count},
		geometry_first => $args{geometry_first},
		geometry_count => $args{geometry_count},
	};
	bless($self, $class);
}

sub from_sol {
	my ($class, $reader) = @_;

	my ($pi, $ni, $l0, $lc, $g0, $gc) = $reader->get_index(6);

	$class->new(
		path           => $pi >= 0 ? $pi : undef,
		node           => $ni,
		lump_first     => $lc > 0 ? $l0 : undef,
		lump_count     => $lc > 0 ? $lc : undef,
		geometry_first => $gc > 0 ? $g0 : undef,
		geometry_count => $gc > 0 ? $gc : undef,
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

	$writer->put_index(defined($self->{path}) and $self->{path} >= 0 ? $self->{path} : -1);
	$writer->put_index($self->{node});
	$writer->put_index(
		_x0xc_to_sol($self->{    lump_first}, $self->{    lump_count}),
		_x0xc_to_sol($self->{geometry_first}, $self->{geometry_count}),
	);
}

sub path {
	my ($self) = @_;
	$self->{path};
}

sub node {
	my ($self) = @_;
	$self->{node};
}

sub lump_first {
	my ($self) = @_;
	$self->{lump_first};
}

sub lump_count {
	my ($self) = @_;
	$self->{lump_count};
}

sub geometry_first {
	my ($self) = @_;
	$self->{geometry_first};
}

sub geometry_count {
	my ($self) = @_;
	$self->{geometry_count};
}

1;

__END__

=head1 NAME

SOL::C::Body - s_body

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Body is the exact representation of an s_body structure.
