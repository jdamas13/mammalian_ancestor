#!/usr/bin/perl
use strict;
#use warnings;
use Data::Dumper;
use List::Util qw(min max);

my $in1 = $ARGV[0];  #refRef  cattleCattle
my $in2 = $ARGV[1];  #otherRef sheepCattle
my $out = $ARGV[2];
my $perc = $ARGV[3]; #fraction of  overlap between blocks in 2 references

## READ DATA ##
my (@mat1, @mat2);
open IN1, $in1 or die "Can't open infile 1\n";
my $x = 0;
while (<IN1>) {
	chomp;
	my $lc = lc($_);
	@{$mat1[$x]} = split(/,/, $lc);
	$x++;
}
close IN1;
my @in1 = sort { $a->[1] cmp $b->[1] || $a->[2] <=> $b->[2] } @mat1; #sort by compGen, refScaf, refScafStart

open IN2, $in2 or die "Cant' open infile 2\n";
my $y = 0;
while (<IN2>) {
	chomp;
	my $lc2 = lc($_);
	@{$mat2[$y]} = split(/,/, $lc2);
	$y++;	
}
close IN2;
my @in2 = sort { $a->[1] cmp $b->[1] || $a->[2] <=> $b->[2] } @mat2; #sort by compGen, refScaf, refScafStart
## END OF READ DATA ##

## ANALYSIS ## 
open OUT, ">$out" or die "Can't create $out file\n";
print OUT "RACF\tID1\tStart1\tEnd1\tOr1\tMatchIDX\tID2\tStart2\tEnd2\tOr2\tMatchIDX\tStatus1st\tStatus2nd\tStatusAdj\tNote\n";
#print scalar(@in1)."\n";
LINE: for my $i (0..$#in1) {
	my $firstFlag = "1stNotFound";
	my $secondFlag = "2ndNotFound";
	my $adjFlag = "notMaintained";
	my $noteFlag = "-";
	my $ori;
	
	if (${$in1[$i]}[1] ne ${$in1[$i+1]}[1] && ${$in1[$i]}[1] ne ${$in1[$i-1]}[1]) { #CARs with one block only
		next LINE;	
	}
	elsif (${$in1[$i]}[1] ne ${$in1[$i+1]}[1] || $i == $#in1) {	#lastLine of CAR or lastLine of file
		next LINE;
	}
	else {	#scaf not alone in block and not last line
		#my @block1 = &find_block($i);
		my @block1 = &find_block_BYend($i, "first");
		my $match_idx = $block1[0];
		my $next = $i + 1;
		#my @block2 = &find_block($next);
		my @block2 = &find_block_BYend($next, "second");
		my $match_idx2 = $block2[0];
		if ($match_idx ne "") {
			$firstFlag = "1st".$block1[1];
			if ($match_idx2 ne ""){
				$secondFlag = "2ndFound";
				my $ori_1st = ${$in1[$i]}[6]; $ori_1st =~ s/1//;
				my $ori_2nd = ${$in1[$next]}[6]; $ori_2nd =~ s/1//;
				my $ori2_1st = ${$in2[$match_idx]}[6]; $ori2_1st =~ s/1//;
				my $ori2_2nd = ${$in2[$match_idx2]}[6]; $ori2_2nd =~ s/1//;
				if ($match_idx == $match_idx2){ #no fragmentation in other set
					$adjFlag = "Maintained";
					$noteFlag = "Not fragmented";
					#print OUT "NoFrag\t";
					print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t$match_idx\t";
					print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t$match_idx2\t";
					print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
					next LINE;
				}
				elsif ($match_idx2 == ($match_idx + 1) || $match_idx2 == ($match_idx - 1) ){ #blocks are consecutive
					if ($ori_1st eq $ori_2nd){
						if ( $match_idx2 == ($match_idx + 1) ) {
							#print OUT "Case1 $ori_1st $ori_2nd $ori2_1st $ori2_2nd\t";
							if ($ori_1st eq $ori2_1st && $ori2_1st eq $ori2_2nd) {
								$adjFlag = "Maintained";
								print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t$match_idx\t";
								print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t$match_idx2\t";
								print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
								next LINE;
							} else {
								$adjFlag = "NotMaintained";
								$noteFlag = "Inverted";
								print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t$match_idx\t";
								print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t$match_idx2\t";
								print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
								next LINE;
							}
						} else { #block is up
							#print OUT "Case2 $ori_1st $ori_2nd $ori2_1st $ori2_2nd\t";
							if ($ori_1st ne $ori2_1st && $ori2_1st eq $ori2_2nd) {
								$adjFlag = "Maintained";
								print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t$match_idx\t";
								print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t$match_idx2\t";
								print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
								next LINE;
							} else {
								$adjFlag = "NotMaintained";
								$noteFlag = "Inverted";
								print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t$match_idx\t";
								print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t$match_idx2\t";
								print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
								next LINE;
							}
						}
					} else {
						#print OUT "Case3 $ori_1st $ori_2nd $ori2_1st $ori2_2nd\t";
						if ($ori_1st eq $ori2_1st && $ori_2nd eq $ori2_2nd){
							$adjFlag = "Maintained";
							print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t$match_idx\t";
							print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t$match_idx2\t";
							print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
							next LINE;
						} else {
							$adjFlag = "NotMaintained";
							$noteFlag = "Inverted";
							print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t$match_idx\t";
							print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t$match_idx2\t";
							print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
							next LINE;
						}
					}
				}
				elsif ( ($match_idx2 != ($match_idx + 1)) && ($match_idx2 != ($match_idx - 1)) ){ #blocks ARE NOT consecutive
					$adjFlag = "NotMaintained";
					$noteFlag = "Inconsistent";
					## Check if it is due to gap ## 
					my @range_idx;
					@range_idx = ($match_idx+1..$match_idx2-1);
					if ($match_idx2 < $match_idx) { @range_idx = ($match_idx2+1..$match_idx-1); }
					my $gap_status;
					for my $val (@range_idx) {
						#print "HERE $match_idx $match_idx2\t".join(',', @range_idx)."\n";
						my @tmp = &find_block_BYend_reverse($val, "first");
						if ($tmp[0] ne "") { $gap_status = "NotGap"; last; }
					}
					# Check if fragmentation
					if (${$in2[$match_idx]}[1] ne ${$in2[$match_idx2]}[1]) { # if it's different RACFs, it's fragmentation if free end
						print "Different RACFs\n";
						# they need to be free ends otherwise is inconsistent
						if ($ori2_2nd eq "+" && ${$in2[$match_idx2]}[1] ne ${$in2[$match_idx2-1]}[1]){
							$adjFlag = "Unique";
							$noteFlag = "Fragmentation";
						} 
						elsif ($ori2_2nd eq "-" && ${$in2[$match_idx2]}[1] ne ${$in2[$match_idx2+1]}[1]){
							$adjFlag = "Unique";
							$noteFlag = "Fragmentation";
						}		
					}
					if ($gap_status eq ""){ $noteFlag = "Gap"; }
					print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t$match_idx\t";
					print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t$match_idx2\t";
					print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
					next LINE;
				}
			}
		} else {
			if ($match_idx2 ne ""){ $secondFlag = "2ndFound"; }
		}
	}
	if ($firstFlag eq "1stNotFound" || $secondFlag eq "2ndNotFound" ){
		$adjFlag = "Unique";
	}
	print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t-\t";
	print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t-\t";
	print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
}
close OUT;

