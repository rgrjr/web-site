# Makefile for home Web site maintenance.
#

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
home-site-pages = ${bob-pages} ${climbing-pages}
serious-pages = ${emacs-pages} ${lisp-pages} ${linux-pages} 
top-pages = index.html site.css hits.html robots.txt \
		web-site.html site-map.html change-history.html \
		random/doubleclick.png
bob-pages = bob/index.html bob/contact.html bob/resume-extra.html \
		bob/resume.html
climbing-pages = climbing/index.html climbing/directions.html \
	climbing/gym-to-crag-faq.html \
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
linux-pages = linux/index.html linux/tux-small.png \
	linux/backup.html \
	linux/disk-upgrade.html \
	linux/ether.html linux/striped-blue.png linux/striped-green.png \
	linux/striped-brown.png linux/striped-orange.png \
	linux/cd-burning.html \
	linux/howto.html \
	linux/ntp.html linux/ntpd.sh \
	linux/subversion.html linux/xml.html
lisp-pages = lisp/index.html

all:	change-history.html

change-history.html:	.
	./htmlize-log.pl 365 change-history-template.html > $@

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
	rm -f html-files.text updated-files.text

# note that install.pl installs only when it sees a difference, and makes
# numbered backups of the original versions.  that way, any changes made
# directly to the active pageroot will not be lost.  -- rgr, 3-Mar-04.
check-install-dir:
	test -d ${web-page-root}/climbing || exit 123
install:	check-install-dir install-pages
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
