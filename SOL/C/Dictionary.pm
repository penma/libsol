package SOL::C::Dictionary;

use strict;
use warnings;

use List::Util qw(sum);

sub from_sol {
	my ($class, $reader, %args) = @_;

	my $self = {};

	# first slurp the whole text section
	my $textv = $reader->get_raw($args{textlen});

	# then slurp the dictionary indices
	for my $i (0..$args{dictlen} - 1) {
		my ($ai, $aj) = $reader->get_index(2);
		my $ti = unpack("Z*", substr($textv, $ai));
		my $tj = unpack("Z*", substr($textv, $aj));
		$self->{$ti} = $tj;
	}

	bless($self, $class);
}

sub sol_count {
	my ($self) = @_;
	my $textlen = sum map { length($_) + 1 } %{$self};
	return ($textlen, scalar keys %{$self});
}

sub to_sol {
	my ($self, $writer) = @_;
	my $av_text = "";
	my @dict;
	foreach my $key (keys %{$self}) {
		push(@dict, length($av_text), length($av_text) + length($key) + 1);
		$av_text .= pack("(Z*)*", $key, $self->{$key});
	}
	$writer->put_raw($av_text);
	$writer->put_index(@dict);
}

sub entries {
	my ($self) = @_;
	keys(%{$self});
}

sub entry {
	my ($self, $k, $v) = @_;
	if (@_ > 2) {
		$self->{$k} = $v;
	}
	$self->{$k};
}

1;

__END__

=head1 NAME

SOL::Dictionary -

=head1 SYNOPSIS

=head1 DESCRIPTION

This module manages the text and dict sections of SOL files. Given the
lengths of the sections (from the header), it produces a hashref.

