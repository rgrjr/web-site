# Makefile for home Web site maintenance.
#
# $Id$

# make INSTALL_OPTS=--diff install
INSTALL = install.pl --show -m 444 ${INSTALL_OPTS}

ifeq "${shell ls /var/www/vhosts 2>/dev/null}" ""
# [suse standard locations (since 8.1 anyway).  -- rgr, 29-May-04.]
server-root = /srv/www
web-page-root=${server-root}/htdocs
else
# [hacked for mediatemple (dv) server.  -- rgr, 10-Jul-11.]
server-root = /var/www/vhosts/rgrjr.com
web-page-root=${server-root}/httpdocs
endif
cgi-bin = ${server-root}/cgi-bin

# [the use of "pages" here is a misnomer.  -- rgr, 30-Aug-03.]
all-pages = ${top-pages} ${home-site-pages} ${serious-pages}
home-site-pages = ${bob-pages} ${girls-pages} ${climbing-pages}
serious-pages = ${emacs-pages} ${lisp-pages} \
		${linux-pages} ${generated-pages} \
		${security-pages} ${perl-pages}
top-pages = index.html site.css hits.html visitors.html robots.txt \
		web-site.html site-map.html change-history.html \
		random/doubleclick.png
bob-pages = bob/index.html bob/contact.html bob/damon-mahler.html \
		bob/tmda.html bob/gimp-toc.html bob/resume-extra.html \
		bob/resume.html
girls-pages = bob/anna/index.html bob/anna/anna-thumbnail-1.jpg \
	bob/anna/anna-2-small.jpg bob/anna/anna-2.jpg \
	bob/anna/anna-3-small.jpg bob/anna/anna-3.jpg \
	bob/anna/anna-portrait-1.jpg \
	bob/anna/anna-and-kitten-1.jpg bob/anna/anna-and-kitten-2.jpg \
	bob/liz/index.html bob/liz/lizzie-at-2-tn.jpg bob/liz/pic-preview.html \
	bob/liz/3sillies.jpg bob/liz/Anna-Bob1.jpg bob/liz/Anna-Bob2.jpg \
	bob/liz/Anna1.jpg bob/liz/Anna2.jpg bob/liz/Anna3.jpg \
	bob/liz/Shelda-Bob1.jpg bob/liz/Shelda-Bob2.jpg \
	bob/liz/Shelda-Bob3.jpg bob/liz/Shelda-cartwheel.jpg \
	bob/liz/liz-portrait-1.jpg bob/liz/liz-thumbnail-1.jpg \
	bob/liz/liz1.jpg bob/liz/liz2.jpg bob/liz/liz4.jpg \
	bob/liz/scowlingAnna.jpg
climbing-pages = climbing/index.html climbing/directions.html \
	climbing/tuesday-night.html climbing/tuesday-night-2000.html \
	climbing/tuesday-night-2001.html climbing/tuesday-night-2002.html \
	climbing/tuesday-night-2003.html climbing/tuesday-night-2004.html
# [oops; need to include the sun4u.xmodmaprc and i586.xmodmaprc files, which
# are referenced by the emacs/keyboard.html page.  -- rgr, 1-Dec-04.]
emacs-pages = emacs/index.html emacs/advanced.html emacs/custom.html \
	emacs/emacs_cheat.html emacs/keyboard.html \
	emacs/sun4u.xmodmaprc emacs/i586.xmodmaprc \
	emacs/overlap.html emacs/rgr-hacks.html emacs/self-doc.html \
	emacs/tutorial.html
generated-pages = linux/svn-dump.html linux/backup.pl.html linux/vacuum.pl.html
linux-pages = linux/index.html linux/tux-small.png \
	linux/antispam.html linux/backup.html \
	linux/disk-upgrade.html \
	linux/ether.html linux/striped-blue.png linux/striped-green.png \
	linux/striped-brown.png linux/striped-orange.png \
	linux/gconf.html linux/cd-burning.html \
	linux/howto.html linux/nis.html linux/qmail.html linux/squid.html \
	linux/ntp.html linux/ntpd.sh linux/tmda.html \
	linux/subversion.html linux/xml.html
