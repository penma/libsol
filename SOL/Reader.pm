package SOL::Reader;

use strict;
use warnings;
use 5.010;

use Data::Dumper;
use Readonly;

# some constants
Readonly my $path_max => 64;

sub sol_load {
	my ($fin) = @_;

	my $sol = {};

	# sol_file
	$sol->{magic} = get_index($fin);
	$sol->{version} = get_index($fin);

	# sol_load_indx
	#                  a    d    m    v    e    s    t    g    l    n    p    b    h    z    j    x    r    u    w    i
	for my $field (qw(text dict mtrl vert edge side texc geom lump node path body item goal jump swch bill ball view indx)) {
		$sol->{count}->{$field} = get_index($fin);
	}

	if ($sol->{count}->{text}) {
		$sol->{_textv} = read_str($fin, $sol->{count}->{text});
	}

	for my $i (0..$sol->{count}->{dict} - 1) {
		my $ai = get_index($fin);
		my $aj = get_index($fin);
		push(@{$sol->{_dictv}}, [$ai, $aj]);

		my $ti = unpack("Z*", substr($sol->{_textv}, $ai));
		my $tj = unpack("Z*", substr($sol->{_textv}, $aj));
		$sol->{dict}->{$ti} = $tj;
	}

	for my $i (0..$sol->{count}->{mtrl} - 1) {
		my @md = get_array($fin, 4);
		my @ma = get_array($fin, 4);
		my @ms = get_array($fin, 4);
		my @me = get_array($fin, 4);
		my ($mh) = get_array($fin, 1);
		my $fl = get_index($fin);
		my $mtrl = read_pathname($fin);

		push(@{$sol->{mtrl}}, { _index => $i,
			diffuse  => \@md,
			ambient  => \@ma,
			specular => \@ms,
			emission => \@me,
			specular_exponent => $mh,
			flags => [ fvar_2flaglist($flagtables{material}, $fl) ],
			texture => $mtrl,
		});
	}

	for my $i (0..$sol->{count}->{vert} - 1) {
		push(@{$sol->{vert}}, [ get_array($fin, 3) ]);
	}

	for my $i (0..$sol->{count}->{edge} - 1) {
		my $vi = get_index($fin);
		my $vj = get_index($fin);
		push(@{$sol->{_edgev}}, [$vi, $vj]);

		push(@{$sol->{edge}}, [$sol->{vert}->[$vi], $sol->{vert}->[$vj]]);
	}

	for my $i (0..$sol->{count}->{side} - 1) {
		my @n = get_array($fin, 3);
		my $d = get_float($fin);
		push(@{$sol->{side}}, { normal => \@n, distance => $d });
	}

	for my $i (0..$sol->{count}->{texc} - 1) {
		push(@{$sol->{texc}}, [ get_array($fin, 2) ]);
	}

	for my $i (0..$sol->{count}->{geom} - 1) {
		my $mi = get_index($fin);
		my ($ti, $si, $vi, $tj, $sj, $vj, $tk, $sk, $vk) = get_indices($fin, 9);
		push(@{$sol->{geom}}, { _index => $i,
			material_index => $mi,
			material => $sol->{mtrl}->[$mi],
			texc_indices => [ $ti, $tj, $tk ],
			side_indices => [ $si, $sj, $sk ],
			vert_indices => [ $vi, $vj, $vk ],
			texcoords  => [ @{$sol->{texc}}[$ti, $tj, $tk] ],
			sides      => [ @{$sol->{side}}[$si, $sj, $sk] ],
			vertices   => [ @{$sol->{vert}}[$vi, $vj, $vk] ],
		});
	}

	for my $i (0..$sol->{count}->{lump} - 1) {
		my ($fl, $v0, $vc, $e0, $ec, $g0, $gc, $s0, $sc) = get_indices($fin, 9);

		push(@{$sol->{lump}}, { _index => $i,
			flags => [ fvar_2flaglist($flagtables{lump}, $fl) ],
			v0 => $v0, vc => $vc,
			e0 => $e0, ec => $ec,
			g0 => $g0, gc => $gc,
			s0 => $s0, sc => $sc,
		}); # XXX
	}

	for my $i (0..$sol->{count}->{node} - 1) {
		my ($si, $ni, $nj, $l0, $lc) = get_indices($fin, 5);

		push(@{$sol->{node}}, {
			si => $si,
			ni => $ni, nj => $nj,
			l0 => $l0, lc => $lc,
		}); # XXX
	}

	for my $i (0..$sol->{count}->{path} - 1) {
		my @p = get_array($fin, 3);
		my $t = get_float($fin);
		my ($pi, $f, $s) = get_indices($fin, 3);

		my @fl;
		if ($sol->{version} >= 7) { # SOL_VER_PATH_FLAGS
			my $fl = get_index($fin);
			@fl = fvar_2flaglist($flagtables{path}, $fl);
		}

		my @e = (1.0, 0.0, 0.0, 0.0);
		if ("oriented" ~~ @fl) {
			@e = get_array($fin, 4);
		}

		push(@{$sol->{path}}, {
			start_position => \@p,
			orientation    => \@e,
			travel_time    => $t,
			enable         => $f,
			smooth         => $s,
			flags          => \@fl,
			next_index     => $pi, # XXX
		});
	}

	for my $i (0..$sol->{count}->{body} - 1) {
		my ($pi, $ni, $l0, $lc, $g0, $gc) = get_indices($fin, 6);
		push(@{$sol->{_bodyv}}, {
			pi => $pi, ni => $ni, l0 => $l0, lc => $lc, g0 => $g0, gc => $gc,
		}); # XXX
	}

	for my $i (0..$sol->{count}->{item} - 1) {
		my @p = get_array($fin, 3);
		my ($t, $n) = get_indices($fin, 2);
		push(@{$sol->{item}}, {
			position => \@p,
			type     => [qw(none coin grow shrink)]->[$t],
			value    => $n,
		});
	}

	for my $i (0..$sol->{count}->{goal} - 1) {
		my @p = get_array($fin, 3);
		my $r = get_float($fin);
		push(@{$sol->{goal}}, {
			position => \@p,
			radius   => $r,
		});
	}

	for my $i (0..$sol->{count}->{jump} - 1) {
		my @p = get_array($fin, 3);
		my @q = get_array($fin, 3);
		my $r = get_float($fin);
		push(@{$sol->{jump}}, {
			position => \@p,
			target   => \@q,
			radius   => $r,
		});
	}

	for my $i (0..$sol->{count}->{swch} - 1) {
		my @p = get_array($fin, 3);
		my $r = get_float($fin);
		my $pi = get_index($fin);
		my $t0 = get_float($fin);
		my $t = get_float($fin);
		my ($f0, $f, $invis) = get_indices($fin, 3);

		push(@{$sol->{swch}}, {
			position       => \@p,
			radius         => $r,
			path_index     => $pi, # XXX
			timer_default  => $t0,
			timer_current  => $t,
			state_default  => $f0,
			state_current  => $f,
			invisible      => $invis,
		});
	}

	for my $i (0..$sol->{count}->{bill} - 1) {
		my ($fl, $mi) = get_indices($fin, 2);
		my $t = get_float($fin);
		my $d = get_float($fin);
		my @w = get_array($fin, 3);
		my @h = get_array($fin, 3);
		my @rx = get_array($fin, 3);
		my @ry = get_array($fin, 3);
		my @rz = get_array($fin, 3);
		my @p = get_array($fin, 3);

		push(@{$sol->{bill}}, {
			flags => [ fvar_2flaglist($flagtables{billboard}, $fl) ],
			mi => $mi, # XXX
			repeat_time => $t,
			distance    => $d,
			width       => \@w,
			height      => \@h,
			rotate_x    => \@rx,
			rotate_y    => \@ry,
			rotate_z    => \@rz,
			p           => \@p, # XXX
		});
	}

	for my $i (0..$sol->{count}->{ball} - 1) {
		my @p = get_array($fin, 3);
		my $r = get_float($fin);

		push(@{$sol->{ball}}, {
			position => \@p,
			radius   => $r,
		});
	}

	for my $i (0..$sol->{count}->{view} - 1) {
		my @p = get_array($fin, 3);
		my @q = get_array($fin, 3);
		push(@{$sol->{view}}, {
			p => \@p,
			q => \@q,
		});
	}

	@{$sol->{_indxv}} = get_indices($fin, $sol->{count}->{indx});

	# done loading

	return $sol;
}

