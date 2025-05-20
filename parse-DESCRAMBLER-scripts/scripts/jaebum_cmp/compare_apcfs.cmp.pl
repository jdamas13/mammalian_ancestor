#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw(min max);
use Tie::RangeHash;
use FindBin qw($Bin);

my $data1_dir = shift; # RACA_APCF.500K (bigger blocks); 
my $data2_dir = shift; # RACA_APCF.300K (smaller blocks); 
my $out_dir = shift;

system("mkdir -p $out_dir");

# input files
my $blist_f1 = "$data1_dir/SFs/block_list.txt";
my $apcf_f1 = "$data1_dir/Ancestor.APCF";
my $blist_f2 = "$data2_dir/SFs/block_list.txt";
my $apcf_f2 = "$data2_dir/Ancestor.APCF";

# output files
my $blist_out_f = "$out_dir/new_block_list.txt"; 
my $bid1map_f = "$out_dir/bid1ToNewBid.txt";
my $bid2map_f = "$out_dir/bid2ToNewBid.txt";
my $apcf_out_f1 = "$out_dir/Ancestor1.APCF";
my $apcf_out_f2 = "$out_dir/Ancestor2.APCF";
my $apcf_aln_f = "$out_dir/Ancestor.APCF.aln";
my $apcf_indel_diff_f = "$out_dir/APCF.indel.diff";

my $DEBUG = 0;
my $pid = $$;

# read blocks
my %hs_crds1 = ();
my %hs_bid1 = ();
read_blocks($blist_f1, \%hs_crds1, \%hs_bid1);
my %hs_crds2 = ();
my %hs_bid2 = ();
read_blocks($blist_f2, \%hs_crds2, \%hs_bid2);

# create new blocks
my $outbedtmp1 = "/tmp/outbedtmp.$pid.1.bed";
my $outbedtmp2 = "/tmp/outbedtmp.$pid.2.bed";
my $outbedtmp3 = "/tmp/outbedtmp.$pid.3.bed";
`intersectBed -a $blist_f1 -b $blist_f2 > $outbedtmp1`;
`intersectBed -a $blist_f1 -b $blist_f2 -v >> $outbedtmp1`;
`intersectBed -a $blist_f2 -b $blist_f1 -v >> $outbedtmp1`;
`subtractBed -a $blist_f1 -b $blist_f2 >> $outbedtmp1`;
`subtractBed -a $blist_f2 -b $blist_f1 >> $outbedtmp1`;
`sortBed -i $outbedtmp1 > $outbedtmp2`; 

# remove duplicate lines
open(F,"$outbedtmp2");
my @lines = <F>;
close(F);
chomp(@lines);

open(O,">$outbedtmp3");
my $pcrd = "";
for (my $i = 0; $i <= $#lines; $i++) {
	my $line = $lines[$i];
	my ($chr, $start, $end) = split(/\s+/, $line);
	my $crd = "$chr:$start-$end";

	if ($crd ne $pcrd) {
		print O "$line\n";
	}

	$pcrd = $crd;	
}
close(O);

# assign new bid
my %hs_bid_merged = ();
my $new_bid = 1;
open(F,"$outbedtmp3");
while(<F>) {
	chomp;
	my ($chr, $start, $end) = split(/\s+/);
	$hs_bid_merged{$chr}{$start} = $new_bid++;	
} 
close(F);

my $max_bid = $new_bid - 1;
my %hs_crds_merged_rev = ();
my %hs_crds_merged = ();

open(O,">$blist_out_f");
open(F,"$outbedtmp3");
while(<F>) {
	chomp;
	my ($chr, $start, $end) = split(/\s+/);
	my $bid = $hs_bid_merged{$chr}{$start};	
	print O "$chr\t$start\t$end\t+\t$bid\n";

	$hs_crds_merged{$chr}{$start} = $end;
	$hs_crds_merged_rev{$bid} = "$chr:$start-$end";
}
close(F);
close(O);

`rm -f $outbedtmp1 $outbedtmp2 $outbedtmp3`;