### ---- START OF SUBROUTINES ---- ###
sub find_block {
	my $flag;
	my $block_idx = $_[0];
	my ($l1, $chr1, $chrStart1, $chrEnd1, $scafStart1, $scafEnd1, $scafOr1, $sps1, $scaf1, $sc1) = @{$in1[$block_idx]};
	for my $j (0..$#in2) {
		my ($l21, $chr21, $chrStart21, $chrEnd21, $scafStart21, $scafEnd21, $scafOr21, $sps21, $scaf21, $sc21) = @{$in2[$j]};
		my $minSt = max($scafStart1, $scafStart21);      
		my $minEnd = min($scafEnd1, $scafEnd21);
		my $overlap_len = $minEnd - $minSt;
		if ( ($overlap_len > (($scafEnd1-$scafStart1) * $perc)) || ($overlap_len > (($scafEnd21-$scafStart21) * $perc))){ 		
		#if ( ($overlap_len > (($scafEnd1-$scafStart1) * $perc)) ){ 		
			if ($scaf1 eq $scaf21 && $scafStart1 <= $scafEnd21 && $scafEnd1 >= $scafStart21) { # blocks overlap
				$flag = "Found";
				return ($j, $flag); 
				exit;
			}
		}
	}
}

sub find_block_BYend {
	my $distance = -1;
	my ($flag, $index, $overlap);
	my ($block_idx, $label) = @_;
	my ($l1, $chr1, $chrStart1, $chrEnd1, $scafStart1, $scafEnd1, $scafOr1, $sps1, $scaf1, $sc1) = @{$in1[$block_idx]};
	$scafOr1 =~ s/1//;
	for my $j (0..$#in2) {
		my ($l21, $chr21, $chrStart21, $chrEnd21, $scafStart21, $scafEnd21, $scafOr21, $sps21, $scaf21, $sc21) = @{$in2[$j]};
		$scafOr21 =~ s/1//;
		my $minSt = max($scafStart1, $scafStart21);      
		my $minEnd = min($scafEnd1, $scafEnd21);
		my $overlap_len = $minEnd - $minSt;
		if ($scaf1 eq $scaf21 && $scafStart1 <= $scafEnd21 && $scafEnd1 >= $scafStart21 && ($overlap_len > (($scafEnd1-$scafStart1) * 0.1)) ) { # blocks overlap
			print "Overlap found $scaf1 $scafStart1 $scafEnd1 -- $scaf21 $scafStart21 $scafEnd21 $label $scafOr1 $j $overlap_len\t";
			if ( ($label eq "first" && $scafOr1 eq "+") || ($label eq "second" && $scafOr1 eq "-")){ #look at END
				my $dis2end = abs($scafEnd1-$scafEnd21);
				print "$dis2end\n";
				#if ($distance == -1 || $distance > $dis2end || $overlap_len > $overlap){ 
				#if ($distance == -1 || $overlap_len > $overlap || ($overlap_len == $overlap && $distance > $dis2end) ){ 
				#if ($distance == -1 || $distance > $dis2end){
				if ($distance == -1 || ($distance > $dis2end && $overlap < $overlap_len) ){
					$distance = $dis2end;
					$index = $j;
					$overlap = $overlap_len;
				}
				elsif ($distance < $dis2end && $overlap < $overlap_len){
					if ( $scafEnd21 > $scafStart1 && $scafEnd21 < $scafEnd1){
						$distance = $dis2end;
						$index = $j;
						$overlap = $overlap_len;		
					}
				}
				elsif ($distance < $dis2end && $overlap > $overlap_len){
					if ( $scafEnd21 > $scafStart1 && $scafEnd21 < $scafEnd1 ){
						$distance = $dis2end;
						$index = $j;
						$overlap = $overlap_len;		
					}
				}
			}	
			elsif ( ($label eq "first" && $scafOr1 eq "-") || ($label eq "second" && $scafOr1 eq "+")){ #look at START
				my $dis2start = abs($scafStart1-$scafStart21);
				print "$dis2start\n";
				#if ($distance == -1 || $distance > $dis2start || $overlap_len > $overlap){
				#if ($distance == -1 || $overlap_len > $overlap || ($overlap_len == $overlap && $distance > $dis2start) ){
				#if ($distance == -1 || $distance > $dis2start){
				if ($distance == -1 || ($distance > $dis2start && $overlap < $overlap_len) ){
					$distance = $dis2start;
					$index = $j;
					$overlap = $overlap_len;
				}
				elsif ($distance < $dis2start && $overlap < $overlap_len){
					if ( $scafStart21 > $scafStart1 && $scafStart21 < $scafEnd1){
						$distance = $dis2start;
						$index = $j;
						$overlap = $overlap_len;		
					}
				}
				elsif ($distance < $dis2start && $overlap > $overlap_len){
					if ( $scafStart21 > $scafStart1 && $scafStart21 < $scafEnd1 ){
						$distance = $dis2start;
						$index = $j;
						$overlap = $overlap_len;		
					}
				}
			}
		}
	}
	#print "$index $distance\n";
	if ($distance != -1){
		$flag = "Found";
		return ($index, $flag); 
		exit;
	}
}

