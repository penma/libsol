package SOL::Dictionary;

use strict;
use warnings;

sub from_sol {
	my ($class, $sol, $textlen, $dictlen) = @_;

	my $self = {};

	# first slurp the whole text section
	my $textv = $sol->get_raw($textlen);

	# then slurp the dictionary indices
	for my $i (0..$dictlen - 1) {
		my ($ai, $aj) = $sol->get_index(2);
		my $ti = unpack("Z*", substr($textv, $ai));
		my $tj = unpack("Z*", substr($textv, $aj));
		$self->{$ti} = $tj;
	}

	bless($self, $class);
}

sub to_sol {
	my ($self, $sol) = @_;
	die("s_dict serialization not implemented");
}

1;

__END__

=head1 NAME

SOL::Dictionary -

=head1 SYNOPSIS

=head1 DESCRIPTION

This module manages the text and dict sections of SOL files. Given the
lengths of the sections (from the header), it produces a hashref.

