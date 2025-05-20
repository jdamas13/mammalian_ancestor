#!/usr/bin/perl
use strict;
#use warnings;
use Data::Dumper;
use List::Util qw(min max);

######INPUT FILES NEED TO BE SORTED#####

my $in1 = $ARGV[0];  #EH file with reference adjacencies 
#MAM_loxAfr4,1,0,734413,3471046,4205459,+1,T_loxAfr4,1,1
my $in2 = $ARGV[1];  #EH file with query adjacencies
my $out = $ARGV[2];
my $out2 = $ARGV[3];
my $perc = $ARGV[4]; #fraction of  overlap between blocks in 2 references

open IN1, $in1 or die "Can't open $in1\n";
open IN2, $in2 or die "Cant' open $in2\n";
open OUT, ">$out" or die "Can't create $out file\n";
open OUT1, ">$out2" or die "Can't create $out2 file\n";
print OUT "Scaf1\tScafStart1\tScafEnd1\tScafOr1\tScaf2\tScafStart2\tScafEnd2\tScafOr2\tChr_in1\tChr_in2\tStatus1st\tStatus2nd\tStatusAdj\tNote\n";
print OUT1 "Scaf1\tScafStart1\tScafEnd1\tScafOr1\tScaf2\tScafStart2\tScafEnd2\tScafOr2\n";

my (@in1, @in2);

my $x = 0;
while (<IN1>) {
	chomp;
	my $lc = lc($_);
	@{$in1[$x]} = split(/,/, $lc);
	$x++;
}

my $y = 0;
while (<IN2>) {
	chomp;
	my $lc2 = lc($_);
	@{$in2[$y]} = split(/,/, $lc2);
	$y++;	
}

