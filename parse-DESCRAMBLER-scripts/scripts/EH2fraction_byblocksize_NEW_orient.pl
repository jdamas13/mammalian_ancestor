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
	$sizes{$tmp[1]} += $len;
	$species = $tmp[7];
	push(@{$data{$tmp[1]}{$tmp[8]}}, \@tmp);
}
close F;
print Dumper %data;

open(F, $sizes_in) or die "Couldn't open $sizes_in!\n";
while (<F>) {
	chomp;
	my ($chr,$len) = split(/\t/, $_);
	$total_sizes{$chr} = $len;
}
close F;
#print Dumper %total_sizes;

my %data_plus;
my %data_minus;
my %fractions;
foreach my $chr1 (keys %data){
	$fractions{$chr1}{"conserved"} = 0;
	$fractions{$chr1}{"inverted"} = 0;
	foreach my $chr2 (keys %{$data{$chr1}}){
		my $plus_val = my $minus_val = my $total = 0;
		#Testing plus orientation
		my @sorted_plus_array = sort { $a->[2] <=> $b->[2] } @{$data{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_plus_array; $i++){
			$total++;
			push(@{$sorted_plus_array[$i]}, $i);
			push(@{$data_plus{$chr1}{$chr2}}, \@{$sorted_plus_array[$i]});
		}
		my %plus;
		$plus{$chr1}{"conserved"} = 0;
		$plus{$chr1}{"inverted"} = 0;
		my @sorted_plus = sort { $a->[4] <=> $b->[4] } @{$data_plus{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_plus; $i++){
			my $idx = $sorted_plus[$i][-1];
			my $orient = $sorted_plus[$i][6];
			my $len = $sorted_plus[$i][3] - $sorted_plus[$i][2];
			if ($i == $idx && $orient !~ /-/){
				$plus_val++;
				$plus{$chr1}{"conserved"} += $len;
			}
			else{
				$plus{$chr1}{"inverted"} += $len;
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
		$minus{$chr1}{"conserved"} = 0;
		$minus{$chr1}{"inverted"} = 0;
		my @sorted_minus = sort { $a->[4] <=> $b->[4] } @{$data_minus{$chr1}{$chr2}};
		for (my $i = 0; $i <= $#sorted_minus; $i++){
			my $idx = $sorted_minus[$i][-1];
			my $orient = $sorted_minus[$i][6];
			my $len = $sorted_minus[$i][3] - $sorted_minus[$i][2];
			if ($i == $idx && $orient =~ /-/){
				$minus_val++;
				$minus{$chr1}{"conserved"} += $len;
			}
			else{
				$minus{$chr1}{"inverted"} += $len;
			}
		}
		print "$chr1\t$chr2\t$plus_val\t$minus_val\n";
		if ($plus_val == $minus_val){
			if($plus_val == 0){ 
				#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tNone\n";
				$fractions{$chr1}{"inverted"} += $plus{$chr1}{"inverted"};
			}
			else{
				if ( $plus{$chr1}{"conserved"} >= $minus{$chr1}{"conserved"} ){
					#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tPlus\n";	
					$fractions{$chr1}{"conserved"} += $plus{$chr1}{"conserved"};
					$fractions{$chr1}{"inverted"} += $plus{$chr1}{"inverted"};
				}
				else{
					#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tMinus\n";	
					$fractions{$chr1}{"conserved"} += $minus{$chr1}{"conserved"};
					$fractions{$chr1}{"inverted"} += $minus{$chr1}{"inverted"};
				}
			}
		}
		elsif ($plus_val > $minus_val){
			#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tPlus\n";
			$fractions{$chr1}{"conserved"} += $plus{$chr1}{"conserved"};
			$fractions{$chr1}{"inverted"} += $plus{$chr1}{"inverted"};
		}
		elsif ($plus_val < $minus_val){
			#print "$species\t$chr1\t$chr2\t$total\t$plus\t$minus\tMinus\n";
			$fractions{$chr1}{"conserved"} += $minus{$chr1}{"conserved"};
			$fractions{$chr1}{"inverted"} += $minus{$chr1}{"inverted"};
		}
		$plus_val = $minus_val = 0;
		undef %plus;
		undef %minus;
	}
}

open(O, ">$out") or die "Couldn't create $out!\n";
print O "Species\tChr\tTotal_len\tMapped_len\tlenNonRearranged\tlenRearranged\tmappedFracNonRearranged\tmappedFracRearranged\ttotalFracNonRearranged\ttotalFracRearranged\n";
my $allCons = my $allInv = my $allLen = my $tot_allLen = 0;
foreach my $ch (keys %fractions){
	my $fraC = my $fraI = my $tot_fraC = my $tot_fraI = 0;
	if (defined $fractions{$ch}{"conserved"}){
		$fraC = $fractions{$ch}{"conserved"}/$sizes{$ch};
		$tot_fraC = $fractions{$ch}{"conserved"}/$total_sizes{$ch};
	}
	else {
		$fractions{$ch}{"conserved"} = 0;
		$fraC = 0;
		$tot_fraC = 0;
	}
	if (defined $fractions{$ch}{"inverted"}){
		$fraI = $fractions{$ch}{"inverted"}/$sizes{$ch};
		$tot_fraI = $fractions{$ch}{"inverted"}/$total_sizes{$ch};	
	}
	else{
		$fractions{$ch}{"inverted"} = 0;
		$fraI = 0;
		$tot_fraI = 0;
	}
	$allCons += $fractions{$ch}{'conserved'};
	$allInv += $fractions{$ch}{'inverted'};
	$allLen += $sizes{$ch};
	$tot_allLen += $total_sizes{$ch};
	print O "$species\t$ch\t$total_sizes{$ch}\t$sizes{$ch}\t$fractions{$ch}{'conserved'}\t$fractions{$ch}{'inverted'}\t$fraC\t$fraI\t$tot_fraC\t$tot_fraI\n";
}

my $fr_CONS = $allCons/$allLen;
my $fr_INV = $allInv/$allLen;
my $fr_t_CONS = $allCons/$tot_allLen;
my $fr_t_INV = $allInv/$tot_allLen;

print O "$species\tOverall\t$tot_allLen\t$allLen\t$allCons\t$allInv\t$fr_CONS\t$fr_INV\t$fr_t_CONS\t$fr_t_INV\n";

close O;