sub sol_stor {
	my ($fout, $sol) = @_;

	print STDERR "Writing SOL file:";

	print STDERR " header";

	put_index($fout, 0x4c4f53af);
	put_index($fout, 7); # version

	# rewrite dict from hash keys
	my $av_text = "";
	my @dict;
	foreach my $key (keys %{$sol->{dict}}) {
		push(@dict, length($av_text), length($av_text) + length($key) + 1);
		$av_text .= pack("(Z*)*", $key, $sol->{dict}->{$key});
	}
	$sol->{count}->{dict} = scalar keys %{$sol->{dict}};
	$sol->{count}->{text} = length($av_text);

	# XXX
	for my $field (qw(text dict mtrl vert edge side texc geom lump node path body item goal jump swch bill ball view indx)) {
		# put_index($fout, $sol->{count}->{$field});
		put_index($fout, $sol->{count}->{$field} // scalar @{$sol->{$field} // []});
	}

	print $fout $av_text;
	put_indices($fout, @dict);

	print STDERR " mtrl";
	foreach my $mtrl (@{$sol->{mtrl}}) {
		put_array($fout,
			@{$mtrl->{diffuse}},
			@{$mtrl->{ambient}},
			@{$mtrl->{specular}},
			@{$mtrl->{emission}},
			$mtrl->{specular_exponent},
		);
		put_index($fout, flaglist_2fvar($flagtables{material}, @{$mtrl->{flags}}));
		print $fout pack("Z$pathmax", $mtrl->{texture});
	}

	print STDERR " vert";
	foreach my $vert (@{$sol->{vert}}) {
		put_array($fout, @{$vert});
	}

	print STDERR " edge";
	foreach my $edge (@{$sol->{edge}}) {
		put_indices($fout,
			index_intable($edge->[0], $sol->{vert}),
			index_intable($edge->[1], $sol->{vert}),
		);
	}

	print STDERR " side";
	foreach my $side (@{$sol->{side}}) {
		put_array($fout, @{$side->{normal}}, $side->{distance});
	}

	print STDERR " texc";
	foreach my $texc (@{$sol->{texc}}) {
		put_array($fout, @{$texc});
	}

	print STDERR " geom";
	foreach my $geom (@{$sol->{geom}}) {
		put_index($fout, index_intable($geom->{material}, $sol->{mtrl}));
		for my $n (0..2) {
			for my $t ([qw(texcoords texc)], [qw(sides side)], [qw(vertices vert)]) {
				put_index($fout, index_intable($geom->{$t->[0]}->[$n], $sol->{$t->[1]}));
			}
		}
	}

	print STDERR " lump";
	foreach my $lump (@{$sol->{lump}}) {
		put_index($fout, flaglist_2fvar($flagtables{lump}, @{$lump->{flags}}));
		# XXX XXX XXX XXX
		put_indices($fout,
			$lump->{v0}, $lump->{vc}, $lump->{e0}, $lump->{ec},
			$lump->{g0}, $lump->{gc}, $lump->{s0}, $lump->{sc},
		);
	}

	print STDERR " node";
	foreach my $node (@{$sol->{node}}) {
		put_indices($fout,
			# XXX
			$node->{si}, $node->{ni}, $node->{nj}, $node->{l0}, $node->{lc},
		);
	}

	print STDERR " path";
	foreach my $path (@{$sol->{path}}) {
		put_array($fout, @{$path->{start_position}});
		put_float($fout, $path->{travel_time});
		put_indices($fout,
			$path->{next_index}, # XXX ??
			$path->{enable},
			$path->{smooth},
			flaglist_2fvar($flagtables{path}, @{$path->{flags}}),
		);
		if ("oriented" ~~ $path->{flags}) {
			put_array($fout, @{$path->{orientation}});
		}
	}

	print STDERR " body";
	foreach my $body (@{$sol->{_bodyv}}) {
		put_indices($fout,
			$body->{pi}, $body->{ni}, $body->{l0}, $body->{lc}, $body->{g0}, $body->{gc},
		);
	}

	print STDERR " item";
	foreach my $item (@{$sol->{item}}) {
		put_array($fout, @{$item->{position}});
		put_indices($fout,
			{ none => 0, coin => 1, grow => 2, shrink => 3 }->{$item->{type}},
			$item->{value},
		);
	}

	print STDERR " goal";
	foreach my $goal (@{$sol->{goal}}) {
		put_array($fout, @{$goal->{position}});
		put_float($fout, $goal->{radius});
	}

	print STDERR " jump";
	foreach my $jump (@{$sol->{jump}}) {
		put_array($fout, @{$jump->{position}}, @{$jump->{target}});
		put_float($fout, $jump->{radius});
	}

	print STDERR " swch";
	foreach my $swch (@{$sol->{swch}}) {
		put_array($fout, @{$swch->{position}});
		put_float($fout, $swch->{radius});
		put_index($fout, $swch->{path_index}); # XXX
		put_array($fout, $swch->{timer_default}, $swch->{timer_current});
		put_indices($fout, $swch->{state_default}, $swch->{state_current});
		put_index($fout, $swch->{invisible});
	}

	print STDERR " bill";
	foreach my $bill (@{$sol->{bill}}) {
		put_indices($fout,
			flaglist_2fvar($flagtables{billboard}, @{$bill->{flags}}),
			$bill->{mi}, # XXX
		);
		put_array($fout,
			$bill->{repeat_time},
			$bill->{distance},
			@{$bill->{width}},
			@{$bill->{height}},
			@{$bill->{rotate_x}},
			@{$bill->{rotate_y}},
			@{$bill->{rotate_z}},
			@{$bill->{p}},
		);
	}

	print STDERR " ball";
	foreach my $ball (@{$sol->{ball}}) {
		put_array($fout, @{$ball->{position}}, $ball->{radius});
	}

	print STDERR " view";
	foreach my $view (@{$sol->{view}}) {
		put_array($fout, @{$view->{p}}, @{$view->{q}});
	}

	# XXX XXX XXX
	print STDERR " indx";
	put_indices($fout, @{$sol->{_indxv}});

	print STDERR ".\n";
}

#my $f = IO::File->new("/dev/stdin", "r") or die($!);
#my $sol = sol_load($f);
#print Dumper $sol

# __END__

my $sol;

$sol->{mtrl} = [
	{ # 0
		ambient  => [ 0.2, 0.2, 0.2, 1.0 ],
		diffuse  => [ 1.0, 1.0, 1.0, 1.0 ],
		specular => [ 0.0, 0.0, 0.0, 1.0 ],
		emission => [ 0.0, 0.0, 0.0, 1.0 ],
		specular_exponent => 0,
		flags    => [qw(opaque)],
		texture  => "mtrl/turf-green",
	}, { # 1
		ambient  => [ 0.2, 0.2, 0.2, 1.0 ],
		diffuse  => [ 1.0, 1.0, 1.0, 1.0 ],
		specular => [ 0.0, 0.0, 0.0, 1.0 ],
		emission => [ 0.0, 0.0, 0.0, 1.0 ],
		specular_exponent => 0,
		flags    => [qw(opaque)],
		texture  => "mtrl/turf-grey",
	},
];

$sol->{vert} = [
	[ +0.  , +0.  , +0.   ], # 0
	[ +0.  , +0.  , -2.   ], # 1
	[ +2.  , +0.  , -2.   ], # 2
	[ +2.  , +0.  , +0.   ], # 3
	[ +0.  , -0.25, +0.   ], # 4
	[ +0.  , -0.25, -2.   ], # 5
	[ +2.  , -0.25, -2.   ], # 6
	[ +2.  , -0.25, +0.   ], # 7
	[ +0.  , +0.5 , -3.   ], # 8
	[ +2.  , +0.5 , -3.   ], # 9
	[ +0.  , +0.5 , -2.   ], # 10
	[ +2.  , +0.5 , -2.   ], # 11
	[ +0.  , +0.  , -3.   ], # 12
	[ +2.  , +0.  , -3.   ], # 13
	[ +0.  , +1.0 , -2.   ], # 14
	[ +2.  , +1.0 , -2.   ], # 15
];

$sol->{edge} = [
	[ $sol->{vert}->[0] => $sol->{vert}->[1] ], # 0
	[ $sol->{vert}->[1] => $sol->{vert}->[2] ], # 1
	[ $sol->{vert}->[2] => $sol->{vert}->[3] ], # 2
	[ $sol->{vert}->[3] => $sol->{vert}->[0] ], # 3
	[ $sol->{vert}->[4] => $sol->{vert}->[5] ], # 4
	[ $sol->{vert}->[5] => $sol->{vert}->[6] ], # 5
	[ $sol->{vert}->[6] => $sol->{vert}->[7] ], # 6
	[ $sol->{vert}->[7] => $sol->{vert}->[4] ], # 7
	[ $sol->{vert}->[0] => $sol->{vert}->[4] ], # 8
	[ $sol->{vert}->[1] => $sol->{vert}->[5] ], # 9
	[ $sol->{vert}->[2] => $sol->{vert}->[6] ], # 10
	[ $sol->{vert}->[3] => $sol->{vert}->[7] ], # 11
	[ 10 => 11 ], # 12
	[  8 =>  9 ], # 13
	[ 12 => 13 ], # 14
	[ 10 =>  8 ], # 15
	[  9 => 11 ], # 16
	[  2 => 13 ], # 17
	[  1 => 12 ], # 18
	[  8 => 12 ], # 19
	[ 13 =>  9 ], # 20
	[  2 => 11 ], # 21
	[  1 => 10 ], # 22
];

$sol->{side} = [
	{ normal => [ -1,  0,  0 ], distance =>     0 }, # 0 left
	{ normal => [  0,  0, -1 ], distance =>     2 }, # 1 back
	{ normal => [  1,  0,  0 ], distance =>     2 }, # 2 right
	{ normal => [  0,  0,  1 ], distance =>     0 }, # 3 front
	{ normal => [  0,  1,  0 ], distance =>     0 }, # 4 top
	{ normal => [  0, -1,  0 ], distance =>  0.25 }, # 5 bottom
	{ normal => [  0,  0,  1 ], distance =>    -2 }, # 6 l2 front, might need to be reversed
	{ normal => [  0,  0,  1 ], distance =>   0.5 }, # 7 l2 top
	{ normal => [  0,  0, -1 ], distance =>     3 }, # 8 l2 back
	{ normal => [  0, -1,  0 ], distance =>    -0 }, # 9 l2 bottom, might need to be reversed
];

$sol->{texc} = [
	[ 0, 0     ], # 0
	[ 1, 0     ], # 1
	[ 1, 1     ], # 2
	[ 0, 1     ], # 3
	[ 0, 0.125 ], # 4
	[ 1, 0.125 ], # 5
	[ 0, 0.5   ], # 6
	[ 1, 0.5   ], # 7
];

$sol->{geom} = [
	{
		sides     => [ $sol->{side}->[4], $sol->{side}->[4], $sol->{side}->[4] ],
		vertices  => [ $sol->{vert}->[0], $sol->{vert}->[2], $sol->{vert}->[1] ],
		texcoords => [ $sol->{texc}->[3], $sol->{texc}->[1], $sol->{texc}->[0] ],
		material  => $sol->{mtrl}->[0],
	}, {
		sides     => [ $sol->{side}->[4], $sol->{side}->[4], $sol->{side}->[4] ],
		vertices  => [ $sol->{vert}->[0], $sol->{vert}->[3], $sol->{vert}->[2] ],
		texcoords => [ $sol->{texc}->[3], $sol->{texc}->[2], $sol->{texc}->[1] ],
		material  => $sol->{mtrl}->[0],
	},
	# TBC
	{ sides => [ 2, 2, 2 ], vertices => [  2,  3,  6 ], texcoords => [ 1, 0, 5 ], material => 1 }, # 2
	{ sides => [ 2, 2, 2 ], vertices => [  3,  7,  6 ], texcoords => [ 0, 4, 5 ], material => 1 }, # 3

	{ sides => [ 0, 0, 0 ], vertices => [  0,  1,  4 ], texcoords => [ 1, 0, 5 ], material => 1 }, # 4
	{ sides => [ 0, 0, 0 ], vertices => [  1,  5,  4 ], texcoords => [ 0, 4, 5 ], material => 1 }, # 5

	{ sides => [ 3, 3, 3 ], vertices => [  3,  0,  7 ], texcoords => [ 1, 0, 5 ], material => 1 }, # 6
	{ sides => [ 3, 3, 3 ], vertices => [  0,  4,  7 ], texcoords => [ 0, 4, 5 ], material => 1 }, # 7

	{ sides => [ 1, 1, 1 ], vertices => [  1,  2,  5 ], texcoords => [ 1, 0, 5 ], material => 1 }, # 8
	{ sides => [ 1, 1, 1 ], vertices => [  2,  6,  5 ], texcoords => [ 0, 4, 5 ], material => 1 }, # 9

	# lump1
	{ sides => [ 6, 6, 6 ], vertices => [  1, 11, 10 ], texcoords => [ 3, 7, 6 ], material => 0 }, # 10
	{ sides => [ 6, 6, 6 ], vertices => [  1,  2, 11 ], texcoords => [ 3, 2, 7 ], material => 0 }, # 11

	{ sides => [ 7, 7, 7 ], vertices => [ 10,  9,  8 ], texcoords => [ 6, 1, 0 ], material => 0 }, # 12
	{ sides => [ 7, 7, 7 ], vertices => [ 10, 11,  9 ], texcoords => [ 6, 7, 1 ], material => 0 }, # 13

	{ sides => [ 8, 8, 8 ], vertices => [  8,  9, 13 ], texcoords => [ 1, 0, 6 ], material => 0 }, # 14
	{ sides => [ 8, 8, 8 ], vertices => [  8, 13, 12 ], texcoords => [ 1, 6, 7 ], material => 0 }, # 15

	{ sides => [ 0, 0, 0 ], vertices => [ 10,  8, 12 ], texcoords => [ 0, 1, 2 ], material => 0 }, # 16 fix tc
	{ sides => [ 0, 0, 0 ], vertices => [ 10, 12,  1 ], texcoords => [ 0, 1, 2 ], material => 0 }, # 17 fix tc

	{ sides => [ 2, 2, 2 ], vertices => [  9, 11,  2 ], texcoords => [ 0, 1, 2 ], material => 0 }, # 18 fix tc
	{ sides => [ 2, 2, 2 ], vertices => [  9,  2, 13 ], texcoords => [ 0, 1, 2 ], material => 0 }, # 19 fix tc

	# no lump
	{ sides => [ 6, 6, 6 ], vertices => [ 10, 15, 14 ], texcoords => [ 6, 1, 0 ], material => 0 }, # 20
	{ sides => [ 6, 6, 6 ], vertices => [ 10, 11, 15 ], texcoords => [ 6, 7, 1 ], material => 0 }, # 21
];

$sol->{lump} = [
	{
		v0 =>  0, vc => 8,
		e0 =>  8, ec => 12,
		s0 => 20, sc => 6,
		g0 => 26, gc => 10,
	}, {
		v0 => 36, vc => 8,
		e0 => 44, ec => 12,
		s0 => 56, sc => 6,
		g0 => 62, gc => 0,
	},
];

$sol->{_indxv} = [
	# 0..7 lump0 v
	0, 1, 2, 3, 4, 5, 6, 7,
	# 8..19 lump0 e
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
	# 20..25 lump0 s
	0, 1, 2, 3, 4, 5,
	# 26..35 lump0 g
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
	# 36..43 lump1 v
	1, 2, 8, 9, 10, 11, 12, 13,
	# 44..55 lump1 e
	1, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
	# 56..61 lump1 s
	6, 7, 2, 0, 8, 9,
	# 62..71 lump1 g
	10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
	# 72..93 body0 g
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
];

$sol->{node} = [ { l0 => 0, lc => 2,  ni => -1, nj => -1, si => -1, } ]; # l0/lc don't have own list space yet
$sol->{_bodyv} = [ { l0 => 0, lc => 0, g0 => 72, gc => 22, pi => -1, ni => 0, } ]; 
$sol->{item} = $sol->{goal} = $sol->{jump} = $sol->{swch} = $sol->{bill} = $sol->{view} = $sol->{path} = [];

$sol->{ball} = [ { radius => 0.25, position => [ 1, 0.25, -1 ] } ];

$sol->{dict} = {
	author    => "Penma",
	message   => "hello world",
	levelname => "libsol-perl",
	version   => 1,
	shot      => "shot-penma-ng/tower.png",

	song      => "bgm/track5.ogg",
	back      => "map-back/city.sol",
	grad      => "back/city.png",

	time      => 0,
	goal      => 0,
	time_hs   => "5000 5236",
};

$sol->{count} = { indx => scalar @{$sol->{_indxv}}, body => scalar @{$sol->{_bodyv}}, };

my $fo = IO::File->new("data/map-penma/sol-out.sol", "w") or die($!);
sol_stor($fo, $sol);

# print Dumper(@{$sol->{geom}}[2..13]);
# print Dumper($sol);