STEP: for my $i (0..$#in1) {
	my $flag1 = "1stNotFound\t2ndNotFound";
	my $ori;
	#MAM_loxAfr4,1,0,734413,3471046,4205459,+1,T_loxAfr4,1,1
	my ($l0, $chr0, $chrStart0, $chrEnd0, $scafStart0, $scafEnd0, $scafOr0, $sps0, $scaf0, $sc0) = @{$in1[$i-1]}; #previous line
	my ($l1, $chr1, $chrStart1, $chrEnd1, $scafStart1, $scafEnd1, $scafOr1, $sps1, $scaf1, $sc1) = @{$in1[$i]}; 	#current line
	my ($l2, $chr2, $chrStart2, $chrEnd2, $scafStart2, $scafEnd2, $scafOr2, $sps2, $scaf2, $sc2) = @{$in1[$i+1]};	#next line
	
	#one block RACFs
	if ($chr1 ne $chr2 and $chr1 ne $chr0) { next STEP; }
	#lastLine in RACF
	elsif ($chr1 ne $chr2) { next STEP; }
	#all other cases 
	else {
		if ($scafOr1 eq $scafOr2) { $ori = "same"; } #scafs have same orientation
		if ($scafOr1 ne $scafOr2) { $ori = "diff"; } #scafs have different orientation
		print OUT1 "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\n";
		print "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t";
		for my $j (0..$#in2) {	#for each scaf in ref2
			my ($ori2,$ori3);
			my ($l21, $chr21, $chrStart21, $chrEnd21, $scafStart21, $scafEnd21, $scafOr21, $sps21, $scaf21, $sc21) = @{$in2[$j]};
			my $minSt = max($scafStart1, $scafStart21);        
			my $minEnd = min($scafEnd1, $scafEnd21);
			#check if scafs overlap - if passes, 1stFound
			if ($chr1 eq $chr2 and $scaf1 eq $scaf21 and $scafStart1 <= $scafEnd21 and $scafEnd1 >= $scafStart21 and (($minEnd - $minSt) >= (($scafEnd1-$scafStart1) * $perc)) ) {
				if ($j == 0) { #If block in first line, only check next block
					my ($l22, $chr22, $chrStart22, $chrEnd22, $scafStart22, $scafEnd22, $scafOr22, $sps22, $scaf22, $sc22) = @{$in2[$j+1]};
					if ($scafOr21 eq $scafOr22) {$ori2= "same"; }
					if ($scafOr21 ne $scafOr22) {$ori2 = "diff"; }
					my $minSt1 = max($scafStart2, $scafStart22);
					my $minEn1 = min($scafEnd2, $scafEnd22);
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print "second found\t";
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound\tMaintained\t2nd_1stLine\n";
						$flag1 = "1stFound\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
					elsif ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori ne $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound\tNotMaintained\tInverted\n";
						$flag1 = "1stFound\t2ndFound";
						print $flag1."\n";
						next STEP;
					}	
				}
				elsif ($j == $#in2) { #If block in the last line, only check previous block
					my ($l20, $chr20, $chrStart20, $chrEnd20, $scafStart20, $scafEnd20, $scafOr20, $sps20, $scaf20, $sc20) = @{$in2[$j-1]};
					if ($scafOr21 eq $scafOr20) { $ori3= "same"; }
					if ($scafOr21 ne $scafOr20) { $ori3 = "diff"; }
					my $minSt2 = max($scafStart2, $scafStart20);
					my $minEn2 = min($scafEnd2, $scafEnd20);
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound\tMaintained\t2nd_LastLine\n";
						$flag1 = "1stFound\t2ndFound";
						print $flag1."\n";
						next STEP;
					} 
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori ne $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound\tNotMaintained\tInverted\n";
						$flag1 = "1stFound\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
				}
				else {
					my ($l20, $chr20, $chrStart20, $chrEnd20, $scafStart20, $scafEnd20, $scafOr20, $sps20, $scaf20, $sc20) = @{$in2[$j-1]};
					my ($l22, $chr22, $chrStart22, $chrEnd22, $scafStart22, $scafEnd22, $scafOr22, $sps22, $scaf22, $sc22) = @{$in2[$j+1]};
					if ($scafOr21 eq $scafOr22) {$ori2= "same"; }
					if ($scafOr21 ne $scafOr22) {$ori2 = "diff"; }
					if ($scafOr21 eq $scafOr20) {$ori3= "same"; }
					if ($scafOr21 ne $scafOr20) {$ori3 = "diff"; }

					my $minSt1 = max($scafStart2, $scafStart22);
					my $minEn1 = min($scafEnd2, $scafEnd22);
					my $minSt2 = max($scafStart2, $scafStart20);
					my $minEn2 = min($scafEnd2, $scafEnd20);

					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound\tMaintained\tDOWNST\n";
						$flag1 = "1stFound\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound_underThr\tMaintained\tDOWNST\n";
						$flag1 = "1stFound\t2ndFound_underThr";
						print $flag1."\n";
						next STEP;
					}
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori ne $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound\tNotMaintained\tDOWNST_inverted\n";
						$flag1 = "1stFound\t2ndFound";
						print $flag1."\n";
						next STEP;
					}

					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound\tMaintained\tUPST\n";
						$flag1 = "1stFound\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound_underThr\tMaintained\tUPST\n";
						$flag1 = "1stFound\t2ndFound_underThr";
						print $flag1."\n";
						next STEP;
					}
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori ne $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound\t2ndFound\tNotMaintained\tUPST_inverted\n";
						$flag1 = "1stFound\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
					# if (($chr21 ne $chr22 and $scafOr1 eq $scafOr21) or ($chr21 ne $chr20 and $scafOr1 eq $scafOr20)) {
					# 	next STEP;
					# }
				}
				print "1st found but second not found\n";
				next STEP;
			}
			#-- End of 1stFound--#
			elsif ($chr1 eq $chr2 and $scaf1 eq $scaf21 and $scafStart1 <= $scafEnd21 and $scafEnd1 >= $scafStart21){
				if ($j == 0) { #If block in first line, only check next block
					my ($l22, $chr22, $chrStart22, $chrEnd22, $scafStart22, $scafEnd22, $scafOr22, $sps22, $scaf22, $sc22) = @{$in2[$j+1]};
					if ($scafOr21 eq $scafOr22) {$ori2= "same"; }
					if ($scafOr21 ne $scafOr22) {$ori2 = "diff"; }
					my $minSt1 = max($scafStart2, $scafStart22);
					my $minEn1 = min($scafEnd2, $scafEnd22);
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound\tMaintained\t2nd_1stLine\n";
						$flag1 = "1stFound_underThr\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
					elsif ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori ne $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound\tNotMaintained\tInverted\n";
						$flag1 = "1stFound_underThr\t2ndFound";
						print $flag1."\n";
						next STEP;
					}	
				}
				elsif ($j == $#in2) { #If block in the last line, only check previous block
					my ($l20, $chr20, $chrStart20, $chrEnd20, $scafStart20, $scafEnd20, $scafOr20, $sps20, $scaf20, $sc20) = @{$in2[$j-1]};
					if ($scafOr21 eq $scafOr20) { $ori3= "same"; }
					if ($scafOr21 ne $scafOr20) { $ori3 = "diff"; }
					my $minSt2 = max($scafStart2, $scafStart20);
					my $minEn2 = min($scafEnd2, $scafEnd20);
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound\tMaintained\t2nd_LastLine\n";
						$flag1 = "1stFound_underThr\t2ndFound";
						print $flag1."\n";
						next STEP;
					} 
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori ne $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound\tNotMaintained\tInverted\n";
						$flag1 = "1stFound_underThr\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
				}
				else {
					my ($l20, $chr20, $chrStart20, $chrEnd20, $scafStart20, $scafEnd20, $scafOr20, $sps20, $scaf20, $sc20) = @{$in2[$j-1]};
					my ($l22, $chr22, $chrStart22, $chrEnd22, $scafStart22, $scafEnd22, $scafOr22, $sps22, $scaf22, $sc22) = @{$in2[$j+1]};
					if ($scafOr21 eq $scafOr22) {$ori2= "same"; }
					if ($scafOr21 ne $scafOr22) {$ori2 = "diff"; }
					if ($scafOr21 eq $scafOr20) {$ori3= "same"; }
					if ($scafOr21 ne $scafOr20) {$ori3 = "diff"; }

					my $minSt1 = max($scafStart2, $scafStart22);
					my $minEn1 = min($scafEnd2, $scafEnd22);
					my $minSt2 = max($scafStart2, $scafStart20);
					my $minEn2 = min($scafEnd2, $scafEnd20);

					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound\tMaintained\tDOWNST\n";
						$flag1 = "1stFound_underThr\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound_underThr\tMaintained\tDOWNST\n";
						$flag1 = "1stFound_underThr\t2ndFound_underThr";
						print $flag1."\n";
						next STEP;
					}
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori ne $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound\tNotMaintained\tDOWNST_inverted\n";
						$flag1 = "1stFound_underThr\t2ndFound";
						print $flag1."\n";
						next STEP;
					}

					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound\tMaintained\tUPST\n";
						$flag1 = "1stFound_underThr\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound_underThr\tMaintained\tUPST\n";
						$flag1 = "1stFound_underThr\t2ndFound_underThr";
						print $flag1."\n";
						next STEP;
					}
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori ne $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
						print OUT "1stFound_underThr\t2ndFound\tNotMaintained\tUPST_inverted\n";
						$flag1 = "1stFound_underThr\t2ndFound";
						print $flag1."\n";
						next STEP;
					}
					# if (($chr21 ne $chr22 and $scafOr1 eq $scafOr21) or ($chr21 ne $chr20 and $scafOr1 eq $scafOr20)) {
					# 	next STEP;
					# }
				}
				next STEP;
			}
			#-- End of 1stFound under threshold --#
		}
	}

	if ($flag1 eq "1stNotFound\t2ndNotFound") {
		
		for my $j (0..$#in2) {	#for each scaf in ref2
			my ($ori2,$ori3);
			my ($l21, $chr21, $chrStart21, $chrEnd21, $scafStart21, $scafEnd21, $scafOr21, $sps21, $scaf21, $sc21) = @{$in2[$j]};
			my $minSt = max($scafStart1, $scafStart21);        
			my $minEnd = min($scafEnd1, $scafEnd21);
		
			if ($j == 0) { #If block in first line, only check next block
				my ($l22, $chr22, $chrStart22, $chrEnd22, $scafStart22, $scafEnd22, $scafOr22, $sps22, $scaf22, $sc22) = @{$in2[$j+1]};
				if ($scafOr21 eq $scafOr22) {$ori2= "same"; }
				if ($scafOr21 ne $scafOr22) {$ori2 = "diff"; }
			
				my $minSt1 = max($scafStart2, $scafStart22);
				my $minEn1 = min($scafEnd2, $scafEnd22);
				if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t"; 
					print OUT "1stNotFound\t2ndFound\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}
				elsif ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori ne $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t";
					print OUT "1stNotFound\t2ndFound\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}	
			}
			elsif ($j == $#in2) { #If block in the last line, only check previous block
				my ($l20, $chr20, $chrStart20, $chrEnd20, $scafStart20, $scafEnd20, $scafOr20, $sps20, $scaf20, $sc20) = @{$in2[$j-1]};
				if ($scafOr21 eq $scafOr20) { $ori3= "same"; }
				if ($scafOr21 ne $scafOr20) { $ori3 = "diff"; }
				my $minSt2 = max($scafStart2, $scafStart20);
				my $minEn2 = min($scafEnd2, $scafEnd20);
				if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t";
					print OUT "1stNotFound\t2ndFound\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				} 
				if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori ne $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
					print OUT "1stNotFound\t2ndFound\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}
			}
			else {
				my ($l20, $chr20, $chrStart20, $chrEnd20, $scafStart20, $scafEnd20, $scafOr20, $sps20, $scaf20, $sc20) = @{$in2[$j-1]};
				my ($l22, $chr22, $chrStart22, $chrEnd22, $scafStart22, $scafEnd22, $scafOr22, $sps22, $scaf22, $sc22) = @{$in2[$j+1]};
				if ($scafOr21 eq $scafOr22) {$ori2= "same"; }
				if ($scafOr21 ne $scafOr22) {$ori2 = "diff"; }
				if ($scafOr21 eq $scafOr20) {$ori3= "same"; }
				if ($scafOr21 ne $scafOr20) {$ori3 = "diff"; }

				my $minSt1 = max($scafStart2, $scafStart22);
				my $minEn1 = min($scafEnd2, $scafEnd22);
				my $minSt2 = max($scafStart2, $scafStart20);
				my $minEn2 = min($scafEnd2, $scafEnd20);
	
				if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t";
					print OUT "1stNotFound\t2ndFound\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}
				if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t";
					print OUT "1stNotFound\t2ndFound_underThr\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}
				if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori ne $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t";
					print OUT "1stNotFound\t2ndFound\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}

				if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t";
					print OUT "1stNotFound\t2ndFound\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}
				if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t";
					print OUT "1stNotFound\t2ndFound_underThr\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}
				if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori ne $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
					print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t";
					print OUT "1stNotFound\t2ndFound\tNotMaintained\t\n";
					$flag1 = "1stNotFound\t2ndFound";
					print $flag1."\n";
					next STEP;
				}
			}
		}		
		#print OUT "1stNotFound\t2ndNotFound\tUniqueAdj\n";
		print $flag1."\n";
		next STEP;
	}
}
exit;