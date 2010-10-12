package SOL::Lump;

use strict;
use warnings;
use 5.010;

use Readonly;

use SOL::Flags;
use SOL::Unresolved;

Readonly my %lump_flags => (
	detail => 1,
);

sub new {
	my ($class, %args) = @_;
	my $self = {
		flags      => $args{flags}      // [],
		vertices   => $args{vertices}   // [],
		edges      => $args{edges}      // [],
		geometries => $args{geometries} // [],
		sides      => $args{sides}      // [],
	};
	bless($self, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my ($flags, $v0, $vc, $e0, $ec, $g0, $gc, $s0, $sc) = $sol->get_index(9);

	$class->new(
		flags      => SOL::Flags::decode($flags, \%lump_flags),
		vertices   => SOL::Unresolved->new("vertex"  , [ $v0 .. ($v0 + $vc - 1) ]),
		edges      => SOL::Unresolved->new("edge"    , [ $e0 .. ($e0 + $ec - 1) ]),
		geometries => SOL::Unresolved->new("geometry", [ $g0 .. ($g0 + $gc - 1) ]),
		sides      => SOL::Unresolved->new("side"    , [ $s0 .. ($s0 + $sc - 1) ]),
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_index(SOL::Flags::encode($self->{flags}, \%lump_flags));
	$sol->put_index(
		@{$self->{vertices}},
		@{$self->{edges}},
		0, 0,
		@{$self->{sides}},
	);
}

1;

__END__

=head1 NAME

SOL::Lump - s_lump

=head1 SYNOPSIS

=head1 DESCRIPTION

