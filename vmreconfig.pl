#!/usr/local/bin/perl

# Author: Joe Rogers, Coredigital media
# version 1.0.8
# Last revision: 04-12-2016

use File::Copy;

my $baseifcfg = ("/root/vmreconfig/ifcfg-eth0.base");
my $newifcfg = ("/etc/sysconfig/network-scripts/ifcfg-eth0");
my $basenw = ("/root/vmreconfig/network.base");
my $newnw = ("/etc/sysconfig/network");

print "Please have hostname and IP ready, or quit\n";

print "Continue? (y/n):";
chomp(my $ok = <>);
my $yes = 'y';
my $no = 'n';
if ($ok eq $yes) {
   copy("/etc/hosts","/etc/hosts.bak-deploy") or die "Copy failed: $!";
   copy($newnw,"/etc/sysconfig/network.bak-deploy")  or die "Copy failed: $!";
   copy($newifcfg,"/root/vmreconfig/ifcfg-eth0.bak-deploy") or die "Copy failed: $!";

   unlink '/etc/udev/rules.d/70-persistent-net.rules';
   unlink glob "/etc/ssh/ssh_host_*";
   unlink glob "/opt/splunkforwarder/var/log/splunk/splunkd*";
   unlink glob "/opt/splunkforwarder/var/log/splunk/metrics*";
   unlink '/var/ossec/etc/client.keys';
   unlink glob "/var/log/registered*";
   unlink "/root/.bash_history";

   if (-d "/home/jboss/logs/node1")  {
	unlink glob "/home/jboss/logs/node1/*";
   }
   if (-d "/var/log/httpd/") {
	unlink glob "/var/log/httpd/*";
   }

   $hostname = &promptUser("Enter the hostname ", "eg: esv-edurel-wapp01");
   $ip_address = &promptUser("Enter the ip_address ", "eg: 10.32.24.89");

   print "$hostname, $ip_address\n";

   open HOSTSOUT,">/tmp/hosts.tmp" or die "Open failed\n";
   print HOSTSOUT "127.0.0.1 localhost.localdomain localhost\n";
   print HOSTSOUT "$ip_address $hostname $hostname.domain.com\n";
   print HOSTSOUT "10.32.8.114     puppet puppet.domain.com master\n";
   close HOSTSOUT;

   copy("/tmp/hosts.tmp","/etc/hosts") or die "Copy failed: $!";
   
   # Set IP and gateway in ifcfg-eth0
   if ($ip_address =~ /10\.32\.(\d+)\.\d+/ ) { 
	$gateway = "10.32.$1.1";
	print "Gateway = $gateway\n";
   } 
   open BIFCFG, "<$baseifcfg" or die "Can not open base ifcfg.";
   open NIFCFG, ">$newifcfg" or die "Can not open new ifcfg.";
   	while (<BIFCFG>) {
       		if (/xgatewayx/) {
       			$_ =~ s/xgatewayx/$gateway/; 
		#	print "$gateway\n";
		}
		if (xipaddressx) {
			$_ =~ s/xipaddressx/$ip_address/;
		}
		print NIFCFG "$_";
       	}
  close BIFCFG;
  close NIFCFG;

  open BNW, "<$basenw" or die "Can not open base network file.";
  open NNW, ">$newnw" or die "Can not open new network file.";
	while (<BNW>) {
		if (/xhostnamex/) {
			$_ =~ s/xhostnamex/$hostname/;
		}
       		if (/xgatewayx/) {
       			$_ =~ s/xgatewayx/$gateway/; 
		}
		print NNW "$_";
	}
	# reboot to put configs in place
	reboot ();

}
elsif ($ok eq $no) {
   print "Please re-run /root/vmreconfig.pl when ready\n";	
   print "Bye bye.\n\n";
   exit;
}
else {
   print "Why you no type y or n?";
   print "Please re-run /root/vmreconfig.pl when ready\n";
   die "you failed\n"; 
}


sub promptUser {


   local($promptString,$defaultValue) = @_;

   #-------------------------------------------------------------------#
   #  if there is a default value, use the first print statement; if   #
   #  no default is provided, print the second string.                 #
   #-------------------------------------------------------------------#

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN (presumably the keyboard)

   chomp;

   if ("$defaultValue") {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}

sub reboot {
   print "\nFiles reconfigured. Ready for reboot? (y/n):";
   chomp(my $ok = <>);
   if ($ok eq $yes) {
      system (reboot);
   }
   else {
      print "Please run reboot to enforce the configuration.\n";
   }
}