# create maps to new bid
my %hs_bid1ToNewBid = ();
my %hs_bid2ToNewBid = ();
foreach my $chr (sort chr_sort keys %hs_crds_merged) {
	my $href = $hs_crds_merged{$chr};
	my $rhash = Tie::RangeHash->new({Type=>Tie::RangeHash::TYPE_NUMBER});

	foreach my $start (sort {$a<=>$b} keys %$href) {
		my $bid = $hs_bid_merged{$chr}{$start};
		my $end = $$href{$start};

		# convert to 1-based start
		$start++;
		$rhash->add("$start,$end", $bid);
	}

	# for blocks1
	my $href_bid1 = $hs_bid1{$chr};
	my $href_crds1 = $hs_crds1{$chr};
	foreach my $start (sort {$a<=>$b} keys %$href_crds1) {
		my $end = $$href_crds1{$start};
		my $bid = $$href_bid1{$start};
		# convert to 1-based start
		$start++;		
		my @newbids = $rhash->fetch_overlap("$start,$end");
		$hs_bid1ToNewBid{$bid} = join(" ",@newbids);	
	}
	
	# for blocks2
	my $href_bid2 = $hs_bid2{$chr};
	my $href_crds2 = $hs_crds2{$chr};
	foreach my $start (sort {$a<=>$b} keys %$href_crds2) {
		my $end = $$href_crds2{$start};
		my $bid = $$href_bid2{$start};

		# convert to 1-based start
		$start++;		
		my @newbids = $rhash->fetch_overlap("$start,$end");
		$hs_bid2ToNewBid{$bid} = join(" ",@newbids);	
	}

}

open(O1,">$bid1map_f");
open(O2,">$bid2map_f");
foreach my $bid (sort {$a<=>$b} keys %hs_bid1ToNewBid) {
	my $newbid = $hs_bid1ToNewBid{$bid};
	print O1 "$bid\t$newbid\n";	
}
		
foreach my $bid (sort {$a<=>$b} keys %hs_bid2ToNewBid) {
	my $newbid = $hs_bid2ToNewBid{$bid};
	print O2 "$bid\t$newbid\n";	
}
close(O1);
close(O2);

# convert APCF files
convert_apcf($apcf_f1, $apcf_out_f1, \%hs_bid1ToNewBid, $max_bid);
convert_apcf($apcf_f2, $apcf_out_f2, \%hs_bid2ToNewBid, $max_bid);

# align two apcfs based on reference bids
my %hs_apcfToRef1 = ();
read_apcf($apcf_out_f1, \%hs_apcfToRef1);
my %hs_apcfToRef2 = ();
read_apcf($apcf_out_f2, \%hs_apcfToRef2);

open(O,">$apcf_aln_f");
for (my $bid = 1; $bid <= $max_bid; $bid++) {
	my $apcf_id1 = $hs_apcfToRef1{$bid};
	if (!defined($apcf_id1)) { $apcf_id1 = "0:0"; }
	my $apcf_id2 = $hs_apcfToRef2{$bid};
	if (!defined($apcf_id2)) { $apcf_id2 = "0:0"; }

	my $crds = $hs_crds_merged_rev{$bid};

	print O "$bid\t$crds\t$apcf_id1\t$apcf_id2\n";
}
close(O);

#####
my @refchrs = ();
my %hs_refchrs = ();
open(F,"$apcf_aln_f");
while(<F>) {
	chomp;
	my ($bid, $refchr, $apcf1, $apcf2) = split(/\s+/);
	push(@refchrs, $refchr);
	$hs_refchrs{$bid} = $refchr;
}
close(F);

# identify indel operations btw two apcfs
my %type_cnt = ();
my %type_len = ();
my %indel_bids = ();
my @indel_lines = `grep "[[:space:]]0:0[[:space:]]" $apcf_aln_f`;
chomp(@indel_lines);
my ($i, $pi, $pchr, $pbid, $ptype) = (0, 0, "", 0, "");
my @bids = ();

open(my $O,">$apcf_indel_diff_f");
for (; $i <= $#indel_lines; $i++) {
	my ($bid, $crds, $ann1, $ann2) = split(/\s+/, $indel_lines[$i]);
	$crds =~ /(\S+):(\S+)\-(\S+)/;
	my ($chr, $start, $end) = ($1, $2, $3);

	my $type = "";
	if ($ann1 eq "0:0" && $ann2 ne "0:0") {
		$type = "Insertion";
	} elsif ($ann1 ne "0:0" && $ann2 eq "0:0") {
		$type = "Deletion";
	} else { 
		print STDERR "==>".$indel_lines[$i]."\n";
		die; 
	}

	if ($i == 0) {
		($pi, $pchr, $pbid, $ptype) = ($i, $chr, $bid, $type);	
		push(@bids, $bid);
		next;
	} 

	if ($type ne $ptype || abs($pbid-$bid) > 1 || $pchr ne $chr || $ptype ne $type) {
		my $bsize = get_size($bids[0]-1, $bids[-1]-1, \@refchrs);
        printNstore($O, $ptype, $bids[0], $bids[-1], $bsize, \%type_cnt, \%type_len, \%indel_bids);

		@bids = ();
		$pi = $i;	
	}
	
	push(@bids, $bid);	
	($pchr, $pbid, $ptype) = ($chr, $bid, $type);	
}
		
