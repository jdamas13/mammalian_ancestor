#!/usr/bin/perl

use strict;
use warnings;

my $anc1name = shift;
my $anc2name = shift;
my $apcf_f = shift;
my $block_f = shift;
my $idmap_f = shift;
my $out_f = shift;
my $bsize_f = shift;

my %hs_blocksize = ();
open(F,"$block_f");
while(<F>) {
	chomp;
	my ($chr, $start, $end, $dir, $id) = split(/\s+/);
	$hs_blocksize{$id} = $end - $start;
}
close(F);

my %hs_idmap = ();
open(F,"$idmap_f");
while(<F>) {
	chomp;
	my ($aid, $newbid, $orgbid) = split(/\s+/);
	$hs_idmap{$aid}{$newbid} = abs($orgbid);
}
close(F);

open(O1, ">$out_f");
open(O2, ">$bsize_f");

my $aid1 = -1;
my $bcnt = 1;
open(F,"$apcf_f");
while(<F>) {
	chomp;
	if (length($_) == 0 || $_ =~ /^>/) { next; }

	if ($_ =~ /^# APCF (\S+)/) {
		$aid1 = $1;
	} else {
		my @ar = split(/\s+/);
		pop(@ar);

		my ($bid1_start, $bid2_start) = (0,0);
		my ($pbid1, $paid2, $pbid2) = (0,0,0);
		for (my $i = 0; $i <= $#ar; $i++) {
			$ar[$i] =~ /(\S+):(\S+):(\S+)/;
			my ($bid1, $aid2, $bid2) = ($1, $2, $3);

			if ($pbid1 == 0) {
				($bid1_start, $bid2_start) = ($bid1, $bid2);
				($pbid1, $paid2, $pbid2) = ($bid1, $aid2, $bid2);
			} else {
				if ($paid2 ne $aid2) {
					print O1 ">$bcnt\n";
					print O1 "$anc1name.$aid1:$bid1_start ... $pbid1\n";

					my $totallen = 0;
					my ($newstart, $newend) = ($bid2_start, $pbid2);
					if ($bid2_start > $pbid2) {
						($newstart, $newend) = ($pbid2, $bid2_start);
					}
					for (my $p = $newstart; $p <= $newend; $p++) {
						my $key = $paid2;
						if ($paid2 =~ /^\-(\S+)/) {
							$key = $1;
						}
						my $orgbid = $hs_idmap{$key}{abs($p)};
						my $len = $hs_blocksize{$orgbid};
						$totallen += $len;
					}

						print O1 "$anc2name.$paid2:$bid2_start ... $pbid2\t$totallen\n\n";					
						print O2 "$totallen\n";
				
					$bcnt++;	
					($bid1_start, $bid2_start) = ($bid1,$bid2);
					($pbid1, $paid2, $pbid2) = ($bid1, $aid2, $bid2);
				} else {
					if ($aid2 !~ /^\-/) {
						if ($pbid2 + 1 == $bid2) {
							# 3:4 3:5 
							$pbid2 = $bid2;
							$pbid1 = $bid1;
						} else {
							print O1 ">$bcnt\n";
							print O1 "$anc1name.$aid1:$bid1_start ... $pbid1\n";
					
							my $totallen = 0;
							my ($newstart, $newend) = ($bid2_start, $pbid2);
							if ($bid2_start > $pbid2) {
								($newstart, $newend) = ($pbid2, $bid2_start);
							}
							for (my $p = $newstart; $p <= $newend; $p++) {
								my $key = $paid2;
								if ($paid2 =~ /^\-(\S+)/) {
									$key = $1;
								}
								my $orgbid = $hs_idmap{$key}{abs($p)};
								my $len = $hs_blocksize{$orgbid};
								$totallen += $len;
							}
					
								print O1 "$anc2name.$paid2:$bid2_start ... $pbid2\t$totallen\n\n";					
								print O2 "$totallen\n";
							$bcnt++;	
							($bid1_start, $bid2_start) = ($bid1,$bid2);
							($pbid1, $paid2, $pbid2) = ($bid1, $aid2, $bid2);
						}
					} else {
						if ($pbid2 - 1 == $bid2) {
							# -3:5 -3:4
							$pbid2 = $bid2;
							$pbid1 = $bid1;
						} else {
							print O1 ">$bcnt\n";
							print O1 "$anc1name.$aid1:$bid1_start ... $pbid1\n";
							
					
							my $totallen = 0;
							my ($newstart, $newend) = ($bid2_start, $pbid2);
							if ($bid2_start > $pbid2) {
								($newstart, $newend) = ($pbid2, $bid2_start);
							}
							for (my $p = $newstart; $p <= $newend; $p++) {
								my $key = $paid2;
								if ($paid2 =~ /^\-(\S+)/) {
									$key = $1;
								}
								my $orgbid = $hs_idmap{$key}{abs($p)};
								my $len = $hs_blocksize{$orgbid};
								$totallen += $len;
							}
							
								print O1 "$anc2name.$paid2:$bid2_start ... $pbid2\t$totallen\n\n";					
								print O2 "$totallen\n";
							$bcnt++;	
							($bid1_start, $bid2_start) = ($bid1,$bid2);
							($pbid1, $paid2, $pbid2) = ($bid1, $aid2, $bid2);
						}
					}				
				}	
			}
		} # end of for
							
		print O1 ">$bcnt\n";
		print O1 "$anc1name.$aid1:$bid1_start ... $pbid1\n";
							
		my $totallen = 0;
		my ($newstart, $newend) = ($bid2_start, $pbid2);
		if ($bid2_start > $pbid2) {
			($newstart, $newend) = ($pbid2, $bid2_start);
		}
		for (my $p = $newstart; $p <= $newend; $p++) {
			my $key = $paid2;
			if ($paid2 =~ /^\-(\S+)/) {
				$key = $1;
			}
			my $orgbid = $hs_idmap{$key}{abs($p)};
			my $len = $hs_blocksize{$orgbid};
			$totallen += $len;
		}
							
			print O1 "$anc2name.$paid2:$bid2_start ... $pbid2\t$totallen\n\n";					
			print O2 "$totallen\n";
		$bcnt++;	
	}	
}
close(F);

close(O1);
close(O2);
