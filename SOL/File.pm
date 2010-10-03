package SOL::File;

use strict;
use warnings;
use 5.010;

sub new {
	my ($class, $fh) = @_;
	my $self = { fh => $fh };
	bless($self, $class);
}

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

sub put_raw {
	my ($self, $value) = @_;
	$self->{fh}->print $value;
}

sub put_index {
	my ($self, @values) = @_;
	$self->put_raw(pack("L<*", @values));
}

sub put_float {
	my ($self, @values) = @_;
	$self->put_raw(pack("f<*", @values));
}

1;