sub find_block_BYend_reverse {
	my $distance = -1;
	my ($flag, $index);
	my ($block_idx, $label) = @_;
	my ($l1, $chr1, $chrStart1, $chrEnd1, $scafStart1, $scafEnd1, $scafOr1, $sps1, $scaf1, $sc1) = @{$in2[$block_idx]};
	$scafOr1 =~ s/1//;

	for my $j (0..$#in1) {
		my ($l21, $chr21, $chrStart21, $chrEnd21, $scafStart21, $scafEnd21, $scafOr21, $sps21, $scaf21, $sc21) = @{$in1[$j]};
		$scafOr21 =~ s/1//;	
		if ($scaf1 eq $scaf21 && $scafStart1 <= $scafEnd21 && $scafEnd1 >= $scafStart21) { # blocks overlap
			#print "Overlap found $label $scafOr1 $j\t";
			if ( ($label eq "first" && $scafOr1 eq "+") || ($label eq "second" && $scafOr1 eq "-")){ #look at END
				my $dis2end = abs($scafEnd1-$scafEnd21);
				if ($distance == -1 || $distance > $dis2end){ 
					$distance = $dis2end;
					$index = $j;
				}
			}	
			elsif ( ($label eq "first" && $scafOr1 eq "-") || ($label eq "second" && $scafOr1 eq "+")){ #look at START
				my $dis2start = abs($scafStart1-$scafStart21);
				if ($distance == -1 || $distance > $dis2start){
					$distance = $dis2start;
					$index = $j;
				}
			}
		}
	}
	#print "$index $distance\n";
	if ($distance != -1){
		$flag = "Found";
		return ($index, $flag); 
		exit;
	}
}