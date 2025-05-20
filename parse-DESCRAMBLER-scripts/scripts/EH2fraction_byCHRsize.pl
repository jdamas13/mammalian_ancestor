#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Data::Dumper;

my $EH_in = shift; #EH in merged
#Avian:Ancestor,1,0,33478961,1299738,41462050,+1,Anapla_RHm,apl1,apl1
#Avian:Ancestor,1,33478962,40035321,43176706,51565002,-1,Anapla_RHm,apl1,apl1
#Avian:Ancestor,1,40035322,41198613,41927777,43148058,+1,Anapla_RHm,apl1,apl1

my $sizes_in = shift; #Sizes of ancestor chromosomes
#chr size

my $out = shift; #out file with fraction inverted & fraction conserved for each ancestral chromosome
#chr fracInv fracCons

my %sizes;
open(S, $sizes_in) or die "Couldn't open $sizes_in!\n";
while (<S>) {
	chomp;
	my @tmp = split(/\t/, $_);
	$sizes{$tmp[0]}=$tmp[1];
}
close S;

my %data;
my $species;
open(F, $EH_in) or die "Couldn't open $EH_in!\n";
while (<F>) {
	chomp;
	my ($id,$chr1,$start1,$end1,$start2,$end2,$or,$sp,$chr2) = split(/,/, $_);
	my $len = $end1 - $start1;
	$species = $sp;
	if (exists $data{$chr1}{$chr2}{$or}){
		$data{$chr1}{$chr2}{$or} += $len;
	}
	else{
		$data{$chr1}{$chr2}{$or} = $len;
	}
}
close F;

#print Dumper %data;

my %data2;
foreach my $ch1 (keys %data){
	foreach my $ch2 (keys %{$data{$ch1}}){
		if (exists $data{$ch1}{$ch2}{"+1"} && exists $data{$ch1}{$ch2}{"-1"}){
			if ($data{$ch1}{$ch2}{"+1"} >= $data{$ch1}{$ch2}{"-1"}){
				$data2{$ch1}{"conserved"} += $data{$ch1}{$ch2}{"+1"};
				$data2{$ch1}{"inverted"} += $data{$ch1}{$ch2}{"-1"};
			}
			else{
				$data2{$ch1}{"conserved"} += $data{$ch1}{$ch2}{"-1"};
				$data2{$ch1}{"inverted"} += $data{$ch1}{$ch2}{"+1"};
			}
		}
		elsif(exists $data{$ch1}{$ch2}{"+1"} && ! exists $data{$ch1}{$ch2}{"-1"}){
			$data2{$ch1}{"conserved"} += $data{$ch1}{$ch2}{"+1"};
			$data2{$ch1}{"inverted"} = 0;
		}
		elsif (exists $data{$ch1}{$ch2}{"-1"} && ! exists $data{$ch1}{$ch2}{"+1"}){
			$data2{$ch1}{"conserved"} += $data{$ch1}{$ch2}{"-1"};
			$data2{$ch1}{"inverted"} = 0;
		}
	}
}
print Dumper %data2;

open(O, ">$out") or die "Couldn't create $out!\n";
print O "Species\tChr\tLength\tTotalConserved\tTotalInverted\tFractionConserved\tFractionInverted\n";
foreach my $k (keys %data2){
	my $fraC = $data2{$k}{"conserved"}/$sizes{$k};
	my $fraI = $data2{$k}{"inverted"}/$sizes{$k};
	print O "$species\t$k\t$sizes{$k}\t$data2{$k}{'conserved'}\t$data2{$k}{'inverted'}\t$fraC\t$fraI\n";
}
close O;