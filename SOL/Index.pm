package SOL::Index;

use strict;
use warnings;

sub from_sol {
	my ($class, $sol, $indexlen) = @_;

	my $self = [ $sol->get_index($indexlen) ];

	bless($self, $class);
}

sub to_sol {
	my ($self, $sol) = @_;
	$sol->put_index(@{$self});
}

1;

__END__

=head1 NAME

SOL::Index -

=head1 SYNOPSIS

=head1 DESCRIPTION

This module manages the text and dict sections of SOL files. Given the
lengths of the sections (from the header), it produces a hashref.

