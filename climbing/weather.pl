#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Weather;

my $target_city = 'boston';
my $iwin_url = 'http://iwin.nws.noaa.gov/iwin/ma/zone.html';

GetOptions('city=s' => \$target_city,
	   'iwin=s' => \$iwin_url)
    or die;

if (@ARGV) {
    use Data::Dumper;
    for my $file (@ARGV) {
	print "$file => ", Dumper(Weather::Zone->parse_zone_data($file));
    }
}
else {
    my $iwin = new Weather::IWIN;
    $iwin->fetch_zone_data($iwin_url);
    my $zones = $iwin->find_matching_zone_reports(split(/ *, */, $target_city));
    if ($zones && @$zones) {
	for my $zone (@$zones) {
	    $zone->print_report();
	}
    }
    else {
	print("No reports match '$target_city' (case-insensitive).\n");
    }
}
