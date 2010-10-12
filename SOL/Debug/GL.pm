package SOL::Debug::GL;

use strict;
use warnings;
use 5.010;

use Readonly;

use OpenGL qw(:all);
use Time::HiRes qw(sleep time);

use SOL::Debug::GL::Texture;

# the sol object currently being dumped
my $sol;
my $display_list;

# GLUT event handlers

sub resize {
	my ($x, $y) = @_;
	glViewport(0, 0, $x, $y);
	update_vp($x, $y);
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

sub init_gl {
	glutInit();
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
	glutInitWindowSize(800, 450);
	glutCreateWindow("libSOL Debug Window");

	glutReshapeFunc   (\&resize);
	glutIdleFunc      (\&idle);
	glutDisplayFunc   (\&draw);
}

sub init_vp {
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glColor3f(1.0, 1.0, 1.0);

	update_vp(800, 450);
}

sub update_vp {
	my ($x, $y) = @_;
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(50, $x / $y, 1, 50);
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
			die("Couldn't find texture \"$mat->{texture}\" in datadir \"$datadir\"");
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

	# have a rotating camera.
	my @cam_obj = (0, 0, 0);
	if (@{$sol->{goal}}) {
		@cam_obj = @{$sol->{goal}->[0]->{position}};
	}

	glLoadIdentity();
	gluLookAt(
		$cam_obj[0] + (15 + 2 * sin(time() - $^T)) * cos(time() - $^T),
		$cam_obj[1] + (15 + 2 * sin(time() - $^T)) * sin(time() - $^T),
		$cam_obj[2] + 4 + 3 * sin(time() - $^T),
		@cam_obj,
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

