package SOL::Edge;

use strict;
use warnings;
use 5.010;

use SOL::Unresolved;

sub new {
	my ($class, $v1, $v2) = @_;
	bless([ $v1, $v2 ], $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my ($i, $j) = $sol->get_index(2);
	$class->new(SOL::Unresolved->new("vertex", $i) => SOL::Unresolved->new("vertex", $j));
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_index(@{$self});
}

1;

__END__

=head1 NAME

SOL::Edge - s_edge

=head1 SYNOPSIS

=head1 DESCRIPTION

