#!/usr/bin/perl
use strict;
#use warnings;
use Data::Dumper;
use List::Util qw(min max);

######INPUT FILES NEED TO BE SORTED#####

my $in1 = $ARGV[0];  #refRef  cattleCattle
#chr chrstart chrend scaff scaffstart scaffend strand
my $in2 = $ARGV[1];  #otherRef sheepCattle
my $out = $ARGV[2];
#my $sps = $ARGV[3];
#my $perc = $ARGV[4]; #fraction of  overlap between blocks in 2 references
my $perc = $ARGV[3]; #fraction of  overlap between blocks in 2 references

open IN1, $in1 or die "Can't open infile 1\n";
open IN2, $in2 or die "Cant' open infile 2\n";
open OUT, ">$out" or die "Can't create $out file\n";
print OUT "Scaf1\tScafStart1\tScafEnd1\tScafOr1\tScaf2\tScafStart2\tScafEnd2\tScafOr2\tChr_in1\tChr_in2\tStatus1st\tStatus2nd\tStatusAdj\tNote\n";

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
	#my $flag1 = "notMaintained\tnotFound";
	my $flag1 = "1stNotFound\t2ndNotFound\tUniqueAdj\t\n";
	my $ori;
	#my $data = $in1[$i];
	#my $data1 = $in1[$i+1];
	my ($l0, $chr0, $chrStart0, $chrEnd0, $scafStart0, $scafEnd0, $scafOr0, $sps0, $scaf0, $sc0) = @{$in1[$i-1]}; #previous line
	my ($l1, $chr1, $chrStart1, $chrEnd1, $scafStart1, $scafEnd1, $scafOr1, $sps1, $scaf1, $sc1) = @{$in1[$i]}; 	#current line
	my ($l2, $chr2, $chrStart2, $chrEnd2, $scafStart2, $scafEnd2, $scafOr2, $sps2, $scaf2, $sc2) = @{$in1[$i+1]};	#next line
	
	if ($chr1 ne $chr2 and $chr1 ne $chr0) { #CARs with one block only
		next STEP;	
	}
	elsif ($chr1 ne $chr2) {	#lastLine of CAR
		next STEP;
	}
	else {	#scaf not alone in block and not last line
		#print "$chr1 $chr2\n";
		if ($scafOr1 eq $scafOr2) { $ori = "same"; } #scafs have same orientation
		if ($scafOr1 ne $scafOr2) { $ori = "diff"; } #scafs have different orientation

		for my $j (0..$#in2) {	#for each scaf in ref2
			#print "$j\t".scalar(@in2)."\n";
			my ($ori2,$ori3);
			my ($l21, $chr21, $chrStart21, $chrEnd21, $scafStart21, $scafEnd21, $scafOr21, $sps21, $scaf21, $sc21) = @{$in2[$j]};
			my $minSt = max($scafStart1, $scafStart21);        
			my $minEnd = min($scafEnd1, $scafEnd21);

			#check if scafs overlap
			if ($chr1 eq $chr2 and $scaf1 eq $scaf21 and $scafStart1 <= $scafEnd21 and $scafEnd1 >= $scafStart21 and (($minEnd - $minSt) >= (($scafEnd1-$scafStart1) * $perc)) ) {
				print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\t$chr21\t";
				#$flag1= "maintained\tnotFound";
				$flag1 = "1stFound\t2ndNotFound\tUniqueAdj\n";
				
				if ($j == 0) { #If block in first line, only check next block
					my ($l22, $chr22, $chrStart22, $chrEnd22, $scafStart22, $scafEnd22, $scafOr22, $sps22, $scaf22, $sc22) = @{$in2[$j+1]};
					#my ($refChr22, $refStart22, $refEnd22) = $in2[$j+1][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;				
					if ($scafOr21 eq $scafOr22) {$ori2= "same"; }
					if ($scafOr21 ne $scafOr22) {$ori2 = "diff"; }
					my $minSt1 = max($scafStart2, $scafStart22);
					my $minEn1 = min($scafEnd2, $scafEnd22);
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						#print OUT "maintained\tbothUsed\tfirstLine\n";
						#$flag1 = "maintained\tfound";
						$flag1 = "1stFound\t2ndFound\tMaintained\tfirstLine\n";
						print OUT $flag1;
						next STEP;
					}
					elsif ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori ne $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						# print OUT "notMaintained\tbothUsed\tinverted\n";
						# $flag1 = "notMaintained\tfound";
						$flag1 = "1stFound\t2ndFound\tNotMaintained\tInverted\n";
						print OUT $flag1;
						next STEP;
					}	
				}
				#if ($j == scalar @in2) { #If block in the last line, only check previous block
				if ($j == $#in2) { #If block in the last line, only check previous block
					#print "Here $scaf1 $scaf2\n";
					my ($l20, $chr20, $chrStart20, $chrEnd20, $scafStart20, $scafEnd20, $scafOr20, $sps20, $scaf20, $sc20) = @{$in2[$j-1]};
					#my ($refChr20, $refStart20, $refEnd20) = $in2[$j-1][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;				
					if ($scafOr21 eq $scafOr20) { $ori3= "same"; }
					if ($scafOr21 ne $scafOr20) { $ori3 = "diff"; }
					my $minSt2 = max($scafStart2, $scafStart20);
					my $minEn2 = min($scafEnd2, $scafEnd20);
					#print "Still going\n";
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						#print "Heya!\n";
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						#print OUT "maintained\tbothUsed\tlastLine\n";
						#$flag1 = "maintained\tfound";
						$flag1 = "1stFound\t2ndFound\tMaintained\tLastLine\n";
						print OUT $flag1;

						next STEP;
					} #else{ "Something's wrong!\n"; next STEP; }
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori ne $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						#print "Heya!\n";
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						#print OUT "notMaintained\tbothUsed\tinverted\n";
						#$flag1 = "notMaintained\tfound";
						$flag1 = "1stFound\t2ndFound\tNotMaintained\tInverted\n";
						print OUT $flag1;
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

					#print "$scaf1 $scaf2 $ori $scaf21 $scaf20 $ori3\n";

					my $minSt1 = max($scafStart2, $scafStart22);
					my $minEn1 = min($scafEnd2, $scafEnd22);
					my $minSt2 = max($scafStart2, $scafStart20);
					my $minEn2 = min($scafEnd2, $scafEnd20);

					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						#print "Checking next ".$scaf1."\n";
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						#print OUT "maintained\tbothUsed\tDOWNST\n";
						#$flag1 = "maintained\tfound";
						$flag1 = "1stFound\t2ndFound\tMaintained\tDOWNST\n";
						print OUT $flag1;
						next STEP;
					}
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori eq $ori2) {
						#print "Checking next ".$scaf1."\n";
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						#print OUT "maintained\tbothUsed\tDOWNST\tThreshold2nd\n";
						#$flag1 = "maintained\tfound";
						$flag1 = "1stFound\t2ndFound\tMaintained\tDOWNST_2ndThr\n";
						print OUT $flag1;
						next STEP;
					}
					if ($chr21 eq $chr22 and $scaf2 eq $scaf22 and $scafStart2 <= $scafEnd22 and $scafEnd2 >= $scafStart22 and $ori ne $ori2 and (($minEn1 - $minSt1) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						#print "Checking next ".$scaf1."\n";
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						#print OUT "notMaintained\tbothUsed\tinverted\tDOWNST\n";
						#$flag1 = "notMaintained\tfound";
						$flag1 = "1stFound\t2ndFound\tNotMaintained\tInverted_DOWNST\n";
						print OUT $flag1;
						next STEP;
					}

					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						#print "Checking previous ".$scaf1."\n";
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						#print OUT "maintained\tbothUsed\tUPST\n";
						#$flag1 = "maintained\tfound";
						$flag1 = "1stFound\t2ndFound\tMaintained\tUPST\n";
						print OUT $flag1;
						next STEP;
					}
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori eq $ori3) {
						#print "Checking previous ".$scaf1."\n";
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						# print OUT "maintained\tbothUsed\tUPST\tThreshold2nd\n";
						# $flag1 = "maintained\tfound";
						$flag1 = "1stFound\t2ndFound\tMaintained\tUPST_2ndThr\n";
						print OUT $flag1;
						next STEP;
					}
					if ($chr21 eq $chr20 and $scaf2 eq $scaf20 and $scafStart2 <= $scafEnd20 and $scafEnd2 >= $scafStart20 and $ori ne $ori3 and (($minEn2 - $minSt2) >= (($scafEnd2-$scafStart2) * $perc)) ) {
						#print "Checking previous ".$scaf1."\n";
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						#print OUT "notMaintained\tbothUsed\tinverted\tUPST\n";
						#$flag1 = "notMaintained\tfound";
						$flag1 = "1stFound\t2ndFound\tNotMaintained\tInverted_UPST\n";
						print OUT $flag1;
						next STEP;
					}
					if (($chr21 ne $chr22 and $scafOr1 eq $scafOr21) or ($chr21 ne $chr20 and $scafOr1 eq $scafOr20)) {
						#print OUT "notMaintained\toneUsed\tendOfTarget\n";
						#$flag1 = "notMaintained\tfound";
						$flag1 = "1stFound\t2ndFound\tNotMaintained\tendOfTarget\n";
						print OUT $flag1;
						next STEP;
					}
				}
			}
		}
	}
	#if ($flag1 eq "maintained\tnotFound") {
	if ($flag1 eq "1stFound\t2ndNotFound\tUniqueAdj\n"){
		my %used = ();
		foreach my $l (0..$#in2) {
			my $id = $in2[$l][3];
			$used{$id} = ();
		}
		#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t"; 
		#print OUT "notMaintained\t";
		if (exists $used{$scaf1} and exists $used{$scaf2}) {
			#print OUT "bothUsed\n";
			print OUT "1stFound\t2ndFound\tUniqueAdj\tBothScafsUsed\n";
		}	
		elsif (! exists $used{$scaf1} or ! exists $used{$scaf2}) {
			#print OUT "oneNotUsed\n";
			print OUT "1stFound\t2ndFound\tUniqueAdj\tOneScafUsed\n";
		}
		else {
			#print OUT "bothNotUsed\n";
			print OUT "1stFound\t2ndFound\tUniqueAdj\tNoneScafsUsed\n";
		}
	}

	#if ($flag1 eq "notMaintained\tnotFound") {
	if ($flag1 eq "1stNotFound\t2ndNotFound\tUniqueAdj\t\n"){
		my %used = ();
		foreach my $l (0..$#in2) {
			my $id = $in2[$l][3];
			$used{$id} = ();
		}
		print OUT "$scaf1\t$scafStart1\t$scafEnd1\t$scafOr1\t$scaf2\t$scafStart2\t$scafEnd2\t$scafOr2\t$chr1\tnf\t"; 
		#print OUT "notFound\t";
		if (exists $used{$scaf1} and exists $used{$scaf2}) {
			#print OUT "bothUsed\n";
			print OUT "1stFound\t2ndFound\tUniqueAdj\tBothScafsUsed\n";
		}	
		elsif (! exists $used{$scaf1} or ! exists $used{$scaf2}) {
			#print OUT "oneNotUsed\n";
			print OUT "1stFound\t2ndFound\tUniqueAdj\tOneScafUsed\n";
		}
		else {
			#print OUT "bothNotUsed\n";
			print OUT "1stFound\t2ndFound\tUniqueAdj\tNoneScafsUsed\n";
		}
	}

}
