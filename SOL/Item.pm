package SOL::Item;

use strict;
use warnings;
use 5.010;

use List::MoreUtils qw(first_index);
use Readonly;

use SOL::Coordinates;

Readonly my @item_types => (qw(none coin grow shrink));

sub new {
	my ($class, %args) = @_;
	bless({
		position => $args{position},
		type     => $args{type},
		value    => $args{value},
	}, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my @p = $sol->get_float(3);
	my ($t, $v) = $sol->get_index(2);

	$class->new(
		position => [ SOL::Coordinates::neverball_to_radiant(@p) ],
		type     => $item_types[$t],
		value    => $v,
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(SOL::Coordinates::radiant_to_neverball(@{$self->{position}}));
	$sol->put_index(first_index(sub { $_ eq $self->{type} }, @item_types), $self->{value});
}

1;

__END__

=head1 NAME

SOL::Item - s_item

=head1 SYNOPSIS

=head1 DESCRIPTION

