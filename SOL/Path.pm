package SOL::Path;

use strict;
use warnings;
use 5.010;

use Readonly;

use SOL::Flags;
use SOL::Unresolved;

Readonly my $sol_version_pathflags => 7;

Readonly my %path_flags => (
	oriented => 1,
);

sub new {
	my ($class, %args) = @_;
	my $self = {
		position       => $args{position},
		orientation    => $args{orientation} // [1, 0, 0, 0],
		travel_time    => $args{travel_time},
		enable         => $args{enable},
		smooth         => $args{smooth} // 1,
		flags          => $args{flags},
		next_path      => $args{next_path},
	};
	bless($self, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my @p = $sol->get_float(3);
	my $t = $sol->get_float(1);
	my ($pi, $f, $s) = $sol->get_index(3);

	my $fl = [];
	if ($sol->version() >= $sol_version_pathflags) {
		$fl = SOL::Flags::decode($sol->get_index(1), \%path_flags);
	}

	my @e = (1, 0, 0, 0);
	if ("oriented" ~~ $fl) {
		@e = $sol->get_float(4); # XXX convert coords?
	}

	$class->new(
		position       => [ SOL::Coordinates::neverball_to_radiant(@p) ],
		orientation    => \@e,
		travel_time    => $t,
		enable         => $f,
		smooth         => $s,
		flags          => $fl,
		next_path      => SOL::Unresolved->new("path", $pi),
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(SOL::Coordinates::radiant_to_neverball(@{$self->{position}}), $self->{travel_time});
	$sol->put_index($self->{next_path} // -1);
	$sol->put_index($self->{enable}, $self->{smooth});
	$sol->put_index(SOL::Flags::encode($self->{flags}, \%path_flags));
	if ("oriented" ~~ $self->{flags}) {
		$sol->put_float(@{$self->{orientation}});
	}
}

1;

__END__

=head1 NAME

SOL::Lump - s_lump

=head1 SYNOPSIS

=head1 DESCRIPTION

