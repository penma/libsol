package SOL::C::Switch;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		position  => "position",
		radius    => "radius",
		path      => "path",
		timer     => "timer",
		state     => "state",
		invisible => "invisible",
	},
	constructor => "new",
};

sub from_sol {
	my ($class, $reader) = @_;

	my @p                = $reader->get_float(3);
	my $r                = $reader->get_float(1);
	my $pi               = $reader->get_index(1);
	my ($t0, $t)         = $reader->get_float(2);
	my ($f0, $f, $invis) = $reader->get_index(3);

	$class->new(
		position  => [ @p ],
		radius    => $r,
		path      => ($pi >= 0 ? $pi : undef),
		timer     => ($t0 != 0 ? $t0 : undef),
		state     => $f0,
		invisible => $invis,
	);
}

sub to_sol {
	my ($self, $writer) = @_;

	$writer->put_float(@{$self->{position}}, $self->{radius});
	$writer->put_index(defined($self->{path}) and $self->{path} >= 0 ? $self->{path} : -1);
	$writer->put_float(($self->{timer} // 0) x 2);
	$writer->put_index(($self->{state}) x 2);
	$writer->put_index($self->{invisible});
}

1;

__END__

=head1 NAME

SOL::C::Switch - s_swch

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Switch is the exact representation of an s_swch structure. Its
coordinates are returned in the Neverball coordinate system.
