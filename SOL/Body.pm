package SOL::Body;

use strict;
use warnings;
use 5.010;

use SOL::Unresolved;

sub new {
	my ($class, %args) = @_;
	my $self = {
		path       => $args{path},
		node       => $args{node},
		lumps      => $args{lumps}      // [],
		geometries => $args{geometries} // [],
	};
	bless($self, $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	my ($pi, $ni, $l0, $lc, $g0, $gc) = $sol->get_index(6);

	$class->new(
		path       => SOL::Unresolved->new("path", $pi),
		node       => SOL::Unresolved->new("node", $ni),
		lumps      => SOL::Unresolved->new("lump"    , [ $l0 .. ($l0 + $lc - 1) ]),
		geometries => SOL::Unresolved->new("geometry", [ $g0 .. ($g0 + $gc - 1) ]),
	);
}

sub to_sol {
	my ($self, $sol) = @_;

	die("s_body storage not implemented yet (must ask parent object about indxv values+indices for node,path,lump,geom)");
}

1;

__END__

=head1 NAME

SOL::Lump - s_lump

=head1 SYNOPSIS

=head1 DESCRIPTION

