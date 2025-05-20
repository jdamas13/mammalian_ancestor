#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
use List::MoreUtils qw(any);

# Check which species support merging of RACFs
# Joana Damas, 26 September 2019

my $input=shift; #EH file with all species
my $output = shift; #output file name

my @data_matrix;
my %noBlocks;
my $line = 0;
open (IN, $input) or die "Couldn't open $input!\n"; #pFalcon,12,0,29578250,0,29578250,+1,FPEpcfs,9,9
while(<IN>){
	chomp;
	my @tmp = split(/,/, $_);
	@{$data_matrix[$line]} = @tmp;
	$line++;
	if (exists $noBlocks{$tmp[1]}){
		my $nb = $noBlocks{$tmp[1]} + 1;
		$noBlocks{$tmp[1]} = $nb;
	} else {
		$noBlocks{$tmp[1]} = 1;
	}
}
close IN;
#print Dumper @data_matrix;

my @sortbyANC_matrix = sort { $a->[7] cmp $b->[7] || $a->[1] cmp $b->[1] || $a->[2] <=> $b->[2] } @data_matrix;
my @sortbySPS_plus = sort { $a->[7] cmp $b->[7] || $a->[8] cmp $b->[8] || $a->[4] <=> $b->[4] } @data_matrix;

## GET RACFs ENDS
my @racf_ends;
for my $i (0 .. scalar(@sortbyANC_matrix)-2){
	my @line = @{$sortbyANC_matrix[$i]};
	my @next_line = @{$sortbyANC_matrix[$i+1]};
	if ($i == 0) {
		my $str = join(",", @line);
		$str .= ",start";
		push(@racf_ends, $str);
	} elsif ($i == scalar(@sortbyANC_matrix)-1){
		my $str = join(",", @line);
		$str .= ",end";
		push(@racf_ends, $str);
	} else {
		my $racf = $line[1];
		my $next_racf = $next_line[1];
		if ($racf ne $next_racf){
			my $str1 = join(",", @line);
			$str1 .= ",end";
			push(@racf_ends, $str1);
			my $str2 = join(",", @next_line);
			$str2 .= ",start";
			push(@racf_ends, $str2);
		}
	}
}
#print Dumper @racf_ends;

