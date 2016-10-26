#!/bin/perl

# Author: Joe Rogers, Coredigital media
# version 1.0.1
# Last revision: 04-12-2016

system("/usr/sbin/ntpdate -u dns04");

my $debug = 1;
# get the hostname from the systemid file, and match it.
# extra code is to ensure exact and not partial matches
chomp(my $hostname = `hostname`);
chomp(my $systemidl = `grep "${hostname}" /etc/sysconfig/rhn/systemid`);
(my $systemid) = $systemidl =~ /string>($hostname)</;

if ($systemid eq $hostname) {
	print "systemid ($systemid) matched hostname ($hostname), this system is already registered, exiting.\n";
}
else {
	if ($debug) {print "systemid ($systemid) doesn't match hostname ($hostname), registering with Satellite.\n";}
	if ($hostname =~ /poc/) {
		$groupid = "-POC"; 
	}
	elsif ($hostname =~ /prod/) {
                $groupid = "-PROD";
	}
	else {
		$groupid = ""; 
	}

	system ("wget --no-check-certificate -qO - https://ipatch.domain.com/pub/bootstrap/bootstrap${groupid}.sh | /bin/bash"); 
#	print "wget --no-check-certificate -qO - https://ipatch.domain.com/pub/bootstrap/bootstrap${groupid}.sh | /bin/bash\n";

	system ("spacewalk-channel --add -c rhn-tools-rhel-x86_64-server-6 -c vmware-tools-rhel6-x86_64 -c rhel-x86_64-server-optional-6 -c epel-6-x86_64 --user patchadmin --password passw0rd");

	system ("rpm --import \"http://ipatch.domain.com/pub/PATCH-RPM-GPG-KEY\"");
	
	print "Running Puppet agent apply\n";
	system ("/usr/bin/puppet agent apply -t");
#	print "\n\nReconfiguration complete.  Please reboot.\n";
	print "Restarting Splunk\n";
	system ("service splunkforwarder restart");
	
}
