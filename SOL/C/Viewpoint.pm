package SOL::C::Viewpoint;

use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	bless({
		position => $args{position},
		target   => $args{target},
	}, $class);
}

sub from_sol {
	my ($class, $reader) = @_;
	$class->new(
		position => [ $reader->get_float(3) ],
		target   => [ $reader->get_float(3) ],
	);
}

sub to_sol {
	my ($self, $writer) = @_;
	$writer->put_float(
		@{$self->{position}},
		@{$self->{target}},
	);
}

sub position {
	my ($self) = @_;
	@{$self->{position}};
}

sub target {
	my ($self) = @_;
	@{$self->{target}};
}

1;

__END__

=head1 NAME

SOL::C::Viewpoint - s_view

=head1 SYNOPSIS

 my $w = SOL::C::Viewpoint->from_sol($reader);
 $camera->set(from => $w->position, to => $w->target);

 my $w = SOL::C::Viewpoint->new(
     position => [ -5, 20, -5 ],
     target   => [ $ball->position ],
 );
 $w->to_sol($writer);

=head1 DESCRIPTION

A SOL::C::Viewpoint is the exact representation of an s_view structure.
Its coordinates are returned in the Neverball coordinate system.