## IDENTIFY SUPPORT FROM SPECIES 
my %results;
for my $i (0 .. $#sortbySPS_plus-1){
	#print "$i \n";
	my @line = @{$sortbySPS_plus[$i]};
	my @next_line = @{$sortbySPS_plus[$i+1]};
	my $racf = $line[1];
	my $next_racf = $next_line[1];
	my $chr = $line[8];
	my $next_chr = $next_line[8];
	my $species = $line[7];
	my $next_species = $next_line[7];
	if ($species eq $next_species){
		if ($racf ne $next_racf && $chr eq $next_chr){
			
			my $str1 = join(",", @line);
			my $str1s= "${str1},start";
			my $str1e= "${str1},end";
				
			my $str2 = join(",", @next_line);
			my $str2s= "${str2},start";
			my $str2e= "${str2},end";

			my $end_match1;
			my $end_match2;
			my $oriens;

			if ($line[6] eq "+1" && $next_line[6] eq "+1"){
				#print join(",",@line)."\t".join(",",@next_line)."\n";
				$oriens="++";
				for my $rend (@racf_ends){
					if ($rend eq $str1s){
						my @tmp = split(",", $rend);
						my $rcf = $tmp[1];
						if ($noBlocks{$rcf} == 1){
							$end_match1 = $rend;
						}
					}
					if ($rend eq $str1e){
						$end_match1 = $rend;
					}

					if ($rend eq $str2s){
						$end_match2 = $rend;
					}
					if ($rend eq $str2e){
						my @tmp = split(",", $rend);
						my $rcf = $tmp[1];
						if ($noBlocks{$rcf} == 1){
							$end_match2 = $rend;
						}
					}
				}
			}
			elsif ($line[6] eq "+1" && $next_line[6] eq "-1"){
				#print join(",",@line)."\t".join(",",@next_line)."\n";
				$oriens="+-";
				for my $rend (@racf_ends){
					if ($rend eq $str1s){
						my @tmp = split(",", $rend);
						my $rcf = $tmp[1];
						if ($noBlocks{$rcf} == 1){
							$end_match1 = $rend;
						}
					}
					if ($rend eq $str1e){
						$end_match1 = $rend;
					}
					if ($rend eq $str2s){
						my @tmp = split(",", $rend);
						my $rcf = $tmp[1];
						if ($noBlocks{$rcf} == 1){
							$end_match2 = $rend;
						}
					}
					if ($rend eq $str2e){
						$end_match2 = $rend;
					}
				}
			}
			elsif ($line[6] eq "-1" && $next_line[6] eq "-1"){
				#print join(",",@line)."\t".join(",",@next_line)."\n";
				$oriens="--";
				for my $rend (@racf_ends){
					if ($rend eq $str1s){
						$end_match1 = $rend;
					}
					if ($rend eq $str1s){
						my @tmp = split(",", $rend);
						my $rcf = $tmp[1];
						if ($noBlocks{$rcf} == 1){
							$end_match1 = $rend;
						}
					}
					if ($rend eq $str2s){
						my @tmp = split(",", $rend);
						my $rcf = $tmp[1];
						if ($noBlocks{$rcf} == 1){
							$end_match2 = $rend;
						}
					}
					if ($rend eq $str2e){
						$end_match2 = $rend;
					}
				}
			}
			elsif ($line[6] eq "-1" && $next_line[6] eq "+1"){
				#print join(",",@line)."\t".join(",",@next_line)."\n";
				$oriens="-+";
				for my $rend (@racf_ends){
					if ($rend eq $str1s){
						$end_match1 = $rend;
					}
					if ($rend eq $str1s){
						my @tmp = split(",", $rend);
						my $rcf = $tmp[1];
						if ($noBlocks{$rcf} == 1){
							$end_match1 = $rend;
						}
					}
					if ($rend eq $str2s){
						$end_match2 = $rend;
					}
					if ($rend eq $str2e){
						my @tmp = split(",", $rend);
						my $rcf = $tmp[1];
						if ($noBlocks{$rcf} == 1){
							$end_match2 = $rend;
						}
					}
				}
			}
			if (defined $end_match1 && defined $end_match2 ){
				#print "-+ $end_match1 $end_match2\n";
				my @tmp1 = split(",", $end_match1);
				my @tmp2 = split(",", $end_match2);
				my $key;
				if ($tmp1[1] <= $tmp2[1]){
					$key = $tmp1[1]."_".$tmp1[-1].":".$tmp2[1]."_".$tmp2[-1];
				} else {
					$key = $tmp2[1]."_".$tmp2[-1].":".$tmp1[1]."_".$tmp1[-1];
				}
				if ( ! exists($results{$key}) ){
					@{$results{$key}}=("${species}_${oriens}");
				} else {
					push (@{$results{$key}}, "${species}_${oriens}");
				} 	
			}
		}
	}
}

my %count;
foreach my $i (keys %results){
	my @tmp = split(":", $i);
	if (exists ${count{$tmp[0]}}){
		${count{$tmp[0]}}++;
	} 
	if (! exists ${count{$tmp[0]}}){
		${count{$tmp[0]}} = 1;
	}
	if (exists ${count{$tmp[1]}}) {
		${count{$tmp[1]}}++;
	}
	if (! exists ${count{$tmp[1]}}){
		${count{$tmp[1]}} = 1;
	}
}
#print Dumper %count;

open(OUT, ">$output") or die "Couldn't create $output!\n";
print OUT "Adjacency\t#species\tSpecies\tClass\n";
for my $k (keys %results){
	my @tmp = split(":", $k);
	my @un = sort(uniq(@{$results{$k}}));
	@{$results{$k}} = @un;
	my $sps = join(",", @un);
	my $num = scalar(@un);
	print OUT "$k\t$num\t$sps\t";
	if (${count{$tmp[0]}} == 1 && ${count{$tmp[1]}} == 1 ){
		print OUT "Unique\n";
	} else {
		print OUT "Inconsistent\n";
	}
}
close OUT;
#print Dumper %results;

##SUBROUTINES
sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}