security-pages = linux/security/index.html linux/security/check-logs.html \
	linux/security/firewall.html linux/security/old-xauth.html \
	linux/security/ssh.html linux/security/xauth.html \
	linux/security/alerts/index.html
perl-pages = perl/index.html perl/perl6-objects.html
lisp-pages = lisp/index.html

all:	change-history.html ${generated-pages}

change-history.html:	.
	./cvs-chrono-log.pl 365 change-history-template.html > $@

linux/svn-dump.html:	linux
	svn cat https://rgrjr.dyndns.org/svn/scripts/trunk/svn-dump.pl > $@.pl
	pod2html $@.pl > $@
	rm -f $@.pl
linux/backup.pl.html:	linux
	svn cat https://rgrjr.dyndns.org/svn/scripts/trunk/backup.pl \
		> linux/backup.pl
	pod2html linux/backup.pl > $@
	rm -f linux/backup.pl
linux/vacuum.pl.html:	linux
	svn cat https://rgrjr.dyndns.org/svn/scripts/trunk/vacuum.pl \
		> linux/vacuum.pl
	pod2html linux/vacuum.pl > $@
	rm -f linux/vacuum.pl

# /usr/local/aolserver/servers/rgrjr/modules/nslog/access.200405.log
current-hits.html:	/var/log/apache2/access_log-20081201.bz2 \
			/var/log/apache2/access_log-20081101.bz2 \
			/var/log/apache2/access_log-20081001.bz2 \
			/var/log/apache2/access_log-20080901.bz2 \
			/var/log/apache2/access_log-20080801.bz2 \
			/var/log/apache2/access_log-20080701.bz2
	../system/scripts/page-rankings.pl --top 20 --nosquid $^ > $@
Q12-hits.html:	/var/log/apache2/access_log.200506.log \
		/var/log/apache2/access_log.200505.log \
		/var/log/apache2/access_log.200504.log \
		/var/log/apache2/access_log.200503.log \
		/var/log/apache2/access_log.200502.log \
		/var/log/apache2/access_log.200501.log
	../system/scripts/page-rankings.pl --top 20 --nosquid $^ > $@
Q41-hits.html:	/var/log/apache2/access_log.200503.log \
		/var/log/apache2/access_log.200502.log \
		/var/log/apache2/access_log.200501.log \
		/var/log/apache2/access_log.200412.log \
		/var/log/apache2/access_log.200411.log \
		/var/log/apache2/access_log.200410.log
	../system/scripts/page-rankings.pl --top 20 --nosquid $^ > $@
Q34-hits.html:	/var/log/apache2/access_log.200412.log \
		/var/log/apache2/access_log.200411.log \
		/var/log/apache2/access_log.200410.log \
		/var/log/apache2/access_log.200409.log \
		/var/log/apache2/access_log.200408.log \
		/var/log/apache2/access_log.200407.log
	../system/scripts/page-rankings.pl --top 20 --nosquid $^ > $@

compare:
	@for file in ${all-pages}; do \
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

find-pages-to-update:
	find . -name '*.html' | sort > html-files.text
	fgrep -l site.css `cat html-files.text` > updated-files.text
	comm -3 html-files.text updated-files.text 
	# rm -f html-files.text updated-files.text

# note that install.pl installs only when it sees a difference, and makes
# numbered backups of the original versions.  that way, any changes made
# directly to the active pageroot will not be lost.  -- rgr, 3-Mar-04.
check-install-dir:
	test -d ${web-page-root}/climbing || exit 123
install:	check-install-dir install-pages install-cgi
install-pages:	change-history.html
	@for file in ${all-pages}; do \
	    ${INSTALL} $$file ${web-page-root}/$$file; \
	done
install-cgi:
	${INSTALL} -m 755 ra.cgi ${cgi-bin}/bob
# this assumes that *all* differences are due to changes in the active pageroot
# that need to be moved here.  any local changes will be lost, unless they've
# already been checked into the CVS repository.
reverse-install:
	@for file in ${all-pages}; do \
	    if ! cmp $$file ${web-page-root}/$$file; then \
		install.pl -show -m 444 ${web-page-root}/$$file .; \
	    fi; \
	done

clean:
	rm -f comment.text change-history.html new-hits.html older-hits.html
	rm -f html-files.text updated-files.text
wc:
	wc ${all-pages}
