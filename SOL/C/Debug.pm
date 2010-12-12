package SOL::C::Debug;

use strict;
use warnings;

use Data::Dump::Filtered qw(dump_filtered);

sub sol_dump {
	my ($cfile) = @_;
	local $Data::Dump::INDENT = "│   ";
	dump_filtered($cfile, sub {
		my ($ctx, $obj) = @_;
		my %p;

		my ($index_obj) = ($ctx->container_self() =~ /\[(\d+)\]/);
		if (defined($index_obj)) {
			$p{comment} .= "index $index_obj\n";
		}

		if ($ctx->object_isa("SOL::C::Vertex")) {
			$p{comment} = "";
			$p{dump} = sprintf("vv[%3d]: % 1.3f  % 1.3f  % 1.3f", $index_obj, @{$obj});
		}

		if ($ctx->object_isa("SOL::C::TextureCoordinate")) {
			$p{comment} = "";
			$p{dump} = sprintf("tv[%3d]: u = % 1.3f, v = % 1.3f", $index_obj, @{$obj});
		}

		if ($ctx->object_isa("SOL::C::Side")) {
			$p{comment} = "";
			$p{dump} = sprintf("sv[%3d]: n0 = % 1.3f  % 1.3f  % 1.3f, d = % 1.3f", $index_obj, @{$obj->{normal}}, $obj->{distance});
		}

		if ($ctx->object_isa("SOL::C::Edge")) {
			$p{comment} = "";
			$p{dump} = sprintf("ev[%3d]: %d -> %d", $index_obj, @{$obj});
		}

		if ($ctx->container_self() =~ /^\$self->\{index\}\[\d+\]$/) {
			$p{comment} = "";
			$p{dump} = sprintf("iv[%3d]: %s", $index_obj, ${$obj});
		}

		if ($ctx->container_isa("SOL::C::Geometry") or $ctx->container_isa("SOL::C::Lump") or $ctx->container_isa("SOL::C::Material")) {
			$p{comment} = "";
		}

		return \%p;
	});
}

1;
