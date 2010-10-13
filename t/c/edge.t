#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 6;

use IO::Handle;
use SOL::C::File;
use SOL::C::Edge;

my $sol = bless({}, "SOL::C::File");
my $e;

# reading

open($sol->{fh}, "<", \"\2\0\0\0\2\0\0\0");
$e = SOL::C::Edge->from_sol($sol);
is($e->vi, 2, "vertex i is 2");
is($e->vj, 2, "vertex j is 2");

open($sol->{fh}, "<", \"\3\0\0\0\5\0\0\0");
$e = SOL::C::Edge->from_sol($sol);
is($e->vi, 3, "vertex i is 3");
is($e->vj, 5, "vertex j is 5");

# writing

my $o;
open($sol->{fh}, ">", \$o);
SOL::C::Edge->new(vi => 2, vj => 5)->to_sol($sol);
is($o, "\2\0\0\0\5\0\0\0", "edge (2,5) correctly serialized");

seek $sol->{fh}, 0, 0;
SOL::C::Edge->new(vi => 1479, vj => 2342)->to_sol($sol);
is($o, "\xC7\5\0\0&\t\0\0", "edge (1479,2342) correctly serialized");

