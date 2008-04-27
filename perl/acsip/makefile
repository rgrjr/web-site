# Makefile for "Advanced Control Structures in Parrot"
#
# $Id: makefile 157 2008-03-15 22:43:29Z rogers $

# make INSTALL_OPTS=--diff install
INSTALL = install.pl --show -m 444 ${INSTALL_OPTS}

all:
	@echo "Who, me?  Compile?  Get real."

pages = summary.text
images = test.svg

install:	${pages} ${images}
	${INSTALL} $^ /srv/www/htdocs/perl/acsip/
