package SOL::Debug::GL;

use strict;
use warnings;
use 5.010;

use Readonly;
use Math::Trig;

use OpenGL qw(:all);
use Time::HiRes qw(sleep time);

use SOL::Debug::GL::Texture;

# the sol object currently being dumped
my $sol;
my $display_list;

# camera
my @cam_eye = (0, 0, 0);
my @cam_dir = (0, 1, 0);
my $cam_mode = "move";
my $cam_fov = 50;
my $cam_clip_far = 50;

# GLUT event handlers

Readonly my $cam_speed => 1/8;   # move speed
Readonly my $cam_aspeed => 1/32; # look speed
Readonly my $cam_fspeed => 1;    # fast speed

my ($win_x, $win_y) = (800, 450);

sub resize {
	my ($x, $y) = @_;
	glViewport(0, 0, $x, $y);
	($win_x, $win_y) = ($x, $y);
	update_vp();
	draw();
	glFlush();
	glutSwapBuffers();
}

sub idle {
	draw();
	glFlush();
	glutSwapBuffers();
	sleep(1/50);
}

sub keyboard {
	my ($key, $x, $y) = @_;
	my $c = chr($key);

	if ($c eq "\e") {
		exit();
	} elsif ($c eq " ") {
		$cam_mode = ($cam_mode eq "look" ? "move" : "look");
	} elsif ($c eq "+") {
		$cam_fov += 5;
		update_vp();
	} elsif ($c eq "-") {
		$cam_fov -= 5;
		update_vp();
	} elsif ($c eq "(") {
		$cam_clip_far -= 5;
		update_vp();
	} elsif ($c eq ")") {
		$cam_clip_far += 5;
		update_vp();
	}
}

sub special {
	my ($key, $x, $y) = @_;

	if ($cam_mode eq "look") {
		my $a_lr = atan2($cam_dir[1], $cam_dir[0]);
		my $a_ud = acos($cam_dir[2]);

		if ($key == GLUT_KEY_UP) {
			$a_ud -= $cam_aspeed;
		} elsif ($key == GLUT_KEY_DOWN) {
			$a_ud += $cam_aspeed;
		} elsif ($key == GLUT_KEY_RIGHT) {
			$a_lr -= $cam_aspeed;
		} elsif ($key == GLUT_KEY_LEFT) {
			$a_lr += $cam_aspeed;
		}

		@cam_dir = (
			sin($a_ud) * cos($a_lr),
			sin($a_ud) * sin($a_lr),
			cos($a_ud)
		);
	} elsif ($cam_mode eq "move") {
		if ($key == GLUT_KEY_UP) {
			$cam_eye[$_] += $cam_speed * $cam_dir[$_] for (0..2);
		} elsif ($key == GLUT_KEY_DOWN) {
			$cam_eye[$_] -= $cam_speed * $cam_dir[$_] for (0..2);
		} elsif ($key == GLUT_KEY_PAGE_UP) {
			$cam_eye[$_] += $cam_fspeed * $cam_dir[$_] for (0..2);
		} elsif ($key == GLUT_KEY_PAGE_DOWN) {
			$cam_eye[$_] -= $cam_fspeed * $cam_dir[$_] for (0..2);
		} elsif ($key == GLUT_KEY_LEFT or $key == GLUT_KEY_RIGHT) {
			my @v;
			if ($key == GLUT_KEY_LEFT) {
				$v[0] = -$cam_dir[1];
				$v[1] = +$cam_dir[0];
			} else {
				$v[0] = +$cam_dir[1];
				$v[1] = -$cam_dir[0];
			}
			my $l = sqrt($v[0] ** 2 + $v[1] ** 2);
			$v[0] /= $l;
			$v[1] /= $l;
			$cam_eye[0] += $v[0] * $cam_speed;
			$cam_eye[1] += $v[1] * $cam_speed;
		}
	}
}

sub init_gl {
	glutInit();
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
	glutInitWindowSize($win_x, $win_y);
	glutCreateWindow("libSOL Debug Window");

	glutKeyboardFunc  (\&keyboard);
	glutSpecialFunc   (\&special);
	glutReshapeFunc   (\&resize);
	glutIdleFunc      (\&idle);
	glutDisplayFunc   (\&draw);
}

sub init_vp {
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glColor3f(1.0, 1.0, 1.0);

	update_vp();
}

sub update_vp {
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective($cam_fov, $win_x / $win_y, 1, $cam_clip_far);
	glMatrixMode(GL_MODELVIEW);
}

# mtrl loader

Readonly my $datadir => "/home/penma/build/neverball/data";

my %textures;

