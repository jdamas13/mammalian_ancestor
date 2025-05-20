#/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(min max);
use List::MoreUtils qw(uniq);
require "/share/lewinlab/jmdamas/perl_scripts/modules/mergeBlocks.pm";

my $in1 = $ARGV[0];  #EH file with reference adjacencies 
#MAM_loxAfr4,1,0,734413,3471046,4205459,+1,T_loxAfr4,1,1
my $in2 = $ARGV[1];  #EH file with query adjacencies
my $out = $ARGV[2];
my $out2 = $ARGV[3];
my $perc = $ARGV[4]; #fraction of  overlap between blocks in 2 references
my $res = $ARGV[5];

my (@in1, @in2);
open (IN1, $in1) or die "Can't open $in1\n";
open (OUT, ">tmp1") or die "Couldn't create tmp1!\n";
while (<IN1>) {
	chomp;
	my @tmp = split(/,/, $_);
	my $block_len = $tmp[3] - $tmp[2];
	if ($block_len >= $res){ print OUT $_."\n"; }
}
close IN1;
close OUT;
MergeBlocks::mergeBlocks("tmp1", $res);

open (IN1, "tmp1.merged") or die "Can't open tmp1.merged\n";
my $x = 0;
while (<IN1>) {
	chomp;
	my $lc = lc($_);
	my @tmp = split(/,/, $lc);
	@{$in1[$x]} = @tmp;
	$x++;
}
close IN1;

open (IN2, $in2) or die "Can't open $in2\n";
open (OUT, ">tmp2") or die "Couldn't create tmp2!\n";
while (<IN2>) {
	chomp;
	my @tmp2 = split(/,/, $_);
	my $block_len = $tmp2[3] - $tmp2[2];
	if ($block_len >= $res){ print OUT $_."\n"; }
}
close IN2;
close OUT;
MergeBlocks::mergeBlocks("tmp2", $res);

open (IN2, "tmp2.merged") or die "Can't open tmp2.merged\n";
my $y = 0;
while (<IN2>) {
	chomp;
	my $lc2 = lc($_);
	my @tmp2 = split(/,/, $lc2);
	@{$in2[$y]} = @tmp2;
	$y++;
}
close IN2;


open (OUT, ">$out") or die "Can't create $out file\n";
print OUT "Scaf1\tScafStart1\tScafEnd1\tScafOr1\tScaf2\tScafStart2\tScafEnd2\tScafOr2\tStatus1st\tNote1st\tStatus2nd\tNote2nd\tStatusAdj\tNote\n";
open (OUT1, ">$out2") or die "Can't create $out2 file\n";
print OUT1 "Scaf1\tScafStart1\tScafEnd1\tScafOr1\tScaf2\tScafStart2\tScafEnd2\tScafOr2\tChr1\tChr2\n";

