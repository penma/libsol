package SOL::C::Item;

use strict;
use warnings;

use Class::XSAccessor {
	accessors => {
		position => "position",
		type     => "type",
		value    => "value",
	},
	constructor => "new",
};

use List::MoreUtils qw(first_index);
use Readonly;

Readonly my @item_types => (qw(none coin grow shrink));

sub from_sol {
	my ($class, $reader) = @_;

	my @p = $reader->get_float(3);
	my ($t, $v) = $reader->get_index(2);

	$class->new(
		position => [ @p ],
		type     => $item_types[$t],
		value    => $v,
	);
}

sub to_sol {
	my ($self, $writer) = @_;

	$writer->put_float(@{$self->{position}});
	$writer->put_index(first_index(sub { $_ eq $self->{type} }, @item_types), $self->{value});
}

1;

__END__

=head1 NAME

SOL::C::Item - s_item

=head1 SYNOPSIS

 my $h = SOL::C::Item->from_sol($reader);
 $money += $h->value if ($h->type eq "coin");

 my $h = SOL::C::Item->new(position => [ 2, 0, 0.5 ], type => "coin", value => 5);
 $h->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Item is the exact representation of an s_item structure. Its
coordinates are returned in the Neverball coordinate system.
