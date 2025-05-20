#!/usr/bin/perl

use strict;
use warnings;

my $parent_f = shift;
my $child_f = shift;

my @lines1 = ();
my %bid_count = ();
open(F,$parent_f);
while(<F>) {
	chomp;
	if ($_ =~ /^>/ || $_ =~ /^#/) { next; }
	push(@lines1, $_);
	
	my @ar = split(/\s+/);
	pop(@ar);	# remove $
	for (my $i = 0; $i <= $#ar; $i++) {
		$bid_count{abs($ar[$i])} = 0;
	}	
}
close(F);

my @lines2 = ();
open(F, $child_f);
while(<F>) {
	chomp;
	
	if ($_ =~ /^>/ || $_ =~ /^#/) { next; }
	push(@lines2, $_);
	
	my @ar = split(/\s+/);
	pop(@ar);	# remove $
	for (my $i = 0; $i <= $#ar; $i++) {
		my $abid = abs($ar[$i]);
		if (defined($bid_count{$abid})) {
			$bid_count{abs($ar[$i])}++;
		}
	}	
}
close(F);

# remove uncommon bids
my @abids = keys %bid_count;
foreach my $abid (@abids) {
	my $value = $bid_count{$abid};
	if ($value == 0) {
		delete $bid_count{$abid};	
	}
}

# collect adjacencies by only using common bids
my %bid_adjs1 = ();
my $total1 = 0;
foreach my $line (@lines1) {
	my @ar_org = split(/\s+/, $line);
	pop(@ar_org);	# remove $

	my @ar_new = ();
	foreach my $bid (@ar_org) {
		my $abid = abs($bid);
		if (defined($bid_count{abs($bid)})) {
			push(@ar_new, $bid);
		}
	}

	if (scalar(@ar_new) > 1) {
		for (my $i = 0; $i < $#ar_new; $i++) {
			my $bid1 = $ar_new[$i];
			my $bid2 = $ar_new[$i+1];
			$bid_adjs1{$bid1} = $bid2;
			$bid_adjs1{-1*$bid2} = -1*$bid1;
			$total1++;
		} 
	}
}

my $total2 = 0;
my $common = 0;
foreach my $line (@lines2) {
	my @ar_org = split(/\s+/, $line);
	pop(@ar_org);	# remove $

	my @ar_new = ();
	foreach my $bid (@ar_org) {
		my $abid = abs($bid);
		if (defined($bid_count{abs($bid)})) {
			push(@ar_new, $bid);
		}
	}

	if (scalar(@ar_new) > 1) {
		for (my $i = 0; $i < $#ar_new; $i++) {
			my $bid1 = $ar_new[$i];
			my $bid2 = $ar_new[$i+1];

			my $tbid2 = $bid_adjs1{$bid1};
			if (defined($tbid2) && $tbid2 == $bid2) {
				$common++;
			}

			$total2++;
		} 
	}
}

my $frac1 = $common/$total1;
my $frac2 = $common/$total2;
printf("ParentTotal %d ChildTotal %d Common %d Common/ParentTotal %.4f Common/ChildTotal %.4f\n", $total1, $total2, $common, $frac1, $frac2);
