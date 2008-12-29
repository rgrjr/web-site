#!/usr/bin/perl -w
#
# Convert the file-oriented "cvs log" output into a historical narrative, in
# reverse chronological order.
#
# [created.  -- rgr, 24-Jul-03.]
#
# $Id$

use strict;
use warnings;

use Date::Parse;
use Date::Format;
use CGI qw(escapeHTML);

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

### Subroutine.

sub cvs_log_to_html_log {

    print "<pre>\n";
    my $log_command
	= join(' | ',
	       "svn log --xml --verbose --revision '{$start_date}:HEAD'",
	       'vc-chrono-log.rb |');
    my $line;
    open(my $in, $log_command)
	or die "oops; couldn't open pipe from svn:  $!";

    my $print_file_line = sub {
	# Helper sub that takes care of file markup & formatting.
	my ($indentation, $file_name, $etc) = @_;

	my $pretty_file_name
	    = ($web_root && -r "$web_root/$file_name"
	       ? "<a href='/$file_name'><tt>/$file_name</tt></a>"
	       : "<tt>$file_name</tt>");
	print("$indentation=> $pretty_file_name ", escapeHTML($etc), "\n");
    };

    while (defined($line = <$in>)) {
	if ($line =~ m@^( *)=> /trunk/(\S+): +(.*)$@) {
	    # SVN output.
	    $print_file_line->($line =~ //);
	}
	elsif ($line =~ /^( *)=> (\S+) (\S+): +(.*)$/) {
	    # CVS output.
	    my ($indentation, $file_name, $file_rev, $etc) = $line =~ //;
	    $print_file_line->($indentation, $file_name,
			       "$file_rev:  $etc");
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
	cvs_log_to_html_log();
    }
    else {
	print;
    }
}
