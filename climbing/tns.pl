#!/usr/bin/perl -w
#
#    Make a Tuesday night schedule, using a list of locations provided on the
# command line.  For example, the original 2003 schedule was made with the
# following command:
#
#	tns.pl wmp dr bw tower hppa wmp sfp qq dr bw rr hpta cr tower rr sfp dr hppa cr rr hpta r1q dr bw tower wmp
#
# This depends on having data files in the right places, though.
#
#    Modification history:
#
# created.  -- rgr, 23-Mar-02.
# updated for 2003 schedule.  -- rgr, 15-Mar-03.
#

use strict;

my $summary_only_p = 0;
# my $tuesday_night_home = '/usr/local/aolserver/servers/rgrjr/pages/climbing/';
my $tuesday_night_home = '.';

# Parse any args
while ($ARGV[0] =~ /^-./) {
    my $arg = shift(@ARGV);
    if ($arg eq '-summary') {
	$summary_only_p = $arg;
    }
    else {
	die "tns.pl:  Unknown argument '$arg'.\nDied";
    }
}
my @tuesday_locations = @ARGV;
my %tn_name;
my %tn_url;
my %tn_description;

# First, load locations.tbl.
open(IN, "$tuesday_night_home/locations.tbl") || die;
my $line;
while (defined($line = <IN>)) {
    chomp($line);
    my ($abbrev, $name, $url, $description) = split("\t", $line);
    $tn_name{$abbrev} = $name;
    $tn_url{$abbrev} = $url;
    $tn_description{$abbrev} = $description;
}

# Read the dates.
open(IN, "$tuesday_night_home/dates.tbl") || die;
chomp(my @dates = <IN>);

if (@dates != @tuesday_locations) {
    warn (sprintf("tns.pl:  %d locations for %d dates.\n",
		  scalar @tuesday_locations, scalar @dates));
}

if ($summary_only_p) {
    # Summarize counts by location.
    my %count;
    foreach my $abbrev (@tuesday_locations) {
	$count{$abbrev}++;
    }
    foreach my $abbrev (sort(keys(%count))) {
	printf("%7d\t%s\n", $count{$abbrev}, $tn_name{$abbrev});
    }
}
else {
    # Generate the table rows using locations specified on the command line.
    my $i = 0;
    foreach my $abbrev (@tuesday_locations) {
	my $date = $dates[$i++];
	print "  <tr>\n    <td>$date</td>\n";
	print "    <td>$tn_name{$abbrev}</td>\n";
	my $url = $tn_url{$abbrev};
	print("    <td>",
	      ($url ? "<a href='$url'>" : ''),
	      $tn_description{$abbrev},
	      ($url ? "</a>" : ''),
	      "</td>\n");
	print "  </tr>\n";
    }
}
