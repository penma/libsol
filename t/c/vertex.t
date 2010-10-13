#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 14;
use Test::Number::Delta within => 1e-4;

use IO::Handle;
use SOL::C::File;
use SOL::C::Vertex;

my $sol = bless({}, "SOL::C::File");
my $v;

# reading

open($sol->{fh}, "<", \"\0\0\x80?\0\0\0\0\0\0\0\0");
$v = SOL::C::Vertex->from_sol($sol);
delta_ok($v->x, 1, "vertex x coordinate is 1");
delta_ok($v->y, 0, "vertex y coordinate is 0");
delta_ok($v->z, 0, "vertex z coordinate is 0");

open($sol->{fh}, "<", \"\0\0\0\0\0\0\0\0\0\0\0\0");
$v = SOL::C::Vertex->from_sol($sol);
delta_ok($v->x, 0, "vertex x coordinate is 0");
delta_ok($v->y, 0, "vertex y coordinate is 0");
delta_ok($v->z, 0, "vertex z coordinate is 0");

open($sol->{fh}, "<", \"\0\0\0\0\0\0\x80\xBF\0\0\0\0");
$v = SOL::C::Vertex->from_sol($sol);
delta_ok($v->x,  0, "vertex x coordinate is 0");
delta_ok($v->y, -1, "vertex y coordinate is -1");
delta_ok($v->z,  0, "vertex z coordinate is 0");

open($sol->{fh}, "<", \"\0\0\0>\0\0\0\0\0\0\@?");
$v = SOL::C::Vertex->from_sol($sol);
delta_ok($v->x, 0.125, "vertex x coordinate is 0.125");
delta_ok($v->y, 0    , "vertex y coordinate is 0");
delta_ok($v->z, 0.75 , "vertex z coordinate is 0.75");

# writing

my $o;
open($sol->{fh}, ">", \$o);
SOL::C::Vertex->new(x => 1, y => 0, z => 0)->to_sol($sol);
is($o, "\0\0\x80?\0\0\0\0\0\0\0\0", "vertex (1,0,0) correctly serialized");

seek $sol->{fh}, 0, 0;
SOL::C::Vertex->new(x => 0, y => -1, z => 2)->to_sol($sol);
is($o, "\0\0\0\0\0\0\x80\xBF\0\0\0\@", "vertex (0,-1,2) correctly serialized");

