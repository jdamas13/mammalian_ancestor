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
print OUT "RACF\tID1\tStart1\tEnd1\tOr1\tID2\tStart2\tEnd2\tOr2\tStatus1st\tStatus2nd\tStatusAdj\tNote\n";
#print scalar(@in1)."\n";
LINE: for my $i (0..$#in1) {
	my $firstFlag = "1stNotFound";
	my $secondFlag = "2ndNotFound";
	my $adjFlag = "notMaintained";
	my $noteFlag = "";
	my $ori;
	
	if (${$in1[$i]}[1] ne ${$in1[$i+1]}[1] && ${$in1[$i]}[1] ne ${$in1[$i-1]}[1]) { #CARs with one block only
		next LINE;	
	}
	elsif (${$in1[$i]}[1] ne ${$in1[$i+1]}[1] || $i == $#in1) {	#lastLine of CAR or lastLine of file
		next LINE;
	}
	else {	#scaf not alone in block and not last line
		my @tarray = &find_block($i);
		my $next = $i + 1;
		my @t2array = &find_block($next);
		if ($tarray[0] ne "") {
			$firstFlag = "1st".$tarray[1];
			my $match_idx = $tarray[0];
			my $match2 = $t2array[0];
			if ($match_idx == $match2){
				$firstFlag = "1stFound";
				$secondFlag = "2ndFound";
				$adjFlag = "Maintained";
				$noteFlag = "NotFragmented";
				print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t";
				print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t";
				print OUT "\t$firstFlag\t$secondFlag\t$adjFlag\t$noteFlag\n";
				next LINE;
			}

			print join("\t",@{$in1[$i]})."\t";
			print join("\t",@{$in1[$i+1]})."\t";
			print join("\t",@{$in2[$match_idx]})."\t";
			if ($match_idx == 0) { #If block in first line, only check next block
				print join("\t",@{$in2[$match_idx+1]})."\t";
				print "Going down!\t";
				my @tmp = &check_blocks_fixed_idx($i, $match_idx, "down");
				if ($tmp[0] ne ""){
					$secondFlag = "2nd".$tmp[0];
					$adjFlag = $tmp[1];
					$noteFlag = $tmp[2];
					#next LINE;
				}
			}
			elsif ($match_idx == $#in2) { #If block in the last line, only check previous block
				print join("\t",@{$in2[$match_idx+1]})."\t";
				print "Going up!\t";
				my @tmp = &check_blocks_fixed_idx($i, $match_idx, "up");
				if ($tmp[0] ne ""){
					$secondFlag = "2nd".$tmp[0];
					$adjFlag = $tmp[1];
					$noteFlag = $tmp[2];
					#next LINE;
				}
			} else {
				print join("\t",@{$in2[$match_idx+1]})."\t";
				print "Going down!\t";
				my @tmp = &check_blocks_fixed_idx($i, $match_idx, "down");
				if ($tmp[0] ne ""){
					$secondFlag = "2nd".$tmp[0];
					$adjFlag = $tmp[1];
					$noteFlag = $tmp[2];
					#next LINE;
				}
				print join("\t",@{$in2[$match_idx+1]})."\t";
				print "Going up!\t";
				my @tmp = &check_blocks_fixed_idx($i, $match_idx, "up");
				if ($tmp[0] ne ""){
					$secondFlag = "2nd".$tmp[0];
					$adjFlag = $tmp[1];
					$noteFlag = $tmp[2];
					#next LINE;
				}
			}

			# my $blockIn1Or = ${$in1[$i]}[6];
			# my $blockIn2Or = ${$in2[$match_idx]}[6];
			# print join("\t",@{$in1[$i]})."\t";
			# print join("\t",@{$in1[$i+1]})."\t";
			# print join("\t",@{$in2[$match_idx]})."\t";
			# if ($blockIn1Or eq $blockIn2Or){
			# 	print join("\t",@{$in2[$match_idx+1]})."\t";
			# 	print "Going down!\t";
			# 	my @tmp = &check_blocks_fixed_idx($i, $match_idx, "down");
			# 	if ($tmp[0] ne ""){
			# 		($secondFlag, $adjFlag, $noteFlag) = @tmp;
			# 		$secondFlag = "2nd".$secondFlag;
			# 	}
			# } else {
			# 	print join("\t",@{$in2[$match_idx-1]})."\t";
			# 	print "Going up!\t";
			# 	my @tmp = &check_blocks_fixed_idx($i, $match_idx, "up");
			# 	if ($tmp[0] ne ""){
			# 		($secondFlag, $adjFlag, $noteFlag) = @tmp;
			# 		$secondFlag = "2nd".$secondFlag;
			# 	}
			# }
		}
	}
	if ($firstFlag eq "1stNotFound" ){
		$adjFlag = "Unique";
		$noteFlag = "FirstMissing";
	}
	if ($secondFlag eq "2ndNotFound" ){
		$adjFlag = "Unique";
		$noteFlag = "SecondMissing";
	}
	if ($firstFlag eq "1stNotFound" && $secondFlag eq "2ndNotFound" ){
		$adjFlag = "Unique";
		$noteFlag = "BothMissing";
	}
	print OUT ${$in1[$i]}[1]."\t".${$in1[$i]}[8]."\t".join("\t", @{$in1[$i]}[4..6])."\t";
	print OUT ${$in1[$i+1]}[8]."\t".join("\t", @{$in1[$i+1]}[4..6])."\t";
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

sub check_blocks_fixed_idx {
	my ($ori, $ori2, $comp_idx, $block_flag, $adj_flag, $note_flag);
	my ($idx1, $idx2, $direction) = @_;

	if ($direction eq "up") { $comp_idx = $idx2 - 1; }
	if ($direction eq "down") { $comp_idx = $idx2 + 1; }

	my $scafOr1 = ${$in1[$idx1]}[6]; 	#current line
	my ($l2, $chr2, $chrStart2, $chrEnd2, $scafStart2, $scafEnd2, $scafOr2, $sps2, $scaf2, $sc2);
	if ($idx1 != $#in1) {
	 	($l2, $chr2, $chrStart2, $chrEnd2, $scafStart2, $scafEnd2, $scafOr2, $sps2, $scaf2, $sc2) = @{$in1[$idx1+1]};	#next line
	}
	if ($scafOr1 eq $scafOr2) { $ori = "same"; } #scafs have same orientation
	if ($scafOr1 ne $scafOr2) { $ori = "diff"; } #scafs have different orientation

	my $chr21 = ${$in2[$idx2]}[1];
	my $scafOr21 = ${$in2[$idx2]}[6];
	my ($l20, $chr20, $chrStart20, $chrEnd20, $scafStart20, $scafEnd20, $scafOr20, $sps20, $scaf20, $sc20) = @{$in2[$comp_idx]};
		
	if ($scafOr21 eq $scafOr20) { $ori2 = "same"; }
	if ($scafOr21 ne $scafOr20) { $ori2 = "diff"; }
		
	my $minSt2 = max($scafStart2, $scafStart20);
	my $minEn2 = min($scafEnd2, $scafEnd20);
	my $overlap_len = $minEn2 - $minSt2;
	print "$chr2 $scaf2 $scafStart2 $scafEnd2 --> $chr21 $scaf20 $scafStart20 $scafEnd20 --> $overlap_len\n"; 
	if (($overlap_len > (($scafEnd2-$scafStart2) * $perc )) || ($overlap_len > (($scafEnd20-$scafStart20) * $perc))){
	#if ( ($overlap_len > (($scafEnd2-$scafStart2) * $perc )) ){
		if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20){
			$block_flag = "Found";
			if ($ori eq $ori2){
				$adj_flag = "Maintained";
				$note_flag = "-";
				return ($block_flag, $adj_flag, $note_flag); 
				exit;
			} else {
				$adj_flag = "NotMaintained";
				$note_flag = "Inverted";
				return ($block_flag, $adj_flag, $note_flag); 
				exit;
			}
		}
	}
}