#!/usr/bin/perl

use strict;
use warnings;

my $aname1 = shift;
my $aname2 = shift;
my $data_dir = shift;

my $aln_f = "$data_dir/Ancestor.APCF.aln";
my $anc1_f = "$data_dir/Ancestor1.APCF";
my $anc2_f = "$data_dir/Ancestor2.APCF";

# read blocks
my %hs_blocks_len = ();
my %hs_ords = ();
open(F, "$aln_f");
while(<F>) {
	chomp;
	my ($bid, $crd, $ord1, $ord2) = split(/\s+/);
	$crd =~ /(\S+):(\S+)\-(\S+)/;
	my ($chr, $start, $end) = ($1, $2, $3);
	$hs_blocks_len{$bid} = $end - $start;	

	if ($ord1 ne "0:0" && $ord2 ne "0:0") {
		$hs_ords{$ord1} = $ord2;
	}
}
close(F);

# read apcf files
my %hs_map1 = ();
read_apcfile($anc1_f, \%hs_map1); 
my %hs_map2 = ();
read_apcfile($anc2_f, \%hs_map2); 

# create map file
my %hs_finalmaps = ();
foreach my $key1 (keys %hs_ords) {
	my $key2 = $hs_ords{$key1};
	my ($dir1, $dir2) = ("+", "+");

	my ($aid1, $ord1) = (0, 0);
	if ($key1 =~ /^\-/) { 
		my $str = substr($key1, 1);
		$str =~ /(\S+):(\S+)/;
		($aid1, $ord1) = ($1, $2);
		$dir1 = "-"; 
	} else {
		$key1 =~ /(\S+):(\S+)/;
		($aid1, $ord1) = ($1, $2);	
	}	
	
	my ($aid2, $ord2) = (0, 0);
	if ($key2 =~ /^\-/) { 
		my $str = substr($key2, 1);
		$str =~ /(\S+):(\S+)/;
		($aid2, $ord2) = ($1, $2);
		$dir2 = "-"; 
	} else {
		$key2 =~ /(\S+):(\S+)/;
		($aid2, $ord2) = ($1, $2);	
	}

	my $astr1 = $hs_map1{$aid1}{$ord1};	
	my $astr2 = $hs_map2{$aid2}{$ord2};
	my $finaldir = "+";
	if ($dir1 ne $dir2) { $finaldir = "-"; }
	my $finalout = "$aname1.$astr1 +\n$aname2.$astr2 $finaldir";

	$astr1 =~ /(\S+):(\S+)\-(\S+)/;
	my ($chr1, $start1, $end1) = ($1, $2, $3);
	$hs_finalmaps{$chr1}{$start1} = $finalout;	
}

# sort final output
my $cnt = 1;
foreach my $chr (sort achr_sort keys %hs_finalmaps) {
	my $rhs = $hs_finalmaps{$chr};
	foreach my $start (sort {$a<=>$b} keys %$rhs) {
		my $out = $$rhs{$start};

		print ">$cnt\n";
		print "$out\n\n";
		$cnt++;
	}
}

##########
sub read_apcfile {
	my $anc_f = shift;
	my $rhs_map = shift;

	my $aid = -1;
	open(F, "$anc_f");
	while(<F>) {
		chomp;
		if ($_ =~ /^>/) { 
			next; 
		} elsif ($_ =~ /# APCF (\S+)/) {
			$aid = $1;
		} else {
			my @bids = split(/\s+/);
			pop(@bids);
			my $totalsize = 0;
			my $order = 1;
			for (my $i = 0; $i <= $#bids; $i++) {
				my $bid = $bids[$i];
				my $len = $hs_blocks_len{abs($bid)};
				my ($start, $end) = ($totalsize, $totalsize + $len);

				my $acrd = "$aid:$start-$end";			
				$$rhs_map{$aid}{$order} = $acrd;

				$totalsize += $len;
				$order++;
			}
		}	
	}
	close(F);
} 

sub achr_sort {
	my $aid = $a;
    my $bid = $b;

    if ($aid =~ /^X/ && $bid =~ /^X/) {
        if ($aid =~ /^X(\d+)/) {
            my $anum = $1;
            my $bnum = substr($bid, 1);
            return ($anum <=> $bnum);
        } else {
            return 0;
        }
    } elsif ($aid !~ /^X/ && $bid =~ /^X/) {
        return -1;
    } elsif ($aid =~ /^X/ && $bid !~ /^X/) {
        return 1;
    } else {
        return ($aid <=> $bid);
    }
}
