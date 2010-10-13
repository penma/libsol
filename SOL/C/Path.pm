package SOL::C::Path;

use strict;
use warnings;

use Readonly;

use SOL::Util::Flags;

Readonly my $sol_version_pathflags => 7;

Readonly my %path_flags => (
	oriented => 1,
);

sub new {
	my ($class, %args) = @_;
	bless({
		position      => $args{position},
		orientation   => $args{orientation},
		travel_time   => $args{travel_time},
		enable        => $args{enable},
		smooth        => $args{smooth},
		flags         => $args{flags},
		next_path     => $args{next_path},
	}, $class);
}

sub from_sol {
	my ($class, $reader) = @_;

	my @p = $reader->get_float(3);
	my $t = $reader->get_float(1);
	my ($pi, $f, $s) = $reader->get_index(3);

	my $fl = [];
	if ($reader->sol_version() >= $sol_version_pathflags) {
		$fl = SOL::Util::Flags::decode($reader->get_index(1), \%path_flags);
	}

	my @e = (1, 0, 0, 0);
	if ("oriented" ~~ $fl) {
		@e = $reader->get_float(4);
	}

	$class->new(
		position       => [ @p ],
		orientation    => [ @e ],
		travel_time    => $t,
		enable         => $f,
		smooth         => $s,
		flags          => $fl,
		next_path      => ($pi >= 0 ? $pi : undef),
	);
}

sub to_sol {
	my ($self, $writer) = @_;

	$writer->put_float(@{$self->{position}}, $self->{travel_time});
	$writer->put_index((defined($self->{next_path}) and $self->{next_path} >= 0) ? $self->{next_path} : -1);
	$writer->put_index($self->{enable}, $self->{smooth});
	$writer->put_index(SOL::Util::Flags::encode($self->{flags}, \%path_flags));
	if ("oriented" ~~ $self->{flags}) {
		$writer->put_float(@{$self->{orientation}});
	}
}

sub position {
	my ($self) = @_;
	@{$self->{position}};
}

sub orientation {
	my ($self) = @_;
	@{$self->{orientation}};
}

sub travel_time {
	my ($self) = @_;
	$self->{travel_time};
}

sub next_path {
	my ($self) = @_;
	$self->{next_path};
}

sub enable {
	my ($self) = @_;
	$self->{enable};
}

sub smooth {
	my ($self) = @_;
	$self->{smooth};
}

sub flags {
	my ($self) = @_;
	@{$self->{flags}};
}

1;

__END__

=head1 NAME

SOL::C::Path - s_path

=head1 SYNOPSIS

=head1 DESCRIPTION

A SOL::C::Path is the exact representation of an s_path structure. Its
coordinates are returned in the Neverball coordinate system.
