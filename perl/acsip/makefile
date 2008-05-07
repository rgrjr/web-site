# Makefile for "Advanced Control Structures in Parrot"
#
# $Id$

# make INSTALL_OPTS=--diff install
INSTALL = install.pl --show -m 444 ${INSTALL_OPTS}

PARROT = /usr/src/parrot/parrot
PERL   = /usr/bin/perl

all:	thumbnails 

pages         = index.html intro.html pir-basics.html simple.html \
		closures.html cont-1.html
perl-scripts  = factorial.pl.text map-elts-print.pl.text map-elts-find.pl.text
pir-scripts   = factorial.pir     map-elts-print.pir
scripts       = ${perl-scripts} ${pir-scripts}
images 	      = test.svg fact-1.svg
other  	      = acsip.css summary.text

thumbnails = fact-1.png

${thumbnails}:  %.png:  %.svg
	convert $^ -resize 25% $@
thumbnails:	${thumbnails}

# This mostly makes sure that the Perl scripts and their PIR implementations
# produce the same output.  It does not check that these programs are consistent
# with their excerpts in the HTML.
test:	test-factorial test-closures
# Test the factorial.* programs.
test-factorial:
	${PARROT} factorial.pir > $@-pir-out.tmp
	${PERL} factorial.pl.text > $@-perl-out.tmp
	cmp $@-pir-out.tmp $@-perl-out.tmp
	rm -f $@-pir-out.tmp $@-perl-out.tmp
# Test the map-elts-print.* programs.
test-closures:
	${PARROT} map-elts-print.pir > $@-pir-out.tmp
	${PERL} map-elts-print.pl.text > $@-perl-out.tmp
	cmp $@-pir-out.tmp $@-perl-out.tmp
	rm -f $@-pir-out.tmp $@-perl-out.tmp

install:	${pages} ${scripts} ${images} ${thumbnails} ${other}
	${INSTALL} $^ /srv/www/htdocs/perl/acsip/

clean:
	rm -f ${thumbnails}
