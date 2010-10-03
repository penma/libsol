package SOL::Flags;

use strict;
use warnings;

use List::Util qw(reduce);

sub decode {
	my ($num, $table) = @_;
	[ grep { $num & $table->{$_} } keys(%{$table}) ];
}

sub encode {
	my ($vec, $table) = @_;
	reduce { $a | $table->{$b} } 0, @{$vec};
}

1;
