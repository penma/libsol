package SOL::Debug;

use strict;
use warnings;

use Data::Dump::Filtered qw(dump_filtered);

sub sol_dump {
	my ($sol) = @_;
	local $Data::Dump::INDENT = "│   ";
	dump_filtered($sol, sub {
		my ($ctx, $obj) = @_;

		if ($ctx->object_isa("SOL::Vertex")) {
			return { dump => sprintf("v(% 1.3f  % 1.3f  % 1.3f)", @{$obj}) };
		}

		if ($ctx->object_isa("SOL::Edge")) {
			return { dump => sprintf("edge: v(% 1.3f  % 1.3f  % 1.3f) -> v(% 1.3f  % 1.3f  % 1.3f)", @{$obj->[0]}, @{$obj->[1]}) };
		}

		if ($ctx->object_isa("SOL::TextureCoordinate")) {
			return { dump => "texc($obj->[0]/$obj->[1])" };
		}

		if ($ctx->object_isa("SOL::Side")) {
			return { dump => sprintf("side(n0 = % 1.3f  % 1.3f  % 1.3f, d = % 1.3f)", @{$obj->{normal}}, $obj->{distance}) };
		}

		if ($ctx->object_isa("SOL::Material")) {
			my $mn = $obj->{texture};
			$mn =~ s/.*\///;
			return { dump => "mtrl(\"$mn\")" };
		}

		if ($ctx->object_isa("SOL::Geometry")) {
			my ($cm) = ($ctx->container_self() =~ /\[(\d+)\]/);
			return { hide_keys => [ "sides" ], comment => "geom $cm" };
		}

		if ($ctx->object_isa("SOL::Lump")) {
			my ($cm) = ($ctx->container_self() =~ /\[(\d+)\]/);
			return { hide_keys => [ "sides", "edges" ], comment => "lump $cm, vertices only" };
		}

		if ($ctx->object_isa("SOL::Body")) {
			my ($cm) = ($ctx->container_self() =~ /\[(\d+)\]/);
			return {
				hide_keys => [ "geometries", "lumps" ],
				comment => "body $cm - "
				. scalar(@{$obj->{geometries} // []}) . " geometries and "
				. scalar(@{$obj->{lumps} // []}) . " lumps hidden",
			};
		}

		return {};
	});
}

1;
