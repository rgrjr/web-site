#!/usr/bin/perl -w

use strict;

BEGIN { unshift(@INC, '/usr/local/aolserver/servers/rgrjr/modules/lib/perl'); }

use Weather;
use CGI;

my $q = new CGI();
my $source_page = 'http://iwin.nws.noaa.gov/iwin/ma/zone.html';

my $target_city = $q->param('city') || 'boston';
my $iwin = new Weather::IWIN(query => $q);
print($q->header,
      $q->start_html(-title => "Bob: Climbing: $target_city weather",
		     -style => { src => '/site.css' }),
      $q->h2("Current NOAA $target_city weather reports"),
      "\n\n<p><a href='/'><tt>Home</tt></a> ",
      ": <a href='/climbing/'>Climbing</a> : Weather\n<hr>\n");
my $zones;
my $iwin_link = $q->a({href => $source_page},
		      'IWIN zone forecast for Massachusetts');
if ($target_city) {
    print("Current forecast extracted from $iwin_link:\n<br>\n<br>\n");
    $iwin->fetch_zone_data($source_page);
    $zones = $iwin->find_matching_zone_reports(split(/ *, */, $target_city));
}
my $n_zones = scalar(@$zones);
my $total_message = join('', "Total of $n_zones zone report",
			 ($n_zones==1 ? '' : 's'), " selected");
if ($n_zones) {
    print("$total_message:<br>\n");
    for my $zone (@$zones) {
	$zone->print_report($q);
    }
    print("<hr>\n<p>$total_message from $iwin_link.\n");
    print("<p>Note:  This page does not update by itself.  ",
	  "To see whether the forecast has been updated, please click ",
	  "your browser's <tt>[Reload]</tt> button.\n");
}
elsif ($target_city) {
    print("No reports match '$target_city' (case-insensitive).\n");
}
else {
    print("Need a target city first.\n");
}
print(qq(<p>
	 <hr>
	 <address><a href="mailto:rogers\@rgrjr.dyndns.org">Bob Rogers
	 <tt>&lt;rogers\@rgrjr.dyndns.org&gt;</tt></a></address>\n),
      $q->end_html, "\n");
