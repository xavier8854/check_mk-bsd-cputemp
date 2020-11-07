#!/usr/bin/perl -w

#######################################################################
# $Id: cputemp.pl, v1.0 r1 07.11.2020 17:15:24 CET XH Exp $
#
# Copyright 2020 Xavier Humbert <xavier@xavierhumbert.net>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.
#
#######################################################################
# TODO
#######################################################################

use strict;

#####
## PROTOS
#####

#####
## CONSTANTS
#####
use constant OK => 0;
use constant WARN => 1;
use constant CRIT => 2;

our $warning = 55;
our $critical = 75;

#####
## VARIABLES
#####
my $rc=0;
my $tempstring;
my @temptable;
my $result = OK;

#####
## MAIN
#####

# Here, I could use BSD::Sysctl, but shell is easyer to grep and sort
$tempstring  = qx(sysctl 	dev.cpu | grep temperature | sort -r);
@temptable = split /\n/, $tempstring;

foreach my $templine (@temptable) {
	$templine =~ m/dev.cpu.([0-9]).temperature: ([0-9]+).*/;
	my $cpuid = $1;
	my $cputemp = $2;
	if ($cputemp ge $warning) {
		$rc = WARN;
	} elsif ($cputemp ge $critical) {
		$rc = CRIT;
	}

	$result = sprintf ("%s|CPU%d_temp=%d;%d;%d", $result, $cpuid, $cputemp, $warning, $critical);
}

$result = substr ($result, 2);
my $status = "OK";
if ( $rc == WARN) {
	$status = "WARN"
} elsif ($rc == CRIT) {
	$status = "CRIT";
}
printf ("%d CPUTemperature %s %s CPU Temperature\n", $rc, $result, $status);

exit ($rc);


=pod

=head1 check_mk-bsd-cputemp

The purpose of this script is to provide CPU temperature metrics to check_ml for motherboards who lack IPMI

Simply put it (make executable first) in the directory B</usr/local/lib/check_mk_agent/local/> on the host you're monitoring, then run an inventory on your check_mk host

See L<URL:https://checkmk.com/cms_localchecks.html>

© Xavier Humbert L<mailto:xavier@xavierhumbert.net> - 2020

=cut