STEP: for my $i (0..$#in1-1){
	my ($flag1, $flag2, $status, $note) = ("1stFound", "2ndFound", "Maintained", "");
	my ($li, $chri, $chrStarti, $chrEndi, $scafStarti, $scafEndi, $ori, $spsi, $scafi, $sli) = @{$in1[$i]}; 	#current line
	my ($lin, $chrin, $chrStartin, $chrEndin, $scafStartin, $scafEndin, $orin, $spsin, $scafin, $slin) = @{$in1[$i+1]}; 	#next line

	if ($chri ne $chrin){ next STEP; } #skips end of RACF and one-block RACFs
	else{
		if ($scafStarti <= $scafStartin) {
			print OUT1 "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$chri\t$chrin\n";
		} else {
			my $n_orin = $orin*-1;
			my $n_ori = $ori*-1;
			print OUT1 "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$chri\t$chrin\n";
		}
		#finding blocks overlap
		my ($idx, $war) = &find_overlap($i, "first");
		if (not defined $idx){ $flag1 = "1stNotFound"; $status = "Inconsistent"; }
		my ($idxn, $warn) = &find_overlap($i+1, "second");
		if (not defined $idxn){ $flag2 = "2ndNotFound"; $status = "Inconsistent"; }
		if ($war eq "zeroOverlap" or $warn eq "zeroOverlap") { $status = "Absent"; }
		#print "$idx\t$war\t$idxn\t$warn\t$status\n"; 
		# print not founds and move to next
		if ($status eq "Inconsistent" or $status eq "Absent"){
			if ($scafStarti <= $scafStartin) {
				print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\t\n";
			} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\t\n";
			}
			next STEP;
		}
		#UP TO HERE IT WORKS!!

		my ($lj, $chrj, $chrStartj, $chrEndj, $scafStartj, $scafEndj, $orj, $spsj, $scafj, $slj) = @{$in2[$idx]};
		my ($ljn, $chrjn, $chrStartjn, $chrEndjn, $scafStartjn, $scafEndjn, $orjn, $spsjn, $scafjn, $sljn) = @{$in2[$idxn]};
		
		my ($first_ori, $second_ori);
		if ($ori eq $orj) { $first_ori = "same"; } else { $first_ori = "diff"; }
		if ($orin eq $orjn) { $second_ori = "same"; } else { $second_ori = "diff"; }

		if ($first_ori eq "same" and $idxn == $idx+1){ #if block dir in human is same as cow idxn has to be equal to $idx+1
			if ($second_ori eq "same"){ # consecutive and relative orientations are the same
				if ($scafStarti <= $scafStartin) {
					print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\t\n";
				} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\t\n";
				}
				next STEP;
			} else { # consecutive and relative orientations are different, means one of the blocks in inverted
				$status = "Inconsistent";
				if ($scafStarti <= $scafStartin) {
					print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\toneIsInverted\n";
				} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\toneIsInverted\n";
				}
				next STEP;
			}
		} elsif ($first_ori eq "diff" and $idxn == $idx-1) {
			if ($second_ori eq "diff"){ # consecutive and relative orientations are the same
				if ($scafStarti <= $scafStartin) {
					print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\t\n";
				} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\t\n";
				}
				next STEP;
			} else { # consecutive and relative orientations are different, means one of the blocks in inverted
				$status = "Inconsistent";
				if ($scafStarti <= $scafStartin) {
					print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\toneIsInverted\n";
				} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\toneIsInverted\n";
				}
				next STEP;
			}
		} elsif ($first_ori eq "same" and $idxn != $idx+1) { # not consecutive
			my $end_first = &check_ends($idx, "first");
			my $end_second = &check_ends($idx, "second");
			if ($end_first eq "true" and $end_second eq "true"){
				$status = "Absent";
				if ($scafStarti <= $scafStartin) {
					print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\tbothEnds\n";
				} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\tbothEnds\n";
				}
				next STEP;
			} else {
				$status = "Inconsistent";
				if ($scafStarti <= $scafStartin) {
					print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\t\n";
				} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\t\n";
				}
				next STEP;
			}
			#print "SAME not cool\t$idx\t$war\t$idxn\t$warn\t$status\t$end_first\t$end_second\n"; 
		} elsif ($first_ori eq "diff" and $idxn != $idx-1) { # not consecutive
			my $end_first = &check_ends($idx, "first");
			my $end_second = &check_ends($idx, "second");
			if ($end_first eq "true" and $end_second eq "true"){
				$status = "Absent";
				if ($scafStarti <= $scafStartin) {
					print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\tbothEnds\n";
				} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\tbothEnds\n";
				}
				next STEP;
			} else {
				$status = "Inconsistent";
				if ($scafStarti <= $scafStartin) {
					print OUT "$scafi\t$scafStarti\t$scafEndi\t$ori\t$scafin\t$scafStartin\t$scafEndin\t$orin\t$flag1\t$war\t$flag2\t$warn\t$status\t\n";
				} else {
					my $n_orin = $orin*-1;
					my $n_ori = $ori*-1;
					print OUT "$scafin\t$scafStartin\t$scafEndin\t$n_orin\t$scafi\t$scafStarti\t$scafEndi\t$n_ori\t$flag2\t$warn\t$flag1\t$war\t$status\t\n";
				}
				next STEP;
				#print "DIFF not cool\t$idx\t$war\t$idxn\t$warn\t$status\t$end_first\t$end_second\n";
			}
		}
		# if ($war eq "overlapFAR" or $warn eq "overlapFAR") { 
			

		# 	$status = "Inconsistent";
		# }
	}
} close OUT; close OUT1;

#Calculate stats
my @status;
open (IN, $out) or die "Couldn't open $out!\n";
while(<IN>){
	chomp;
	if ($_ =~ /^Scaf1/) { next; }
	else{
		my @tmp = split(/\t/, $_);
		push(@status, $tmp[12]); 
	}
} close IN;

my $total_adjs = scalar(@status);
my @uniq_status = uniq @status;

print "Total no. adj = $total_adjs\n";
foreach my $stat (@uniq_status){
	my $cnt = grep { $_ eq "$stat" } @status;
	my $perc = sprintf("%.2f", $cnt/$total_adjs*100);
	print "$stat -> N = $cnt\t$perc%\n";
}


