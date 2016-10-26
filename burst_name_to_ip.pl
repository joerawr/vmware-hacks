#!/bin/perl -w

# Joe Rogers and Paul Fernandez 
# 02-02-2015
# Convert a list of hostnames and IPs into XML files for running through
# VMWare vcli scripts

open LIST,"< /tmp/x1";
my @namesips = <LIST>;
close LIST;

for my $line (@namesips) {
	if ($line =~ /^([\S]+)\s+10.132.8.(\d+)/) {
		open WAPP,"< /home/jrogers/vcli/wapp8.xml";
		my @wappsnarf = <WAPP>;
		close WAPP;
		my $hostname = $1;
		my $wappip = $2;
		my $filename = "/home/jrogers/vcli/burst/$hostname.xml";
		print "$hostname $wappip\n";
		$wappsnarf[4]=~ s/XXX/$wappip/;
		#print "$wappsnarf[4]\n";
		open WAPPOUT,">$filename";
		print WAPPOUT @wappsnarf;
		close WAPPOUT;
	}
	if ($line =~ /^([\S]+)\s+10.132.4.(\d+)/) {
		open HTML,"< /home/jrogers/vcli/http4.xml";
		my @htmlsnarf = <HTML>;
		close HTML;
                my $hostname = $1;
                my $htmlip = $2; 
                my $filename = "/home/jrogers/vcli/burst/$hostname.xml";
		print "$hostname $htmlip";
                $htmlsnarf[4]=~ s/XXX/$htmlip/;
                open HTMLOUT,">$filename";
                print HTMLOUT @htmlsnarf;
                close HTMLOUT;
        }

}