my $bsize = get_size($bids[0]-1, $bids[-1]-1, \@refchrs);
printNstore($O, $ptype, $bids[0], $bids[-1], $bsize, \%type_cnt, \%type_len, \%indel_bids);

print $O "\n";
foreach my $type (sort keys %type_cnt) {
	my $cnt = $type_cnt{$type};
	my $len = $type_len{$type};
	print $O "$type\t$cnt\t$len\n";
}
close($O);

# create apcf files only using common bids
my %hs_commonApcfToRef2 = ();
read_apcf_only_common_bids($apcf_out_f2, \%hs_commonApcfToRef2, \%indel_bids);

my $headerline = "";
open(O,">$out_dir/Ancestor.APCF.map");
open(F,"$apcf_out_f1");
while(<F>) {
	chomp;
	if ($_ =~ /^>/) {
		print O "$_\n";
	} elsif($_ =~ /^#/) {
		$headerline = $_;
	} else {
		my $finalstr = "";
		my @ar = split(/\s+/);
		pop(@ar);
		for (my $i = 0; $i <= $#ar; $i++) {
			my $bid = $ar[$i];
			if (defined($indel_bids{abs($bid)})) { 
				next; 
			}

			my $tstr = $hs_commonApcfToRef2{abs($bid)};
			if (!defined($tstr)) { next; }

			if ($bid < 0) {
				my @tmpar = split(/:/, $tstr);
				my $newaid = "";
				if ($tmpar[0] =~ /^\-/) {
					$newaid = substr($tmpar[0], 1);
				} else {
					$newaid = sprintf("-%s", $tmpar[0]);
				}
				$tstr = sprintf("%s:%d", $newaid, $tmpar[1]);
			}

			$finalstr .= "$bid:$tstr ";
		}
		if ($finalstr ne "") {
			print O "$headerline\n";
			print O "$finalstr\$\n";
		}
	}	
}
close(F);
close(O);

# classify events
my $apcfid = 0;
my %type_others = ();
open(O,">$out_dir/APCF.other.diff");
open(F,"$out_dir/Ancestor.APCF.map");
while(<F>) {
	chomp;
	if ($_ =~ /^>/) { next; }
	if ($_ =~ /^# APCF (\S+)/) {
		$apcfid = $1;
		next;	
	}

	my @ar = split(/\s+/);
	pop(@ar);

	# find breakpoints
	my @bks_boundaries = ();	# i-1 : i
	my ($papcf, $porder, $pbid) = (0,0,0);
	for (my $i = 0; $i <= $#ar; $i++) {
		my $bstr = $ar[$i];
		$bstr =~ /(\S+):(\S+):(\S+)/;
		my ($bid, $apcf, $order) = ($1, $2, $3);

		if ($i > 0 && ($apcf ne $papcf || abs($order-$porder) > 1)) {
			my $prefstr = $hs_refchrs{abs($pbid)};
			my $pdir = "+";
			if ($pbid < 0) { $pdir = "-"; }
			my $refstr = $hs_refchrs{abs($bid)};
			my $dir = "+";
			if ($bid < 0) { $dir = "-"; }

			print O "Breakpoint $apcfid $papcf:$porder vs $apcf:$order\t$prefstr $pdir vs $refstr $dir\n";	
			push(@bks_boundaries, "$papcf:$porder $apcf:$order");
		}

		($papcf, $porder, $pbid) = ($apcf, $order, $bid);
	}

	for (my $i = 0; $i < $#bks_boundaries; $i += 2) {
		$bks_boundaries[$i] =~ /(\S+):(\S+) (\S+):(\S+)/;
		my ($apcf1, $order1, $apcf2, $order2) = ($1,$2,$3,$4);
		$bks_boundaries[$i+1] =~ /(\S+):(\S+) (\S+):(\S+)/;
		my ($apcf3, $order3, $apcf4, $order4) = ($1,$2,$3,$4);

		my $etype = "";
		if (abs_equal($apcf1, $apcf3) && abs_equal($apcf2, $apcf4)) {
			if (opposite_sign($apcf1, $apcf3) && abs($order1-$order3) == 1 && opposite_sign($apcf2, $apcf4) && abs($order2-$order4) == 1) {
				# inversion
				$etype = "Inversion";
			} else {
				# transposition
				$etype = "Other";
			}	

		} elsif (!abs_equal($apcf1, $apcf3) && !abs_equal($apcf2, $apcf4)) {
			# translocation
			$etype = "Other";
		} else {
			# complex
			$etype = "Other";
		}

		printf O "%-10s\t...%8s] [%-8s ... %8s] [%-8s ...\n", $etype, "$apcf1:$order1", "$apcf2:$order2", "$apcf3:$order3", "$apcf4:$order4";

		if (defined($type_others{$etype})) {
			$type_others{$etype}++;
		} else {
			$type_others{$etype} = 1;
		}
	} 
}
close(F);

