package SOL::TextureCoordinate;

use strict;
use warnings;
use 5.010;

sub new {
	my ($class, $u, $v) = @_;
	bless([ $u, $v ], $class);
}

sub from_sol {
	my ($class, $sol) = @_;

	$class->new($sol->get_float(2));
}

sub to_sol {
	my ($self, $sol) = @_;

	$sol->put_float(@{$self});
}

1;

__END__

=head1 NAME

SOL::TextureCoordinate - s_texc

=head1 SYNOPSIS

=head1 DESCRIPTION

