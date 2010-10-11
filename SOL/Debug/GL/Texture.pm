package SOL::Debug::GL::Texture;

use strict;
use warnings;

use OpenGL qw(:all);
use Image::Magick;

sub create_texture {
	my $old_texture = glGetIntegerv_p(GL_TEXTURE_BINDING_2D);

	my $new_texture = (glGenTextures_p(1))[0];
	glBindTexture(GL_TEXTURE_2D, $new_texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	glBindTexture(GL_TEXTURE_2D, $old_texture);

	return $new_texture;
}

sub from_file {
	my ($file) = @_;

	my $new_texture = create_texture();

	my $old_texture = glGetIntegerv_p(GL_TEXTURE_BINDING_2D);
	glBindTexture(GL_TEXTURE_2D, $new_texture);

	my $img = Image::Magick->new();
	my $e = $img->Read($file);
	if ($e) {
		die("Error loading texture: $e");
	}

	my ($w, $h) = $img->Get("width", "height");
	my $d = pack("f*", $img->GetPixels(map => "RGBA", normalize => 1, width => $w, height => $h));
	glTexImage2D_s(
		GL_TEXTURE_2D,
		0,
		GL_RGBA,
		$w, $h,
		0,
		GL_RGBA,
		GL_FLOAT,
		$d
	);

	glBindTexture(GL_TEXTURE_2D, $old_texture);

	return $new_texture;
}

1;
