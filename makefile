# Makefile for home Web site maintenance.
#
# $Id$

# make INSTALL_OPTS=--noinstall install
INSTALL = install.pl --show -m 444 ${INSTALL_OPTS}

# [suse standard location (since 8.1 anyway).  -- rgr, 29-May-04.]
# make web-page-root=/srv/www/htdocs install
web-page-root = /usr/local/aolserver/servers/rgrjr/pages
# [aolserver location (not yet configured for suse).  -- rgr, 15-Jun-04.]
cgi-root = /usr/local/aolserver/servers/rgrjr/modules
cgi-bin = ${cgi-root}/cgi
cgi-lib-perl = ${cgi-root}/lib/perl

# [the use of "pages" here is a misnomer.  -- rgr, 30-Aug-03.]
all-pages = ${top-pages} ${home-site-pages} ${serious-pages}
home-site-pages = ${bob-pages} ${girls-pages} ${climbing-pages}
serious-pages = ${emacs-pages} ${ilisp-pages} \
		${linux-pages} ${security-pages} ${perl-pages}
top-pages = index.html site.css hits.html visitors.html robots.txt \
		web-site.html site-map.html change-history.html \
		random/doubleclick.png
bob-pages = bob/index.html bob/contact.html bob/damon-mahler.html \
		bob/gimp-toc.html bob/resume-extra.html bob/resume.html
girls-pages = bob/anna/index.html bob/anna/anna-thumbnail-1.jpg \
	bob/liz/index.html bob/liz/lizzie-at-2-tn.jpg bob/liz/pic-preview.html
climbing-pages = climbing/index.html climbing/directions.html \
	climbing/ephemeris.html climbing/lists.html \
	climbing/tuesday-night.html climbing/tuesday-night-2000.html \
	climbing/tuesday-night-2001.html climbing/tuesday-night-2002.html \
	climbing/tuesday-night-2003.html
# [these still exist, but are obsolete.  -- rgr, 30-Aug-03.]
# climbing/br-web-review.html climbing/br-work-flow.html
emacs-pages = emacs/index.html emacs/advanced.html emacs/custom.html \
	emacs/emacs_cheat.html emacs/keyboard.html \
	emacs/overlap.html emacs/rgr-hacks.html emacs/self-doc.html \
	emacs/study.html emacs/tutorial.html emacs/vm+qmail.html
ilisp-pages = emacs/ilisp/index.html emacs/ilisp/new-meta-point.html
linux-pages = linux/index.html linux/tux-small.png \
	linux/backup.html linux/backup.pl.html \
	linux/cl-xml-notes.html linux/disk-upgrade.html linux/ether.html \
	linux/gconf.html linux/howto.html linux/ntp.html linux/tmda.html \
	linux/xml.html
security-pages = linux/security/index.html linux/security/check-logs.html \
	linux/security/firewall.html linux/security/old-xauth.html \
	linux/security/ssh.html linux/security/xauth.html \
	linux/security/alerts/index.html
perl-pages = perl/index.html perl/sub-memory-leak.html

all:	change-history.html

change-history.html:	change-history-template.html
	./cvs-chrono-log.pl $^ > $@

new-hits.html:	/usr/local/aolserver/servers/rgrjr/modules/nslog/access.200405.log
	../system/scripts/make-popular-pages.pl --nosquid $^ > $@
older-hits.html:
	../system/scripts/make-popular-pages.pl --nosquid /usr/local/aolserver/servers/rgrjr/modules/nslog/access.200404.log > $@
	../system/scripts/make-popular-pages.pl --nosquid /usr/local/aolserver/servers/rgrjr/modules/nslog/access.200403.log >> $@
	../system/scripts/make-popular-pages.pl --nosquid /usr/local/aolserver/servers/rgrjr/modules/nslog/access.200402.log >> $@
	../system/scripts/make-popular-pages.pl --nosquid /usr/local/aolserver/servers/rgrjr/modules/nslog/access.200401.log >> $@

compare:
	for file in ${all-pages}; do \
	    if ! cmp $$file ${web-page-root}/$$file; then \
		diff -u $$file ${web-page-root}/$$file; \
	    fi; \
	done

full-compare:
	(cd ${web-page-root}; find . -type f) \
	    | grep -Ev '~$$|/(pics|molly|icancad)/' > pageroot-files.tmp
	-for file in `cat pageroot-files.tmp`; do \
	    cmp $$file ${web-page-root}/$$file; \
	done
	rm pageroot-files.tmp

find-id:
	find . -name '*.html' | xargs fgrep -l site.css | xargs fgrep '$$Id:'

# note that install.pl installs only when it sees a difference, and makes
# numbered backups of the original versions.  that way, any changes made
# directly to the active pageroot will not be lost.  -- rgr, 3-Mar-04.
check-install-dir:
	test -d ${web-page-root} || exit 123
install:	check-install-dir install-pages install-cgi
install-pages:
	for file in ${all-pages}; do \
	    ${INSTALL} $$file ${web-page-root}/$$file; \
	done
install-cgi:
	${INSTALL} climbing/Weather.pm ${cgi-lib-perl}
	${INSTALL} -m 755 climbing/weather.cgi ${cgi-bin}/weather
# this assumes that *all* differences are due to changes in the active pageroot
# that need to be moved here.  any local changes will be lost, unless they've
# already been checked into the CVS repository.
reverse-install:
	for file in ${all-pages}; do \
	    if ! cmp $$file ${web-page-root}/$$file; then \
		install.pl -show -m 444 ${web-page-root}/$$file .; \
	    fi; \
	done

clean:
	rm -f comment.text change-history.html new-hits.html older-hits.html
wc:
	wc ${all-pages}