print O "\n";
foreach my $etype (sort keys %type_others) {
	my $cnt = $type_others{$etype};
	print O "$etype\t$cnt\n";
}

close(O);

`perl $Bin/apcfs_agreement.pl $apcf_out_f1 $apcf_out_f2 > $out_dir/APCF_agr.txt`;


###############################################################
sub read_blocks {
	my ($f, $href_crds, $href_bid) = @_;
	
	open(F,"$f");
	while(<F>) {
		chomp;
		my ($chr, $start, $end, $dir, $bid) = split(/\s+/);
		$$href_crds{$chr}{$start} = $end;
		$$href_bid{$chr}{$start} = $bid;	
	}
	close(F);
}

sub chr_sort {
    $a =~ /chr(\S+)/;
    my $chr1 = $1;
    $b =~ /chr(\S+)/;
    my $chr2 = $1;

	if (!defined($chr1) || !defined($chr2)) {
		return ($a cmp $b);
	}

    return 0 if ($chr1 eq $chr2);
    return 1 if ($chr1 eq "X" && $chr2 ne "X");
    return -1 if ($chr1 ne "X" && $chr2 eq "X");

    if ($chr1 =~ /^\d+$/ && $chr2 =~ /^\d+$/) {
        return -1 if ($chr1 < $chr2);
        return 1 if ($chr1 > $chr2);
        return 0;
    }
    if ($chr1 =~ /^\d+$/ && $chr2 !~ /^\d+$/) {
        $chr2 =~ /(\d+)\D+/;
        my $chr2num = $1;
        return -1 if ($chr1 < $chr2num);
        return 1 if ($chr1 > $chr2num);
        return 0;
    }
    if ($chr1 !~ /^\d+$/ && $chr2 =~ /^\d+$/) {
        $chr1 =~ /(\d+)\D+/;
        my $chr1num = $1;
        return -1 if ($chr1num < $chr2);
        return 1 if ($chr1num > $chr2);
        return 0;
    }
    if ($chr1 !~ /^\d+$/ && $chr2 !~ /^\d+$/) {
        $chr1 =~ /(\d+)(\D+)/;
        my $chr1num = $1;
        my $chr1chr = $2;
        $chr2 =~ /(\d+)(\D+)/;
        my $chr2num = $1;
        my $chr2chr = $2;
        return -1 if ($chr1num < $chr2num);
        return 1 if ($chr1num > $chr2num);

        return -1 if ($chr1chr lt $chr2chr);
        return 1 if ($chr1chr gt $chr2chr);
        return 0;
    }
}

