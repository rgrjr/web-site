
all:

sched-2004.html:
	./tns.pl wmp dr bw tower hppa wmp sfp qq dr \
		 bw rr hpta cr tower rr sfp dr hppa \
		 cr rr hpta r1q dr bw tower wmp > $@

2005-sites =	wmp dr bw hppa \
		wmp sfp bw dr \
		qq hpta rr bw cr \
		tower rr sfp hppa \
		dr cr rr hpta choice \
		r1q dr bw wmp
sched-2005.html:
	./tns.pl ${2005-sites} > $@

2006-sites =	wmp  dr   bw   hppa \
		wmp  dr   bw   hpta  qq \
		sfp  bw   rr   cr \
		sfp  hppa rr   dr \
		sfp  cr   rr   hpta  wmp \
		r1q  dr   bw         wmp
sched-2006.html:
	./tns.pl ${2006-sites} > $@

2007-sites =	wmp  dr   bw   hppa \
		wmp  dr   bw   hpta  qq \
		sfp  bw   rr   cr \
		sfp  hppa rr   dr    wmp \
		sfp  cr   rr   hpta \
		r1q  dr   bw   wmp
sched-2007.html:
	./tns.pl ${2007-sites} > $@

2008-sites =	wmp  dr   bw   hppa  wmp \
		dr   bw   hpta qq \
		sfp  bw   rr   cr \
		sfp  hppa rr   dr    wmp \
		sfp  cr   rr   bw \
		r1q  hpta dr   bw   wmp
sched-2008.html:
	./tns.pl ${2008-sites} > $@

2009-sites =	wmp  dr   bw   hppa \
		wmp  dr   hpta qq \
		sfp  bw   rr   cr   sfp  \
		hppa rr   dr   wmp \
		sfp  cr   rr   bw \
		hpta  r1q dr   bw   wmp
sched-2009.html:
	./tns.pl --holidays 2009-05-25,2009-7-04,2009-9-7 \
		--start 2009-04-07 --end 2009-9-30 \
		${2009-sites} > $@

# This is not the best test case, as it depends on the locations.tbl file
# contents.
test-tns-1:
	./tns.pl --holidays 2008-07-04,2008-05-26,2008-09-01 \
		--start 2008-04-01 --end 2008-9-30 \
		 ${2008-sites} > $@.tmp
	cmp $@.tmp $@.html
	rm -f $@.tmp

stats:
	rm -f $@.tmp
	for location in ${2005-sites}; do echo $$location >> $@.tmp; done
	sort $@.tmp | uniq -c | sort -nr
	rm -f $@.tmp
	for location in ${2006-sites}; do echo $$location >> $@.tmp; done
	sort $@.tmp | uniq -c | sort -nr
	rm -f $@.tmp
	for location in ${2007-sites}; do echo $$location >> $@.tmp; done
	sort $@.tmp | uniq -c | sort -nr

clean:
	rm -f $@.tmp sched-2004.html sched-2005.html sched-2006.html
