#!/usr/bin/perl -w

use strict;

BEGIN { unshift(@INC, '/srv/www/lib/perl'); }

use CGI qw(escapeHTML);
use CGI::Carp qw(fatalsToBrowser);
use Time::Local;

my $q = new CGI();

### Constants (or near enough).

my $seconds_per_day = 24*60*60;
my $max_day = 24855;	# a magic number.
my @days_of_the_week = qw(Sun Mon Tue Wed Thu Fri Sat);
my %month_labels
    = (1 => 'Jan',  2 => 'Feb',  3 => 'Mar',  4 => 'Apr',
       5 => 'May',  6 => 'Jun',  7 => 'Jul',  8 => 'Aug',
       9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec');
my ($this_sec, $this_min, $this_hour, $this_mday, $this_month, $this_year)
    = gmtime(time());

### Form parameters.

my $days1 = encode_date($q, 'day1');
my $days2 = encode_date($q, 'day2');
my $today = int(time()/$seconds_per_day);
my $name1 = escapeHTML($q->param('name1') || 'the first person');
my $name2 = escapeHTML($q->param('name2') || 'the second person');
my $page_title = ($q->param('name1') && $q->param('name2')
		  ? "Ratio anniversaries for $name1 and $name2"
		  : 'Ratio anniversaries');

### Subroutines.

sub encode_date {
    # Return the number of days since the epoch.
    my ($q, $prefix) = @_;

    my $year = $q->param($prefix.'_year');
    my $month = $q->param($prefix.'_month');
    my $day = $q->param($prefix.'_day');
    return undef
	unless $year && $month && $day && $year != -1;
    timegm(0, 0, 0, $day, $month-1, $year)/$seconds_per_day;
}

sub date_widget {
    my ($q, $prefix) = @_;

    join('',
	 $q->popup_menu($prefix.'_day', [1..31], $this_mday),
	 $q->popup_menu(-name => $prefix.'_month',
			-values => [1..12],
			-labels => \%month_labels,
			-default => 1+$this_month),
	 $q->popup_menu($prefix.'_year', [1920..2005], -1));
}

sub print_birthday {
    my ($days, $name) = @_;

    if (defined($days)) {
	my $delta = $today-$days;
	my ($sec, $min, $hour, $mday, $mon) = gmtime($days*$seconds_per_day);
	join('',
	     "$name ",
	     ($delta > 0 ? 'was born on '.print_date($days)
	      : $delta == 0 ? 'is born today (congratulations!)'
	      : 'will be born on '.print_date($days)),
	     ", which ",
	     ($delta == 1 ? 'was yesterday'
	      : $delta >= 0 ? "was $delta days ago"
	      : $delta == -1 ? 'will be tomorrow'
	      : 'will be in '.(-$delta). ' days'),
	     " ($days from the epoch). ",
	     ($mday == $this_mday && $mon == $this_month
	      ? "Happy birthday, $name!" : ''),
	     "\n");
    }
    else {
	"No valid birthday yet for $name.\n";
    }
}

sub print_date {
    my $days = shift;

    my ($sec, $min, $hour, $mday, $mon, $year, $wday)
	= gmtime($days*$seconds_per_day);
    sprintf('%s, %d %s %d',
	    $days_of_the_week[$wday], $mday, $month_labels{$mon+1}, $year+1900);
}

sub print_ratio {
    my ($date, $age1, $age2, $numerator, $denominator) = @_;

    my $was = ($date < $today ? 'was ' : 'will be ');
    print("On ", print_date($date), ", $name1 $was $age1 days old, which is ",
	  ($denominator == 1
	   ? "$numerator times"
	   : "$numerator/$denominator"),
	  " as old as $name2, who $was $age2 days.<br>\n");
}

my $n_multiples_truncated = 0;
sub try_ratio {
    # Looking for $x days in the future when $age1/$age2 = $n/$d:
    #	 ($age1+$x)*$d == ($age2+$x)*$n
    #	 $age1*$d + $x*$d == $age2*$n + $x*$n
    #	 $x*($d-$n) == $age2*$n-$age1*$d
    #	 $x = ($age2*$n-$age1*$d)/($d-$n)
    my ($age1, $age2, $n, $d, $results) = @_;

    my $x = int(($age2*$n - $age1*$d)/($d-$n));
    my $date = $today+$x;
    if ($date > $max_day) {
	$n_multiples_truncated++;
    }
    elsif ($date > $days1 && $date > $days2) {
	# age ratios don't count if they are before someone is born.
	$results->{$date} ||= [$date, $x, $n, $d];
    }
}

sub try_it {
    my $age1 = $today-$days1;
    my $age2 = $today-$days2;

    if ($age1 == $age2) {
	print(qq(Gee, $name1 and $name2 are twins; how about that.<br>
		 You will always be the same age every day of your lives.<br>
		 ));
	return;
    }
    my $max_multiple = 10;
    my %results;
    # if there is a large disparity in ages, then look for large integer
    # multiples.  we don't always do this, because such multiples get very dense
    # shortly after the younger person's birthday, and aren't very interesting.
    if ($age2 <= 0 || $age1/$age2 > $max_multiple) {
	for my $n (2..2*($age2 <= 0 ? $max_multiple : 1+int($age1/$age2))) {
	    try_ratio($age1, $age2, $n, 1, \%results);
	}
    }
    elsif ($age1 <= 0 || $age2/$age1 > $max_multiple) {
	for my $d (2..2*($age1 <= 0 ? $max_multiple : 1+int($age2/$age1))) {
	    try_ratio($age1, $age2, 1, $d, \%results);
	}
    }
    # go for non-integer fractions.
    for my $n (1..$max_multiple) {
	for my $d (1..$max_multiple) {
	    try_ratio($age1, $age2, $n, $d, \%results)
		unless $n == $d;
	}
    }
    # print what we've got.
    for my $date (sort { $a <=> $b; } (keys(%results))) {
	my ($date, $x, $n, $d) = @{$results{$date}};
	# print "[offset $x days] ";
	print_ratio($date, $age1+$x, $age2+$x, $n, $d);
    }
}

### Main code.

print($q->header,
      $q->start_html(-title => "Bob: $page_title",
		     -style => { src => '/site.css' }),
      $q->h2("Ratio Anniversaries"),
      "\n\n<p><a href='/'><tt>Home</tt></a> ",
      ": <a href='/bob/index.html'>Bob</a> ",
      ": Ratio Anniversaries\n<hr>\n");

print($q->start_form,
      $q->table($q->Tr($q->td('First person:'),
		       $q->td('Name: ',
			      $q->textfield(-name => 'name1', -size => 30)),
		       $q->td('Birthday: ', date_widget($q, 'day1'))),
		$q->Tr($q->td('Second person:'),
		       $q->td('Name: ',
			      $q->textfield(-name => 'name2', -size => 30)),
		       $q->td('Birthday: ', date_widget($q, 'day2')))),
      $q->submit,
      $q->end_form);

print("<h3>Birthdays</h3>\n\n<ul>",
      '  <li> ', print_birthday($days1, $name1),
      '  <li> ', print_birthday($days2, $name2),
      "</ul>\n\n");

print("<h3>Results</h3>\n");

try_it()
    if defined($days1) && defined($days2);

print("\n<p>Dates past ", print_date($max_day), " were truncated due to lack ",
      "of integer precision; sorry.<br>\n")
    if $n_multiples_truncated;

print(qq(<p>
	 <hr>
	 <address><a href="/bob/contact.html">Bob Rogers
	 <tt>&lt;rogers\@rgrjr.dyndns.org&gt;</tt></a></address>\n),
      $q->end_html, "\n");
