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

my $res = shift;

my %total_sizes;
my %sizes;
my %data;
my $species;

open(F, $EH_in) or die "Couldn't open $EH_in!\n";
while (<F>) {
	chomp;
	#my ($id,$chr1,$start1,$end1,$start2,$end2,$or,$sp,$chr2) = split(/,/, $_);
	my @tmp = split(/,/, $_);
	my $len = $tmp[3] - $tmp[2];
	if($tmp[1] =~ /[Uu]n/ or $tmp[1] =~ /[Uu]n/ or $len < $res) { next; }
	$sizes{$tmp[1]}{$tmp[8]} += $len;
	$sizes{$tmp[1]}{"Total"} += $len;
	$species = $tmp[7];
	push(@{$data{$tmp[1]}{$tmp[8]}}, \@tmp);
}
close F;
#print Dumper %data;

open(F, $sizes_in) or die "Couldn't open $sizes_in!\n";
while (<F>) {
	chomp;
	my ($chr,$len) = split(/\t/, $_);
	$total_sizes{$chr} = $len;
}
close F;

#print Dumper %data;

my %data_plus;
my %data_minus;
my %fractions;
foreach my $chr1 (keys %data){
	foreach my $chr2 (keys %{$data{$chr1}}){
		$fractions{$chr1}{$chr2}{"conserved"} = 0;
		$fractions{$chr1}{$chr2}{"inverted"} = 0;
		my $plus = my $minus = my $total = 0;
		#Testing plus orientation
		my @sorted_plus_array = sort { $a->[2] <=> $b->[2] } @{$data{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_plus_array; $i++){
			$total++;
			push(@{$sorted_plus_array[$i]}, $i);
			push(@{$data_plus{$chr1}{$chr2}}, \@{$sorted_plus_array[$i]});
		}
		my %plus;
		$plus{$chr1}{$chr2}{"conserved"} = 0;
		$plus{$chr1}{$chr2}{"inverted"} = 0;
		my @sorted_plus = sort { $a->[4] <=> $b->[4] } @{$data_plus{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_plus; $i++){
			my $idx = $sorted_plus[$i][-1];
			my $orient = $sorted_plus[$i][6];
			my $len = $sorted_plus[$i][3] - $sorted_plus[$i][2];
			if ($i == $idx && $orient !~ /-/){
				$plus++;
				$plus{$chr1}{$chr2}{"conserved"} += $len;
			}
			else{
				$plus{$chr1}{$chr2}{"inverted"} += $len;
			}
		}
		
		#Testing minus orientation
		my @sorted_minus_array = sort { $b->[2] <=> $a->[2] } @{$data{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_minus_array; $i++){
			push(@{$sorted_minus_array[$i]}, $i);
			push(@{$data_minus{$chr1}{$chr2}}, \@{$sorted_minus_array[$i]});
		}
		#print Dumper %data_minus;
		my %minus;
		$minus{$chr1}{$chr2}{"conserved"} = 0;
		$minus{$chr1}{$chr2}{"inverted"} = 0;
		my @sorted_minus = sort { $a->[4] <=> $b->[4] } @{$data_minus{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_minus; $i++){
			my $idx = $sorted_minus[$i][-1];
			my $orient = $sorted_minus[$i][6];
			my $len = $sorted_minus[$i][3] - $sorted_minus[$i][2];
			if ($i == $idx && $orient =~ /-/){
				$minus++;
				$minus{$chr1}{$chr2}{"conserved"} += $len;
			}
			else{
				$minus{$chr1}{$chr2}{"inverted"} += $len;
			}
		}
		if ($plus == $minus){
			if($plus == 0){ 
				#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tNone\n";
				$fractions{$chr1}{$chr2}{"inverted"} += $plus{$chr1}{$chr2}{"inverted"};
			}
			else{
				if ( $plus{$chr1}{$chr2}{"conserved"} >= $minus{$chr1}{$chr2}{"conserved"} ){
					#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tPlus\n";	
					$fractions{$chr1}{$chr2}{"conserved"} += $plus{$chr1}{$chr2}{"conserved"};
					$fractions{$chr1}{$chr2}{"inverted"} += $plus{$chr1}{$chr2}{"inverted"};
				}
				else{
					#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tMinus\n";	
					$fractions{$chr1}{$chr2}{"conserved"} += $minus{$chr1}{$chr2}{"conserved"};
					$fractions{$chr1}{$chr2}{"inverted"} += $minus{$chr1}{$chr2}{"inverted"};
				}
			}
		}
		elsif ($plus > $minus){
			#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tPlus\n";
			$fractions{$chr1}{$chr2}{"conserved"} += $plus{$chr1}{$chr2}{"conserved"};
			$fractions{$chr1}{$chr2}{"inverted"} += $plus{$chr1}{$chr2}{"inverted"};
		}
		elsif ($plus < $minus){
			#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tMinus\n";
			$fractions{$chr1}{$chr2}{"conserved"} += $minus{$chr1}{$chr2}{"conserved"};
			$fractions{$chr1}{$chr2}{"inverted"} += $minus{$chr1}{$chr2}{"inverted"};
		}
		$plus = $minus = 0;
		undef %plus;
		undef %minus;
	}
}

#print Dumper %fractions;

open(O, ">$out") or die "Couldn't create $out!\n";
print O "Species\tCHR\tCHR2\tTotal_mapped\tMapped_len\tFractionMapped\tCount\n";
my $fr_INTER = my $gen_size = my $mapped_size = 0;
foreach my $ch (keys %sizes){
	my @sizes;
	my $count = scalar(keys %{$sizes{$ch}}) - 1;
	foreach my $ch2 (keys %{$sizes{$ch}}){
		if($ch2 ne "Total"){
			my $mapped_frac = $sizes{$ch}{$ch2}/$sizes{$ch}{"Total"};
			print O "$species\t$ch\t$ch2\t$sizes{$ch}{'Total'}\t$sizes{$ch}{$ch2}\t$mapped_frac\t$count\n";
			push(@sizes, $sizes{$ch}{$ch2});
		} else {
			$gen_size += $sizes{$ch}{"Total"};
		}
	}
	my @sorted_sizes = sort(@sizes);
	my $best = shift(@sorted_sizes);
	$mapped_size += $best;
}
$fr_INTER = $mapped_size/$gen_size;

print O "$species\tOverall\tOverall\t$gen_size\t$mapped_size\t$fr_INTER\t100\n";

close O;