#!/usr/bin/perl
use strict;
#use warnings;
use Data::Dumper;
use List::Util qw(min max);
#Compare Ancestral reconstructions from 2 different references -- use DB file

my $in1 = $ARGV[0];  #refRef  cattleCattle
my $in2 = $ARGV[1];  #otherRef sheepCattle
#format:
#insert into CONSENSUS values('NeogGGA:100K','1',175942,383557,75049136,75108819,-1,'Melgal','1',null,'1','1');
my $out = $ARGV[2];
my $sps = $ARGV[3]; #species to compare
my $perc = $ARGV[4]; #FRACTION of  overlap between blocks in 2 references

open IN1, $in1 or die "Can't open infile 1\n";
open IN2, $in2 or die "Cant' open infile 2\n";
open OUT, ">$out" or die "Can't create $out file\n";
open OUT1 , ">in1.txt";
open OUT2, ">in2.txt";

my (@in1, @in2);
#matrix format
##cattle.chr10:372900-2876446 + [1]

my $x = 0;
while (<IN1>) {
	chomp $_;
	if ($_ =~ /CONSENSUS/ && $_ =~ /$sps/ && $_ !~ /COMP_GEN/) {
		my $t = $_;
		$t =~ s/'//g;
		my @tmp = split(/,/,$t);
		if($tmp[6] eq "-1"){ $tmp[6] = "-";}
		if($tmp[6] eq "+1" || $tmp[6] eq "1"){ $tmp[6] = "+";}
		@{$in1[$x]} = ("${sps}.chr${tmp[8]}:${tmp[4]}-${tmp[5]}", $tmp[6], $tmp[1], $tmp[1]);
		$x++;
	}	
}

#print Dumper @in1;	

foreach my $l (0..$#in1) {
 	print  OUT1 "@{$in1[$l]}\n";
}


my $y = 0;
while (<IN2>) {
	chomp $_;
	if ($_ =~ /CONSENSUS/ && $_ =~ /$sps/ && $_ !~ /COMP_GEN/) {
		my $t = $_;
		$t =~ s/'//g;
		my @tmp = split(/,/,$t);
		if($tmp[6] eq "-1"){ $tmp[6] = "-";}
		if($tmp[6] eq "+1" || $tmp[6] eq "1"){ $tmp[6] = "+";}
		@{$in2[$y]} = ("${sps}.chr${tmp[8]}:${tmp[4]}-${tmp[5]}", $tmp[6], $tmp[1], $tmp[1]);
		$y++;
	}	
}

#print Dumper @in2;	

foreach my $l (0..$#in2) {
	print  OUT2 "@{$in2[$l]}\n";
}