## SUBROUTINES ##
sub find_overlap{
	my ($i, $pos) = @_;

	my ($li, $chri, $chrStarti, $chrEndi, $scafStarti, $scafEndi, $ori, $spsi, $scafi, $sli) = @{$in1[$i]};

	my $line; my $note = "zeroOverlap";
	for my $j (0..$#in2){
		my ($lj, $chrj, $chrStartj, $chrEndj, $scafStartj, $scafEndj, $orj, $spsj, $scafj, $slj) = @{$in2[$j]};
		my $maxStart = max($scafStarti, $scafStartj);        
 		my $minEnd = min($scafEndi, $scafEndj);
		my $fracOveri = ($minEnd - $maxStart) / ($scafEndi - $scafStarti);
		my $fracOverj = ($minEnd - $maxStart) / ($scafEndj - $scafStartj);
		#check if there is overlap and both blocks pass overlap fraction threshold
		if ($scafi eq $scafj and $scafStarti <= $scafEndj and $scafEndi >= $scafStartj){
			if($fracOveri >= $perc and $fracOverj >= $perc){
				#print "OVERLAP FOUND $scafi $scafStarti $scafEndi $ori $scafj $scafStartj $scafEndj $orj BOTH PASS\n"; 
				$line = $j; $note = "OverlapOK"; return ($line, $note); last; 
			} 
			elsif ($fracOveri < $perc or $fracOverj < $perc){
				my $dist2start = abs($scafStarti - $scafStartj);
				my $dist2end = abs($scafEndi - $scafEndj);
				if ($pos eq "first") {
					if ($ori !~ /-/ and $dist2end < $res*1.5){
						#print "OVERLAP FOUND $scafi $scafStarti $scafEndi $ori $scafj $scafStartj $scafEndj $orj BUT CLOSE TO END\n";
						$line = $j; $note = "close2end"; #return ($line, $note); last;
					} elsif ($ori =~ /-/ and $dist2start < $res*1.5) {
						#print "OVERLAP FOUND $scafi $scafStarti $scafEndi $ori $scafj $scafStartj $scafEndj $orj BUT CLOSE TO START\n";
						$line = $j; $note = "close2start"; #return ($line, $note); last;
					} else {
				 		#print "OVERLAP FOUND $scafi $scafStarti $scafEndi $ori $scafj $scafStartj $scafEndj $orj $dist2start $dist2end STOPS HERE\n";
						$line = $j; $note = "overlapFAR"; #return ($line, $note); last;
					}
				} elsif ($pos eq "second"){
					if ($ori !~ /-/ and $dist2start < $res*1.5){
						#print "OVERLAP FOUND $scafi $scafStarti $scafEndi $ori $scafj $scafStartj $scafEndj $orj BUT CLOSE TO END\n";
						$line = $j; $note = "close2start"; #return ($line, $note); last;
					} elsif ($ori =~ /-/ and $dist2end < $res*1.5) {
						#print "OVERLAP FOUND $scafi $scafStarti $scafEndi $ori $scafj $scafStartj $scafEndj $orj BUT CLOSE TO START\n";
						$line = $j; $note = "close2end"; #return ($line, $note); last;
					} else {
				 		#print "OVERLAP FOUND $scafi $scafStarti $scafEndi $ori $scafj $scafStartj $scafEndj $orj $dist2start $dist2end STOPS HERE\n";
						$line = $j; $note = "overlapFAR"; #return ($line, $note); last;
					}
				}
			} 
		}
	}
	return ($line, $note);
}

sub check_ends {
	my ($no, $pos) = @_;
	
	my $end = "false";

	my ($l, $chr, $chrStart, $chrEnd, $scafStart, $scafEnd, $or, $sps, $scaf, $sl) = @{$in2[$no]};
	if ($pos eq "first"){
		if ($or !~ /-/){
			if($no == $#in2){ $end = "true"; }
			else{
				my $chrn = @{$in2[$no+1]}[1];
				if ($chr ne $chrn) { $end = "true"; }
			}
		} else{
			if($no == 0){ $end = "true"; }
			else {
				my $chrp = @{$in2[$no-1]}[1];
				if ($chr ne $chrp) { $end = "true"; }
			}
		}
	} elsif ($pos eq "second"){
		if ($or !~ /-/){
			if($no == 0){ $end = "true"; }
			else {
				my $chrp = @{$in2[$no-1]}[1];
				if ($chr ne $chrp) { $end = "true"; }
			}
		} else {
			if($no == $#in2){ $end = "true"; }
			else{
				my $chrn = @{$in2[$no+1]}[1];
				if ($chr ne $chrn) { $end = "true"; }
			}
		}
	}
	return ($end);
}

exit;
