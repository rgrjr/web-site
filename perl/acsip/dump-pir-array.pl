#! /usr/bin/perl -w
#
# Helper for generating same-fringe.*.pir test data, which is wicked tedious.
#
# [created.  -- rgr, 8-Jun-08.]
#
# $Id:$

use strict;
use warnings;

sub print_array {
    my $array = shift;

    '['.join(', ', map { ref($_) ? print_array($_) : $_; } @$array).']';
}

sub dump_elts {
    ## $thing is assumed to be an arrayref.
    my ($name, $array) = @_;

    my $len = @$array;
    print("\t## $name contains ", print_array($array), "\n",
	  "\t$name = new 'FixedPMCArray'\n",
	  "\t$name = $len\n");
    for my $i (0..@$array-1) {
	my $elt = $array->[$i];
	if (ref($elt) eq 'ARRAY') {
	    my $subname = $name.'_'.$i;
	    print("\t.local pmc $subname\n");
	    dump_elts($subname, $elt);
	    print("\t$name\[$i] = $subname\n");
	}
	elsif (ref($elt)) {
	    die "unhandled";
	}
	elsif ($elt =~ /^\d+$/) {
	    print("\t$name\[$i] = $elt\n");
	}
	else {
	    die "unhandled";
	}
    }
}

dump_elts(s1 => [1, 2, [3, 4], [[5, [6, 7], 8], 9, [10, 11]]]);
print "\n";
dump_elts(s1 => [1, 2, [3, 4], [[5, [6, 7], 8], 9, [10, 11]]]);
print "\n";
dump_elts(s2 => [1, 2, [3, 4], [[5, [6, 8], 7], 9, [10, 11]]]);
print "\n";
dump_elts(s3 => [1, 2, [3, 4], [[5, [6, 7]], 9, [10, 11]]]);
print "\n";
dump_elts(s4 => [1, [2, [3], 4], [5, [[[6, 7], 8], 9, [10, 11]]]]);
print "\n";
dump_elts(s5 => [1, [2, [3], 4], [5, [[[6, 7], 8], 9]]]);
