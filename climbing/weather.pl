#! /usr/bin/perl -w

use strict;
use Getopt::Long;
use Weather;

my $target_city = 'boston';

GetOptions('city=s' => \$target_city) or die;

my $iwin = new Weather::IWIN;
$iwin->fetch_zone_data(shift(@ARGV)
		       || 'http://iwin.nws.noaa.gov/iwin/ma/zone.html');
my $zones = $iwin->find_matching_zone_reports(split(/ *, */, $target_city));
if ($zones && @$zones) {
    for my $zone (@$zones) {
	$zone->print_report();
    }
}
else {
    print("No reports match '$target_city' (case-insensitive).\n");
}
