#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Data::Dumper;

my $EH_in = shift; #EH in merged
#Avian:Ancestor,1,0,33478961,1299738,41462050,+1,Anapla_RHm,apl1,apl1
#Avian:Ancestor,1,33478962,40035321,43176706,51565002,-1,Anapla_RHm,apl1,apl1
#Avian:Ancestor,1,40035322,41198613,41927777,43148058,+1,Anapla_RHm,apl1,apl1

#my $sizes_in = shift; #Sizes of ancestor chromosomes
#chr size

my $out = shift; #out file with fraction inverted & fraction conserved for each ancestral chromosome
#chr fracInv fracCons

my %sizes;
my %data;
my $species;
open(F, $EH_in) or die "Couldn't open $EH_in!\n";
while (<F>) {
	chomp;
	#my ($id,$chr1,$start1,$end1,$start2,$end2,$or,$sp,$chr2) = split(/,/, $_);
	my @tmp = split(/,/, $_);
	my $len = $tmp[3] - $tmp[2];
	$sizes{$tmp[1]} += $len;
	$species = $tmp[7];
	push(@{$data{$tmp[1]}{$tmp[8]}}, \@tmp);
}
close F;
#print Dumper %data;

my %data2;
my %fractions;
foreach my $chr1 (keys %data){
	foreach my $chr2 (keys %{$data{$chr1}}){
		my @sorted_array = sort { $a->[2] <=> $b->[2] } @{$data{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_array; $i++){
			push(@{$sorted_array[$i]}, $i);
			push(@{$data2{$chr1}{$chr2}}, \@{$sorted_array[$i]});
		}
		#print Dumper $data2{$chr};
		my @sorted_target = sort { $a->[4] <=> $b->[4] } @{$data2{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_target; $i++){
			my $idx = $sorted_target[$i][-1];
			my $orient = $sorted_target[$i][6];
			my $len = $sorted_target[$i][3] - $sorted_target[$i][2];
			if ($i == $idx && $orient eq "+1"){
				$fractions{$chr1}{"conserved"} += $len;
			}
			else{
				$fractions{$chr1}{"inverted"} += $len;
			}	
		}	
	}
}

open(O, ">$out") or die "Couldn't create $out!\n";
print O "Species\tChr\tLength\tTotalConserved\tTotalInverted\tFractionConserved\tFractionInverted\n";
foreach my $ch (keys %fractions){
	my $fraC = my $fraI = 0;
	if (exists $fractions{$ch}{"conserved"}){
		$fraC = $fractions{$ch}{"conserved"}/$sizes{$ch};
	}
	else {
		$fractions{$ch}{"conserved"} = 0;
		$fraC = 0;
	}
	if (exists $fractions{$ch}{"inverted"}){
		$fraI = $fractions{$ch}{"inverted"}/$sizes{$ch};	
	}
	else{
		$fractions{$ch}{"inverted"} = 0;
		$fraI = 0;
	}
	print O "$species\t$ch\t$sizes{$ch}\t$fractions{$ch}{'conserved'}\t$fractions{$ch}{'inverted'}\t$fraC\t$fraI\n";
}
close O;