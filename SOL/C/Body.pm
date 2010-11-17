package SOL::C::Body;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		path           => "path",
		node           => "node",
		lump_first     => "lump_first",
		lump_count     => "lump_count",
		geometry_first => "geometry_first",
		geometry_count => "geometry_count",
	},
	constructor => "new",
};

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

	$writer->put_index((defined($self->{path}) and $self->{path} >= 0) ? $self->{path} : -1);
	$writer->put_index($self->{node});
	$writer->put_index(
		_x0xc_to_sol($self->{    lump_first}, $self->{    lump_count}),
		_x0xc_to_sol($self->{geometry_first}, $self->{geometry_count}),
	);
}

1;

__END__

=head1 NAME

SOL::C::Body - s_body

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Body is the exact representation of an s_body structure.
