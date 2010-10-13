#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 5;
use Test::Number::Delta within => 1e-4;

use IO::Handle;
use SOL::C::File;
use SOL::C::Side;

my $sol = bless({}, "SOL::C::File");
my $s;

# reading

open($sol->{fh}, "<", \"\0\0\x80?\0\0\0\0\0\0\0\0\0\0\xA0\xC0");
$s = SOL::C::Side->from_sol($sol);
delta_ok([$s->normal], [1,0,0], "side normal is (1,0,0)");
delta_ok($s->distance, -5, "side distance is -5");

# writing

my $o;
open($sol->{fh}, ">", \$o);
$s = SOL::C::Side->new(normal => [ 0, 0, 1 ], distance => 5);
delta_ok([$s->normal], [0,0,1], "side normal is (0,0,1)");
delta_ok($s->distance, 5, "side distance is 5");
$s->to_sol($sol);
is($o, "\0\0\0\0\0\0\0\0\0\0\x80?\0\0\xA0\@", "side (0,0,1),5 correctly serialized");
