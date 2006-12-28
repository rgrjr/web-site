
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