# $mtrl = SOL::Material
# setup the GL to draw with something that resembles the texture specified by the given SOL::Material.
sub activate_mtrl {
	my ($mat) = @_;
	if (!exists($textures{$mat->{texture}})) {
		for my $ext ("png", "jpg") {
			if (-e "$datadir/$mat->{texture}.$ext") {
				$textures{$mat->{texture}} = SOL::Debug::GL::Texture::from_file("$datadir/$mat->{texture}.$ext");
			}
		}
		if (!exists($textures{$mat->{texture}})) {
			warn("Couldn't find texture \"$mat->{texture}\" in datadir \"$datadir\" - replacing with \"invisible\"");
			$textures{$mat->{texture}} = SOL::Debug::GL::Texture::from_file("$datadir/mtrl/invisible.png");
		}
	}
	glBindTexture(GL_TEXTURE_2D, $textures{$mat->{texture}});
	glMaterialfv_p(GL_FRONT_AND_BACK, GL_AMBIENT , @{$mat->{ambient}});
	glMaterialfv_p(GL_FRONT_AND_BACK, GL_DIFFUSE , @{$mat->{diffuse}});
	glMaterialfv_p(GL_FRONT_AND_BACK, GL_SPECULAR, @{$mat->{specular}});
	glMaterialfv_p(GL_FRONT_AND_BACK, GL_EMISSION, @{$mat->{emission}});
	glMaterialf   (GL_FRONT_AND_BACK, GL_SHININESS,  $mat->{specular_exponent});
}

#

sub draw_geom {
	my ($geom) = @_;
	activate_mtrl($geom->{material});
	glBegin(GL_TRIANGLES);
	for my $vn (0..2) {
		glNormal3f  (@{$geom->{sides}->[$vn]->{normal}});
#		glTexCoord2f(@{$geom->{texture_coordinates}->[$vn]});
		glTexCoord2f($geom->{texture_coordinates}->[$vn]->[0], -$geom->{texture_coordinates}->[$vn]->[1]);
		glVertex3f  (@{$geom->{vertices}->[$vn]});
	}
	glEnd();
}

sub init_dl {
	my $dl = glGenLists(1);
	glNewList($dl, GL_COMPILE);
	print STDERR "prerendering geometry: ";
	my $b = 0;
	foreach my $body (@{$sol->{body}}) {
		print STDERR "[$b]    %";
		$b++;
		glPushMatrix();
		if (defined($body->{path})) {
			glTranslatef(@{$sol->{path}->{$body->{path}}->{position}});
		}

		my $g = 0;
		foreach my $geom (@{$body->{geometries}}) {
			print STDERR sprintf("\b\b\b\b%3d%%", 100 * ($g++) / @{$body->{geometries}});
			draw_geom($geom);
		}
		print STDERR "\b\b\b\b100% ";

		glPopMatrix();
	}
	glEndList();
	$display_list = $dl;
}

sub draw {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glLoadIdentity();
	gluLookAt(
		@cam_eye,
		$cam_eye[0] + $cam_dir[0], $cam_eye[1] + $cam_dir[1], $cam_eye[2] + $cam_dir[2],
		0, 0, 1,
	);

	glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);
		glLightfv_p(GL_LIGHT0, GL_POSITION, -8, -8, 32, 0);
		glLightfv_p(GL_LIGHT0, GL_DIFFUSE , 1., .8, .8, 1);
		glLightfv_p(GL_LIGHT0, GL_SPECULAR, 1., .8, .8, 1);
		glEnable(GL_LIGHT1);
		glLightfv_p(GL_LIGHT1, GL_POSITION, +8, +8, 32, 0);
		glLightfv_p(GL_LIGHT1, GL_DIFFUSE , .8, 1., .8, 1);
		glLightfv_p(GL_LIGHT1, GL_SPECULAR, .8, 1., .8, 1);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
	glColor3f(1,1,1);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glCallList($display_list);

	# render coordinate axes
	glDisable(GL_LIGHTING);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_BLEND);
	glColor3f(1, 0, 0); glBegin(GL_LINES); glVertex3f(0, 0, 0); glVertex3f(1, 0, 0); glEnd();
	glColor3f(0, 1, 0); glBegin(GL_LINES); glVertex3f(0, 0, 0); glVertex3f(0, 1, 0); glEnd();
	glColor3f(0, 0, 1); glBegin(GL_LINES); glVertex3f(0, 0, 0); glVertex3f(0, 0, 1); glEnd();
}

sub sol_dump {
	my ($sol_in) = @_;
	$sol = $sol_in;
	print STDERR "dumping sol\n";
	init_gl();
	init_vp();
	init_dl();
	glutMainLoop();
}

1;

