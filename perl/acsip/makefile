# Makefile for "Advanced Control Structures in Parrot"
#
# $Id$

# make INSTALL_OPTS=--diff install
INSTALL = install.pl --show -m 444 ${INSTALL_OPTS}

LISP   = lisp
LUA    = lua
PARROT = /usr/src/parrot/parrot
PERL   = perl

all:		thumbnails

pages         = index.html preface.html intro.html pir-basics.html simple.html \
		closures.html actions.html cont-1.html cont-2.html \
		cont-3.html coroutines.html conclusions.html
lisp-scripts  = map-elts-return.lisp map-elts-binary.lisp \
		map-elts-throw-closure.lisp map-elts-throw.lisp
perl-scripts  = factorial.pl.text map-elts-print.pl.text map-elts-find.pl.text \
		map-elts-binary.pl.text map-elts-throw.pl.text \
		same-fringe.flatten.pl.text
lua-scripts   = same-fringe.flatten.lua same-fringe.coro.lua
pir-scripts   = factorial.pir map-elts-print.pir map-elts-find.pir \
		map-elts-return.pir map-elts-binary.pir map-elts-throw.pir
scripts       = ${perl-scripts} ${lisp-scripts} ${lua-scripts} ${pir-scripts}
diagrams      = fact-1.svg fact-2.svg fact-3.svg goto-1.svg goto-2.svg \
		goto-3.svg return-1.svg return-2.svg \
		action-1.svg action-2.svg action-3.svg
other  	      = acsip.css summary.text

thumbnails = ${diagrams:.svg=.png}

${thumbnails}:  %.png:  %.svg
	convert $^ -resize 25% $@
thumbnails:	${thumbnails}

# This mostly makes sure that the Perl scripts and their PIR implementations
# produce the same output.  It does not check that these programs are consistent
# with their excerpts in the HTML.
test:		test-factorial test-closures test-cont-1 test-cont-2 \
		test-action test-cont-3 test-cont-4
	@echo All tests pass.
# Test the factorial.* programs.  [This gives different outputs on 32-bit
# systems:  Parrot promotes to BigInts, while Perl uses floats.  -- rgr,
# 7-May-08.]
test-factorial:
	${PARROT} factorial.pir > $@-pir-out.tmp
	${PERL} factorial.pl.text > $@-perl-out.tmp
	-diff -u $@-pir-out.tmp $@-perl-out.tmp
	rm -f $@-pir-out.tmp $@-perl-out.tmp
# Test the map-elts-print.* programs.
test-closures:
	${PARROT} map-elts-print.pir > $@-pir-out.tmp
	${PERL} map-elts-print.pl.text > $@-perl-out.tmp
	cmp $@-pir-out.tmp $@-perl-out.tmp
	rm -f $@-pir-out.tmp $@-perl-out.tmp
# Test the map-elts-find.* programs.
test-cont-1:
	${PARROT} map-elts-find.pir > $@-pir-out.tmp
	${PERL} map-elts-find.pl.text > $@-perl-out.tmp
	cmp $@-pir-out.tmp $@-perl-out.tmp
	rm -f $@-pir-out.tmp $@-perl-out.tmp
# Test the map-elts-return.* programs.
test-cont-2:
	${PARROT} map-elts-return.pir > $@-pir-out.tmp
	${LISP} -load map-elts-return.lisp -eval '(ext:quit)' \
		| fgrep -v Loading > $@-lisp-out.tmp
	cmp $@-pir-out.tmp $@-lisp-out.tmp
	rm -f $@-pir-out.tmp $@-lisp-out.tmp
# Test the map-elts-binary.* programs.
test-action:
	${PARROT} map-elts-binary.pir > $@-pir-out.tmp
	${LISP} -load map-elts-binary.lisp -eval '(ext:quit)' \
		| fgrep -v Loading > $@-lisp-out.tmp
	cmp $@-pir-out.tmp $@-lisp-out.tmp
	${PERL} map-elts-binary.pl.text > $@-perl-out.tmp
	cmp $@-pir-out.tmp $@-perl-out.tmp
	rm -f $@-*-out.tmp
# Test nonlocal dynamic exit (Continuations III).
test-cont-3:
	${PARROT} map-elts-throw.pir > $@-pir-out.tmp
	${LISP} -load map-elts-throw.lisp -eval '(ext:quit)' \
		| fgrep -v Loading > $@-lisp-out.tmp
	cmp $@-pir-out.tmp $@-lisp-out.tmp
	${PERL} map-elts-throw.pl.text > $@-perl-out.tmp
	cmp $@-pir-out.tmp $@-perl-out.tmp
	${LISP} -load map-elts-throw-closure.lisp -eval '(ext:quit)' \
		| fgrep -v Loading > $@-clo-out.tmp
	cmp $@-pir-out.tmp $@-clo-out.tmp
	rm -f $@-*-out.tmp
# Test the same-fringe.* programs.
test-cont-4:
	${LUA} same-fringe.coro.lua > $@-coro.tmp
	${LUA} same-fringe.map.lua > $@-map.tmp
	cmp $@-coro.tmp $@-map.tmp
	${LUA} same-fringe.flatten.lua > $@-flatten.tmp
	cmp $@-coro.tmp $@-flatten.tmp
	${PERL} same-fringe.flatten.pl.text > $@-perl.tmp
	cmp $@-coro.tmp $@-perl.tmp
	rm -f $@-*.tmp

install:	${pages} ${scripts} ${diagrams} ${thumbnails} ${other}
	${INSTALL} $^ /srv/www/htdocs/perl/acsip/

clean:
	rm -f ${thumbnails}
