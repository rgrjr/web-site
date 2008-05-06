# Makefile for "Advanced Control Structures in Parrot"
#
# $Id$

# make INSTALL_OPTS=--diff install
INSTALL = install.pl --show -m 444 ${INSTALL_OPTS}

all:	thumbnails 

pages  = index.html intro.html pir-basics.html simple.html
images = test.svg fact-1.svg
other  = acsip.css

thumbnails = fact-1.png

${thumbnails}:  %.png:  %.svg
	convert $^ -resize 33% $@
thumbnails:	${thumbnails}

install:	summary.text ${pages} ${images} ${thumbnails} ${other}
	${INSTALL} $^ /srv/www/htdocs/perl/acsip/