sub convert_apcf {
	my ($apcf_f, $apcf_out_f, $href_bidToNewBid, $max_bid) = @_;

	open(F,"$apcf_f");
	open(O,">$apcf_out_f");
	my $chr = "";
	while(<F>) {
		chomp;
		if ($_ =~ /^>/ ) { 
			print O ">ANCESTOR\t$max_bid\n";
		} elsif ($_ =~ /^#/) {
			print O "$_\n";
		} else {
			my @ar = split(/\s+/);
			pop(@ar);
			for (my $i = 0; $i <= $#ar; $i++) {
				my $bid = $ar[$i];
				my $newbids = $$href_bidToNewBid{abs($bid)};

				if ($bid < 0) {
					my @tmpar = ();
					my @bids = split(/\s+/, $newbids);
					for (my $j = $#bids; $j >= 0; $j--) {
						my $newbid = $bids[$j];
						push(@tmpar, -1*$newbid);
					}
					$newbids = join(" ", @tmpar);
				}

				print O "$newbids ";
			}
			print O "\$\n";                                       
		}                                                         
	}                                                             
	close(O);                                                     
	close(F);                
}

sub read_apcf {
	my ($apcf_f, $href_apcfToRef) = @_;

	my $apcf_id = -1;
	open(F,"$apcf_f");
	while(<F>) {
		chomp;
		if ($_ =~ /^>/) {
			next;
		} elsif ($_ =~ /^# APCF (\S+)/) {
			$apcf_id = $1;
		} else {
			my @ar = split(/\s+/);
			pop(@ar);
			for (my $i = 0; $i <= $#ar; $i++) {
				my $bid = $ar[$i];
				my $bp = $i+1;
				my $val = "$apcf_id:$bp";
				if ($bid < 0) {
					$val = sprintf("-%s:%d", $apcf_id, $bp);
				}
				$$href_apcfToRef{abs($bid)} = $val; 
			}
		}

	}
	close(F);
}

sub read_apcf_only_common_bids {
	my ($apcf_f, $href_apcfToRef, $href_indelbids) = @_;

	my $apcf_id = -1;
	open(F,"$apcf_f");
	while(<F>) {
		chomp;
		if ($_ =~ /^>/) {
			next;
		} elsif ($_ =~ /^# APCF (\S+)/) {
			$apcf_id = $1;
		} else {
			my @ar = split(/\s+/);
			pop(@ar);
			my $bp = 1;
			for (my $i = 0; $i <= $#ar; $i++) {
				my $bid = $ar[$i];
				if (defined($$href_indelbids{abs($bid)})) { 
					next; 
				}

				my $val = "$apcf_id:$bp";
				if ($bid < 0) {
					$val = sprintf("-%s:%d", $apcf_id, $bp);
				} 
				print "$apcf_id\t$bp\t$bid\n";

				$$href_apcfToRef{abs($bid)} = $val; 
				$bp++;
			}
		}

	}
	close(F);
}
sub get_size {
	my ($si, $ei, $refar) = @_;

	my $sum = 0;
	for (my $j = $si; $j <= $ei; $j++) {
		my $chrstr = $$refar[$j];
		$chrstr =~ /(\S+):(\S+)\-(\S+)/;
		my ($chr, $start, $end) = ($1, $2, $3);
		$sum += ($end - $start);	
	}

	return $sum;
}

sub printNstore {
	my ($fh, $type, $s, $e, $len, $href_cnt, $href_len, $href_indelbids) = @_;

	print $fh "$type\t",$s,"\t",$e,"\t$len\n";

	for (my $p = $s; $p <= $e; $p++) {
		$$href_indelbids{$p} = 1;
	}

    if (defined($$href_cnt{$type})) {
		$$href_cnt{$type}++;
        $$href_len{$type} += $len;
    } else {
		$$href_cnt{$type} = 1;
        $$href_len{$type} = $len;
    }
}

sub abs_equal {
	my $aid1 = shift;
	my $aid2 = shift;

	my $newaid1 = $aid1;
	if ($aid1 =~ /^\-/) {
		$newaid1 = substr($aid1, 1);
	}
	
	my $newaid2 = $aid2;
	if ($aid2 =~ /^\-/) {
		$newaid2 = substr($aid2, 1);
	}

	if ($newaid1 eq $newaid2) { return 1; }
	else { return 0; }
}

sub opposite_sign {
	my $aid1 = shift;
	my $aid2 = shift;

	if ($aid1 =~ /^\-/ && $aid2 !~ /^\-/) {
		my $newaid1 = substr($aid1, 1);
		if ($newaid1 eq $aid2) { return 1; }
	} elsif ($aid1 !~ /^\-/ && $aid2 =~ /^\-/) {
		my $newaid2 = substr($aid2, 1);
		if ($newaid2 eq $aid1) { return 1; }
	} else {
		return 0;
	}

	return 0;
}
