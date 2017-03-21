#!/usr/bin/perl -w
#
# Convert vc-chrono-log.pl output from "svn log" to HTML.
#
# [created.  -- rgr, 24-Jul-03.]
#
# $Id$

use strict;
use warnings;

use Date::Parse;
use Date::Format;

my $date_format_string = '%Y-%m-%d %H:%M';
my $date_fuzz = 60;		# in seconds.
my %modifications;

my $html_p = 1;
my $n_days_ago = shift(@ARGV);
my $start_date = time2str($date_format_string, time-24*3600*$n_days_ago);
my $web_root;
for my $dir (qw(/srv/www/htdocs /var/www/html)) {
    $web_root = $dir, last
	if -d $dir;
}
warn "$0:  No web root.\n"
    unless defined($web_root);

### Subroutines.

sub escapeHTML {
    # Helper for writing HTML output.
    my ($string) = @_;

    $string =~ s{&}{&amp;}g;
    $string =~ s{<}{&lt;}g;
    $string =~ s{>}{&gt;}g;
    $string =~ s{"}{&quot;}g;
    return $string;
}

sub insert_html_log {

    print "<pre>\n";
    my $log_command = qq{git log --since '{$start_date}' | vc-chrono-log.pl |};
    my $line;
    open(my $in, $log_command)
	or die "oops; couldn't open pipe from svn:  $!";
    while (defined($line = <$in>)) {
	if ($line =~ m@^( *)=> /trunk/(\S+): +(.*)$@) {
	    my ($indentation, $file_name, $etc) = $line =~ //;
	    # warn "woop $file_name";
	    my $link_file_name
		= ($web_root && -r "$web_root/$file_name"
		   ? "<a href='/$file_name'><tt>/$file_name</tt></a>"
		   : "<tt>$file_name</tt>");
	    print("$indentation=> $link_file_name ", escapeHTML($etc), "\n");
	}
	elsif ($line =~/author: rogers/) {
	    # boring; skip.
	}
	else {
	    print escapeHTML($line);
	}
    }
    print "</pre>\n\n";
}

### Main loop.

while (<>) {
    if ($_ =~ /^\s*<!--\s+insert-log\s*-->\s*$/) {
	insert_html_log();
    }
    else {
	print;
    }
}
