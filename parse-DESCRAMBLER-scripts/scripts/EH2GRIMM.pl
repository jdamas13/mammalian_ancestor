#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Data::Dumper;

my $EH_in = shift; #EH in merged
#Avian:Ancestor,1,0,33478961,1299738,41462050,+1,Anapla_RHm,apl1,apl1
#Avian:Ancestor,1,33478962,40035321,43176706,51565002,-1,Anapla_RHm,apl1,apl1
#Avian:Ancestor,1,40035322,41198613,41927777,43148058,+1,Anapla_RHm,apl1,apl1

my $out = shift; #out file for GRIMM
#ANCESTOR
#342 396 397 -300 -299 -298 -297 -296$
#...
#SPECIES
#342 396 397 -300 -299 -298 -297 -296$
#...

my %data_anc;
my %data_sps;
open(F, $EH_in) or die "Couldn't open $EH_in!\n";
my $cnt=1;
while (<F>) {
	chomp;
	my @tmp = split(/,/, $_);
	push(@tmp, $cnt);
	push(@{$data_anc{$tmp[1]}}, \@tmp);
	push(@{$data_sps{$tmp[8]}}, \@tmp);
	$cnt++;
}
close F;
#print Dumper %data_anc;

open (O, ">$out") or die "Couldn't open $out!\n";
open (O2, ">${out}.withCHR") or die "Couldn't open ${out}.withCHR!\n";
print O "ANCESTOR\n";
print O2 "ANCESTOR\n";
foreach my $chr (keys %data_anc){
	#print O2 "#chr$chr\n";
	my @anc_sorted = sort { $a->[2] <=> $b->[2] } @{$data_anc{$chr}};
	for (my $i = 0; $i <= $#anc_sorted; $i++){
		if ($i == 0 && $i != $#anc_sorted){
			print O $anc_sorted[$i][-1]." ";
			print O2 "#chr$chr\t$anc_sorted[$i][-1]"." ";
		}
		elsif ($i == 0 && $i == $#anc_sorted){
			print O $anc_sorted[$i][-1]."\$\n";
			print O2 "#chr$chr\t$anc_sorted[$i][-1]"."\$\n";
		}
		elsif ($i == $#anc_sorted && $i != 0){
		 	print O $anc_sorted[$i][-1]."\$\n";
		 	print O2 $anc_sorted[$i][-1]."\$\n";
		}
		else{
		 	print O $anc_sorted[$i][-1]." ";
		 	print O2 $anc_sorted[$i][-1]." ";
		} 
	}
}
print O "\nSPECIES\n";
print O2 "\nSPECIES\n";
foreach my $chr (keys %data_sps){
	#print O2 "#chr$chr\n";
	my @sps_sorted = sort { $a->[4] <=> $b->[4] } @{$data_sps{$chr}};
	for (my $i = 0; $i <= $#sps_sorted; $i++){
		if ($sps_sorted[$i][6] eq "-" || $sps_sorted[$i][6] eq "-1" ){ my $newBlock = "-".$sps_sorted[$i][-1]; $sps_sorted[$i][-1]=$newBlock; }
		if ($i == 0 && $i != $#sps_sorted){
			print O $sps_sorted[$i][-1]." ";
			print O2 "#chr$chr\t$sps_sorted[$i][-1]"." ";
		}
		elsif ($i == 0 && $i == $#sps_sorted){
			print O $sps_sorted[$i][-1]."\$\n";
			print O2 "#chr$chr\t$sps_sorted[$i][-1]"."\$\n";
		}
		elsif ($i == $#sps_sorted && $i != 0){
			print O $sps_sorted[$i][-1]."\$\n";
			print O2 $sps_sorted[$i][-1]."\$\n";
		}
		else{
		 	print O $sps_sorted[$i][-1]." ";
		 	print O2 $sps_sorted[$i][-1]." ";
		} 
	}
}
close O;
close O2;
