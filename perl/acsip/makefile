# Makefile for "Advanced Control Structures in Parrot"
#
# $Id$

# make INSTALL_OPTS=--diff install
INSTALL = install.pl --show -m 444 ${INSTALL_OPTS}

all:
	@echo "Who, me?  Compile?  Get real."

pages  = index.html intro.html pir-basics.html simple.html
images = test.svg fact-1.svg
other  = acsip.css

install:	summary.text ${pages} ${images} ${other}
	${INSTALL} $^ /srv/www/htdocs/perl/acsip/
