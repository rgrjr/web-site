
use strict;

package Weather::Thing;

# Base class for weather objects.

sub new {
    my $class = shift;

    my $self = bless({}, $class);
    $self->shared_initialize(@_);
    $self;
}

sub shared_initialize {
    my $self = shift;

    while (@_) {
	my $method = shift;
	my $argument = shift;
	$self->$method($argument)
	    if $self->can($method);
    }
    $self;
}

package Weather::Zone;

use base qw(Weather::Thing);

# define instance accessors.
sub BEGIN {
  no strict 'refs';
  for my $method (qw(zone_codes cities date 
		     location_description weather_report)) {
    my $field = '_' . $method;
    *$method = sub {
      my $self = shift;
      @_ ? ($self->{$field} = shift, $self) : $self->{$field};
    }
  }
}

sub zone_equal_p {
    my ($zone1, $zone2) = @_;

    ($zone1->zone_codes eq $zone2->zone_codes
     # [assume that these are good if the zone codes match.]
     # && $zone1->cities eq $zone1->cities
     && $zone1->date eq $zone2->date
     && $zone1->weather_report eq $zone2->weather_report);
}

sub new_from_data {
    my ($class, $zone_codes, $zone_data, $line_number) = @_;
    $class = ref($class) || $class;
    $line_number ||= 0;

    # warn("[new_from_data at $line_number, size ", length($zone_data), ".]\n");
    # die $zone_data;
    my ($header, $data) = split(/\n\n/, $zone_data, 2);
    my @header_lines = split("\n", $header);
    my $date = pop(@header_lines);
    my ($prefix, $blather, $cities)
	= split(/including the (cities|city) of/i,
		join("\n", @header_lines));
    if (! $cities) {
	# warn "[failed on '$header']\n";
	return;
    }
    $cities =~ s/\n//g;
    $cities =~ s/^\.+//;
    $prefix =~ s/\n/ /g;
    $class->new(cities => [ split(/\.+/, $cities) ],
		date => $date,
		zone_codes => $zone_codes,
		location_description => $prefix,
		weather_report => $data);
}

sub parse_zone_data {
    my ($class, $source) = @_;

    open(IN, $source) or die;
    # $self->_parse_zone_data(join('', <IN>));
    my $zone_data = '';
    my $zone_codes;
    my $line_number = 1;
    my $result;
    while (! $result && defined(my $line = <IN>)) {
	chomp($line);
	$line =~ s/\r//g;
	if ($line =~ /^\w\wZ\d\d\d[->]/) {
	    $zone_codes = $line;
	}
	elsif ($line eq '$$') {
	    $result = $class->new_from_data($zone_codes, $zone_data, 
					    $line_number)
		if $zone_data;
	    $zone_codes = $zone_data = '';
	}
	elsif ($zone_codes) {
	    $zone_data .= "$line\n";
	}
	$line_number++;
    }
    close(IN);
    $result ||= $class->new_from_data($zone_codes, $zone_data, $line_number)
	# this is in case we see EOF before $$.  [but that may mean the file has
	# been truncated.  -- rgr, 22-Aug-04.]
	if $zone_data;
    $result;
}

sub _match_city_p {
    my ($self, $target_city) = @_;

    my $cities = $self->cities;
    return undef
	if ! $cities;
    my $match_p = 0;
    for my $city (@$cities) {
	$match_p = 1, last
	    if lc($city) eq lc($target_city);
    }
    $match_p;
}

sub print_report {
    my ($self, $query) = @_;

    my $cities = $self->cities;
    if ($query) {
	print("\n<p>\n<hr>\n",
	      "Codes:  ", CGI::escapeHTML($self->zone_codes), "<br>\n",
	      "Date:  ", CGI::escapeHTML($self->date), "<br>\n",
	      "Location:  ", CGI::escapeHTML($self->location_description),
	      "<br>\n");
	print("Cities: ", join(', ', @$cities), "<br>\n")
	    if $cities && @$cities;
	print("\n<blockquote>\n<pre>", 
	      CGI::escapeHTML($self->weather_report),
	      "</pre>\n</blockquote>\n");
    }
    else {
	print("\n\nCodes:  ", $self->zone_codes,
	      "\nDate:  ", $self->date,
	      "\nLocation:  ", $self->location_description,);
	print("\nCities: ", join(', ', @$cities))
	    if $cities && @$cities;
	print("\n\n", $self->weather_report, "\n");
    }
}

package Weather::IWIN;

use base qw(Weather::Thing);

# define instance accessors.
sub BEGIN {
  no strict 'refs';
  for my $method (qw(zones selected_zones query)) {
    my $field = '_' . $method;
    *$method = sub {
      my $self = shift;
      @_ ? ($self->{$field} = shift, $self) : $self->{$field};
    }
  }
}

sub find_matching_zone_reports {
    # note that this preserves the order found in the $self->zones list.
    my $self = shift;

    my $zones = $self->zones;
    my $result = [];
    $self->selected_zones($result);
    return $result
	unless $zones;
    for my $zone (@$zones) {
	my $match_p = 0;
	for my $target_city (@_) {
	    $match_p = 1, last
		if $zone->_match_city_p($target_city);
	}
	# found a match; make sure it's not a duplicate.  for some reason, we
	# often get duplicate reports with the identical content.
	for my $found (@$result) {
	    $match_p = 0, last
		if $zone->zone_equal_p($found);
	}
	push(@$result, $zone)
	    if $match_p;
    }
    $result;
}

sub _process_zone {
    my ($self, $zone_codes, $zone_data, $line_number) = @_;

    # warn("[_process_zone at $line_number, size ", length($zone_data), ".]\n");
    # die $zone_data;
    my $zones = $self->zones;
    $self->zones($zones = [])
	unless $zones;
    my $new_zone = Weather::Zone->new_from_data($zone_codes, $zone_data,
						$line_number);
    push(@$zones, $new_zone)
	if $new_zone;
    $new_zone;
}

sub _parse_zone_data {
    my ($self, $page) = @_;

    my ($zone_codes, $zone_data);
    $page =~ s/\r//g;
    my $line_number = 1;
    for my $line (split("\n", $page)) {
	if ($line =~ /^..Z\d\d\d[->]/) {
	    $self->_process_zone($zone_codes, $zone_data, $line_number)
		if $zone_data;
	    $zone_codes = $line;
	    $zone_data = '';
	}
	elsif ($line eq '$$') {
	    $self->_process_zone($zone_codes, $zone_data, $line_number)
		if $zone_data;
	    $zone_codes = $zone_data = '';
	}
	elsif ($zone_codes) {
	    $zone_data .= "$line\n";
	}
	$line_number++;
    }
    $self->_process_zone($zone_codes, $zone_data, $line_number)
	if $zone_data;
}

sub fetch_zone_data {
    my ($self, $source) = @_;

    if ($source =~ /^http:/i) {
	require LWP::UserAgent;
	my $ua = new LWP::UserAgent;
	$ua->agent("FetchWeather/0.1");
	my $req = new HTTP::Request(GET => $source);
	my $res = $ua->request($req);
	if ($res->is_success) {
	    $self->_parse_zone_data($res->content);
	}
	else {
	    die "Bad luck this time\n";
	}
    }
    else {
	open(IN, $source) or die;
	$self->_parse_zone_data(join('', <IN>));
	close(IN);
    }
}

1;
