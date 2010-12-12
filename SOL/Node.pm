package SOL::Node;

use strict;
use warnings;
use 5.010;

use SOL::C::Node;

sub new {
	my ($class, %args) = @_;
	bless({
		lumps => $args{lumps},
	}, $class);
}

sub to_c {
	my ($self, $file) = @_;

	my %params;

	if (@{$self->{lumps}}) {
		# store lumps.
		# note that the lumps have to be stored sequentially in the file.
		# unlike all other objects, lumps are not resolved through the index
		# vector.
		# so we just assume that they are stored sequentially, and, to be
		# extra safe, validate that this is indeed the case.
		# at least mapc doesn't seem to ensure this either.
		my @li = map $_->to_c($file), @{$self->{lumps}};

		# die if for some reason the lump indices are not adjacent
		for my $x (1 .. @li - 1) {
			if ($li[$x] != $li[$x - 1] + 1) {
				die("Indices of lumps are not adjacent. This should not happen.");
			}
		}

		$params{lump_first} = $li[0];
		$params{lump_count} = scalar(@li);
	}

	$file->store_object("node", SOL::C::Node->new(%params));
}

1;

__END__

=head1 NAME

SOL::Geometry - s_geom

=head1 SYNOPSIS

=head1 DESCRIPTION

