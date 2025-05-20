#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";

my $aname = shift;	# EUT
my $tspc = shift;	# BOR
my $res = shift;
my $f = shift;	# merged_map

my $anc_str = "$aname:APCF:$res";

open(F,"$f");

my $tspcname = $tspc;
my $astr = "";
my $tspc_str = "";
while(<F>) {
	chomp;
		
	if (length($_) == 0) {
		$astr =~ /$aname\.(\S+):(\S+)\-(\S+) (\S+)/;
		my ($achr, $astart, $aend, $adir) = ($1, $2, $3, $4);
		$tspc_str =~ /$tspc\.(\S+):(\S+)\-(\S+) (\S+)/;
		my ($tchr, $tstart, $tend, $tdir) = ($1, $2, $3, $4);
		my $tdirnum = 1;
		if ($tdir eq "-") { $tdirnum = -1; }
			
		#####
		my $new_tchr = $tchr;
		$new_tchr =~ s/chr//g;
		#####			

		print "insert into CONSENSUS values('$anc_str','$achr',$astart,$aend,$tstart,$tend,$tdirnum,'$tspcname','$new_tchr',null,'$new_tchr','$new_tchr');\n";
	} elsif ($_ =~ /^>/) {
		next;
	} else {
		if ($_ =~ /^$aname/) {
			$astr = $_;
		} elsif ($_ =~ /^$tspc/) {
			$tspc_str = $_;
		} else {
			print STDERR "Parsing error!!\n";
			die;
		}
	}
}
close(F);
	
print "\n";	
print "INSERT INTO CHROMOSOME_SIZE SELECT COMP_GEN as GEN, COMP_CHR as CHR, max(MODIFIED_ORDER_END) as SIZE from CONSENSUS where COMP_GEN = '$tspcname' group by COMP_GEN, COMP_CHR;\n";
	

