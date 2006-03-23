#!/usr/bin/perl -w
#
# Convert the file-oriented "cvs log" output into a historical narrative, in
# reverse chronological order.
#
# [created.  -- rgr, 24-Jul-03.]
#
# $Id$

use strict;
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
for my $dir (qw(/usr/local/aolserver/servers/rgrjr/pages /srv/www/htdocs)) {
    $web_root = $dir, last
	if -d $dir;
}
warn "$0:  No web root.\n"
    unless defined($web_root);

sub record_file_rev_comment {
    my ($file_name, $file_rev, $date_etc, $comment) = @_;

    my $date = ($date_etc =~ /date: *([^;]+); */ 
		? ($date_etc =~ s///, $1)
		: '???');
    # warn "[got ($file_name, $file_rev, $date_etc):]\n";
    if ($date eq '???') {
	warn "Oops; can't identify date in '$date_etc' -- skipping.\n";
    }
    else {
	my $encoded_date = str2time($date, 'UTC');
	$date_etc =~ s/state: Exp; *//;
	push(@{$modifications{$comment}{$encoded_date}},
	     [$file_name, $file_rev, $date_etc]);
    }
}

sub print_file_rev_comments {
    # Print all revision comments, sorted by date and grouped by comment.

    # examine entries by comment, then by date, combining all that have the
    # identical comment and nearly the same date.
    my @combined_entries;
    for my $comment (sort(keys(%modifications))) {
	my $last_date;
	my @entries;
	for my $date (sort(keys(%{$modifications{$comment}}))) {
	    if ($last_date && $date-$last_date > $date_fuzz) {
		# the current entry probably represents a "cvs commit" event
		# that is distinct from the previous entry(ies).
		push(@combined_entries, [$last_date, $comment, @entries]);
		@entries = ();
		undef($last_date);
	    }
	    $last_date ||= $date;
	    push(@entries, @{$modifications{$comment}{$date}});
	}
	push(@combined_entries, [$last_date, $comment, @entries])
	    if @entries;
    }
    # now resort by date and print them out.
    for my $date_entry (sort { -($a->[0] <=> $b->[0]); } @combined_entries) {
	my $date = time2str($date_format_string, shift(@$date_entry));
	my $comment = shift(@$date_entry);
	print "$date:\n";
	for my $line (split("\n", escapeHTML($comment))) {
	    print "  $line\n"
		if $line;
	}
	# CVS sorts the file names, but combining sets of entries with similar
	# dates can make them come unsorted.
	for my $entry (sort { $a->[0] cmp $b->[0]; } @$date_entry) {
	    my ($file_name, $file_rev, $date_etc) = @$entry;
	    my $pretty_file_name
		= ($web_root && -r "$web_root/$file_name"
		   ? "<a href='/$file_name'><tt>/$file_name</tt></a>"
		   : "<tt>$file_name</tt>");
	    print "  => $pretty_file_name $file_rev:  $date_etc\n";
	}
	print "\n";
    }
}

### Parser top level.

sub cvs_log_to_html_log {
    print "<pre>\n";
    # state is one of qw(none headings descriptions).
    my $state = 'none';
    my $file_name;
    my $line;
    open(IN, "cvs -q log -d '>$start_date' |")
	or die "oops; couldn't open pipe from cvs:  $!";
    while (defined($line = <IN>)) {
	if ($line =~ /^RCS file: /) {
	    # start of a new entry.
	    $state = 'headings';
	}
	elsif ($state eq 'descriptions') {
	    # print($line);
	    $line =~ /^revision (.*)$/
		or warn "[oops; expected revision here.]\n";
	    my $file_rev = $1;
	    chomp(my $date_etc = <IN>);
	    my $comment = '';
	    $line = <IN>;
	    if ($line =~ /^branches: /) {
		chomp($line);
		$date_etc .= "  ".$line;
		$line = <IN>;
	    }
	    while ($line !~ /^---+$|^===+$/) {
		$comment .= $line;
		$line = <IN>;
	    }
	    record_file_rev_comment($file_name, $file_rev, $date_etc, $comment);
	    $state = ($line =~ /^========/ ? 'none' : 'descriptions');
	}
	# $state eq 'headings'
	elsif ($line =~ /^([^:]+):\s*(.*)/) {
	    # processing the file header.
	    my $tag = $1;
	    if ($tag eq 'description') {
		$line = <IN>;
		$state = ($line =~ /^========/ ? 'none' : 'descriptions');
	    }
	    elsif ($tag eq 'Working file') {
		chomp($file_name = $2);
	    }
	}
    }
    close(IN);
    warn "[oops; final state is $state.]\n"
	unless $state eq 'none';
    print_file_rev_comments();

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