STEP: for my $i (0..$#in1) {
	my $flag1 = "notMaintained\tnotFound";
	my $ori;
	my $data = $in1[$i][0];
	my $data1 = $in1[$i+1][0];
	my ($refChr, $refStart, $refEnd) = $data =~ /$sps\.(.*)\:(\d+)\-(\d+)/;
	my ($refChr1, $refStart1, $refEnd1) = $data1 =~/$sps\.(.*)\:(\d+)\-(\d+)/;
	
	#print "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$i\n";
	#print "$refChr\t$refStart\t$refEnd\t$i\n";
	if ($in1[$i][3] ne $in1[$i+1][3] and $in1[$i][3] ne $in1[$i-1][3]) {     #CARs with one block only
		print "ONE BLOCK!\n";
		#print $in1[$i][3];
		for my $j (0..$#in2) {
			my ($refChr2, $refStart2, $refEnd2) = $in2[$j][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;
			my $minSt = max($refStart, $refStart2);        
			my $minEnd = min($refEnd, $refEnd2);
				
			# if ($refChr eq $refChr2 and $refStart <= $refEnd2 and $refEnd >= $refStart2 ) { 
			# 	print "FOUND!\n";
			# 	print "$refChr\t$refStart\t$refEnd\t$refChr2\t$refStart2\t$refEnd2\t$i\t$j\t$minSt\t$minEnd\n";
			# 	my $minLen = $minEnd - $minSt;
			# 	my $refLen = $refEnd - $refStart;
			# 	my $limit =  $refLen * $perc;
			# 	print "MinLen = $minLen\tRefLen = $refLen\tLimit = $limit\n";
				
			# }
			
			if ($refChr eq $refChr2 and $refStart <= $refEnd2 and $refEnd >= $refStart2 and (($minEnd - $minSt) >= (($refEnd-$refStart) * $perc)) ) {
				print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
				print OUT "maintained\tused\talone\n";
				$flag1 = "maintained\tfound";
				next STEP;
			}
		}
	}
	if ($in1[$i][3] ne $in1[$i+1][3]) {     #lastLine of CAR
		#print $in1[$i][3];
		for my $j (0..$#in2) {
			my ($refChr2, $refStart2, $refEnd2) = $in2[$j][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;
			#print "$refChr\t$refStart\t$refEnd\t$refChr2\t$refStart2\t$refEnd2\t$i\t$j\n";
			my $minSt = max($refStart, $refStart2);    
			my $minEnd = min($refEnd, $refEnd2);
			if ($refChr eq $refChr2 and $refStart <= $refEnd2 and $refEnd >= $refStart2 and (($minEnd - $minSt) >= (($refEnd-$refStart) * $perc)) ) {
				print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
				print OUT "maintained\tused\tlastLineCAR\n";
				$flag1 = "maintained\tfound";
				next STEP;
			}
		}
	}
	else {
		if ($in1[$i][1] eq $in1[$i+1][1]) { $ori = "same"; } #same orientation
		if ($in1[$i][1] ne $in1[$i+1][1]) { $ori = "diff"; } #different orientation

		for my $j (0..$#in2) { #start the otherRef
			my ($ori2,$ori3);
			my ($refChr2, $refStart2, $refEnd2) = $in2[$j][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;
			my $minSt = max($refStart, $refStart2);        #HERE!!!
			my $minEnd = min($refEnd, $refEnd2);
			if ($in1[$i][3] eq $in1[$i+1][3] and $refChr eq $refChr2 and $refStart <= $refEnd2 and $refEnd >= $refStart2 and (($minEnd - $minSt) >= (($refEnd-$refStart) * $perc)) ) {
				print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
				$flag1= "maintained\tnotFound";
				if ($j == 0) { #If block in first line, only check next block
					my ($refChr22, $refStart22, $refEnd22) = $in2[$j+1][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;				
					if ($in2[$j][1] eq $in2[$j+1][1]) {$ori2= "same"; }
					if ($in2[$j][1] ne $in2[$j+1][1]) {$ori2 = "diff"; }
					my $minSt1 = max($refStart1, $refStart22);
					my $minEn1 = min($refEnd1, $refEnd22);
					if ($in2[$j][3] eq $in2[$j+1][3] and $refStart1 <= $refEnd22 and $refEnd1 >= $refStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($refEnd1-$refStart1) * $perc)) ) {
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						print OUT "maintained\tbothUsed\tfirstLine\n";
						$flag1 = "maintained\tfound";
						next STEP;
					}	
				}
				if ($j == scalar @in2) { #If block in the last line, only check previous block
					my ($refChr20, $refStart20, $refEnd20) = $in2[$j-1][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;				
					if ($in2[$j][1] eq $in2[$j-1][1]) {$ori3= "same"; }
					if ($in2[$j][1] ne $in2[$j-1][1]) {$ori3 = "diff"; }
					my $minSt2 = max($refStart1, $refStart20);
					my $minEn2 = min($refEnd1, $refEnd20);
					if ($in2[$j][3] eq $in2[$j+1][3] and $refStart1 <= $refEnd20 and $refEnd1 >= $refStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($refEnd1-$refStart1) * $perc)) ) {
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						print OUT "maintained\tbothUsed\tlastLine\n";
						$flag1 = "maintained\tfound";
						next STEP;
					}	
				}
				else {
					my ($refChr22, $refStart22, $refEnd22) = $in2[$j+1][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;				
					my ($refChr20, $refStart20, $refEnd20) = $in2[$j-1][0] =~/$sps\.(.*)\:(\d+)\-(\d+)/;				
					if ($in2[$j][1] eq $in2[$j+1][1]) {$ori2= "same"; }
					if ($in2[$j][1] ne $in2[$j+1][1]) {$ori2 = "diff"; }
					if ($in2[$j][1] eq $in2[$j-1][1]) {$ori3= "same"; }
					if ($in2[$j][1] ne $in2[$j-1][1]) {$ori3 = "diff"; }
					my $minSt1 = max($refStart1, $refStart22);
					my $minEn1 = min($refEnd1, $refEnd22);
					my $minSt2 = max($refStart1, $refStart20);
					my $minEn2 = min($refEnd1, $refEnd20);
					if ($in2[$j][3] eq $in2[$j+1][3] and $refStart1 <= $refEnd22 and $refEnd1 >= $refStart22 and $ori eq $ori2 and (($minEn1 - $minSt1) >= (($refEnd1-$refStart1) * $perc)) ) {
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						print OUT "maintained\tbothUsed\tplus\n";
						$flag1 = "maintained\tfound";
						next STEP;
					}
					if ($in2[$j][3] eq $in2[$j-1][3] and $refStart1 <= $refEnd20 and $refEnd1 >= $refStart20 and $ori eq $ori3 and (($minEn2 - $minSt2) >= (($refEnd1-$refStart1) * $perc)) ) {
						#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t$refChr2\t$refStart2\t$refEnd2\t$in2[$j][1]\t$in2[$j][3]\t";
						print OUT "maintained\tbothUsed\tminus\n";
						$flag1 = "maintained\tfound";
						next STEP;
					}
				}
			}
		}
	}
	if ($flag1 eq "maintained\tnotFound") {
		my %used = ();
		foreach my $l (0..$#in2) {
			my $id = $in2[$l][0] =~ /$sps\.(.*)\:/;
			$used{$id} = ();
		}
		#print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t"; 
		print OUT "notMaintained\t";
		if (exists $used{$refChr} and exists $used{$refChr1}) {
			print OUT "bothUsed\n";
		}	
		elsif (! exists $used{$refChr} or ! exists $used{$refChr1}) {
			print OUT "oneNotUsed\n";
		}
		else {
			print OUT "bothNotUsed\n";
		}
	}

	if ($flag1 eq "notMaintained\tnotFound") {
		my %used = ();
		foreach my $l (0..$#in2) {
			my $id = $in2[$l][0] =~ /$sps\.(.*)\:/;
			$used{$id} = ();
		}
		print OUT "$refChr\t$refStart\t$refEnd\t$in1[$i][1]\t$in1[$i][3]\t"; 
		print OUT "na\tna\tna\tna\tna\tnotFound\t";
		if (exists $used{$refChr} and exists $used{$refChr1}) {
			print OUT "bothUsed\n";
		}	
		elsif (! exists $used{$refChr} or ! exists $used{$refChr1}) {
			print OUT "oneNotUsed\n";
		}
		else {
			print OUT "bothNotUsed\n";
		}
	}

}