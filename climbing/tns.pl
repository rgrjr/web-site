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
use warnings;

use Date::Parse;
use Date::Format;
use Getopt::Long;

my $summary_only_p = 0;
my $locations_file = "locations.tbl";
# These have to be specified as command-line options.
my ($start_time, $end_time, @holidays);
# Parse any args
GetOptions('summary!' => \$summary_only_p,
	   'locations=s' => \$locations_file,
	   'start=s' => sub { my ($arg, $start_date) = @_;
			      $start_time = str2time($start_date)
				  or die "Bad start date";
	   },
	   'end=s' => sub { my ($arg, $end_date) = @_;
			    $end_time = str2time($end_date)
				or die "Bad end date";
	   },
	   'holidays=s' 
	       => sub { my ($arg, $holiday) = @_;
			push(@holidays,
			     map { str2time($_) || die "Bad data '$_'";
			     } split(/,/, $holiday));
	   });

my @tuesday_locations = @ARGV;
my %tn_name;
my %tn_url;
my %tn_description;

# First, load locations.tbl.
open(IN, $locations_file) || die;
my $line;
while (defined($line = <IN>)) {
    chomp($line);
    my ($abbrev, $name, $url, $description) = split("\t", $line);
    $tn_name{$abbrev} = $name;
    $tn_url{$abbrev} = $url;
    $tn_description{$abbrev} = $description;
}

# Validate abbreviations.
my $n_errors = 0;
for my $abbrev (@tuesday_locations) {
    if (! $tn_name{$abbrev}) {
	warn("'$abbrev' is not one of '",
	     join("', '", sort(keys(%tn_name))), "'.\n");
	$n_errors++;
    }
}
exit(1)
    if $n_errors;

# If requested, summarize counts by location, and exit.
if ($summary_only_p) {
    my %count;
    for my $abbrev (@tuesday_locations) {
	$count{$abbrev}++;
    }
    for my $abbrev (sort(keys(%count))) {
	printf("%7d\t%s\n", $count{$abbrev}, $tn_name{$abbrev});
    }
    exit(0);
}

# Find out whether we're too close to a holiday.
my $secs_per_day = 24*60*60;
my $secs_per_week = 7*$secs_per_day;
sub after_holiday_p {
    # If a holiday falls on a Monday or Tuesday of the same week, then climbing
    # should happen on Wednesday.
    my ($time, $debug) = @_;

    for my $holiday (@holidays) {
	my $interval = $time-$holiday;
	warn "$debug time $time, holiday $holiday, interval $interval"
	    if $debug;
	return $interval
	    if $interval > 0 && $interval < 2*$secs_per_day;
    }
    return 0;
}

# Check start and end dates against holidays.
die "$0:  Must specify --start and --end dates.\n"
    unless $start_time && $end_time;
for my $holiday (@holidays) {
    warn("Holiday at ", time2str('%d %b %Y', $holiday), ' is not between ',
	 time2str('%d %b %Y', $start_time), ' and ', 
	 time2str('%d %b %Y', $end_time), ".\n")
	if $holiday < $start_time || $holiday > $end_time;
}

# Figure out the dates.
my $time = $start_time;
my @dates;
while ($time <= $end_time) {
    my $day;
    if (after_holiday_p($time)) {
	$day = time2str('%d %b (WED)', $time+$secs_per_day);
    }
    else {
	$day = time2str('%d %b', $time);
    }
    # warn "time $time => day $day\n";
    push(@dates, $day);
    $time += $secs_per_week;
}
die('tns.pl:  ', scalar(@tuesday_locations), ' locations for ',
    scalar(@dates), " dates.\n")
    if @dates != @tuesday_locations;

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
