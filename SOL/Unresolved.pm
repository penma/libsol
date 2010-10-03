package SOL::Unresolved;

use strict;
use warnings;
use 5.010;

sub new {
	my ($class, $type, $index) = @_;
	bless({ type => $type, index => $index }, $class);
}

sub resolve {
	my ($self, $sol) = @_;
	# is it a direct or an indirect index?
	if (ref($self->{index}) eq "ARRAY") {
		# indirect index - list of indices stored in index list
		[ map { $sol->{$self->{type}}->[$_] } @{$sol->{index}}[@{$self->{index}}] ];
	} elsif (ref($self->{index}) eq "") {
		# direct index
		$sol->{$self->{type}}->[$self->{index}];
	} else {
		die("Weird value of index for SOL::Unresolved");
	}
}

1;

__END__

=head1 NAME

SOL::Unresolved - dummy object for unresolved indices

=head1 SYNOPSIS

 # 2nd vert
 SOL::Unresolved->new("vertex", 2);

 # geoms stored in 20th to 27th index entries
 SOL::Unresolved->new("geometry", [ 20..27 ]);

 # look up the actual object in a fully loaded SOL
 if ($geom_list->isa("SOL::Unresolved")) {
     $geom_list = $geom_list->resolve($sol);
 }

=head1 DESCRIPTION

In the SOL format, objects are sometimes referenced by indices and not
directly. The Perl modules don't use indices and use straight references
instead.

When reading SOL files, the index is located at the end of the file, and
it can only be read when the rest of the file has already been parsed
(because of many variable-length structures in SOL). So the indices cannot
be resolved immediately. Instead, a SOL::Unresolved object is created,
which stores the index and the object type it temporarily represents.
When SOL::Loader arrives at the index, it searches the created tree for
SOL::Unresolved objects and replaces them with references to the now existent
actual objects.

If the index provided to the constructor is a simple scalar, it references
that element in the SOL file directly. If it is an arrayref, the specified
positions in the index table will be consulted for the actual indices of
the elements.

