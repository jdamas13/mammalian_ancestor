#!/usr/bin/perl

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

my $map_f = shift;

open(F,"$map_f");
my @lines = <F>;
close(F);
chomp(@lines);

my %hs_out = ();
my %hs_splits = ();
my %hs_starts = ();
my %hs_ends = ();
my $paid1 = "";
my $aid2str = "";
for (my $i = 0; $i < $#lines; $i+=4) {
	my $line1 = $lines[$i+1];
	my $line2 = $lines[$i+2];

	$line1 =~ /\S+\.(\S+):/;
	my $aid1 = $1;
	$line2 =~ /\S+\.(\S+):(\S+)\s+\.\.\.\s+\S+\s+(\S+)/;
	my ($aid2, $start2, $length) = ($1, $2, $3);

	$hs_starts{remove_sign($aid2)}{$start2} = 1;
	$hs_ends{remove_sign($aid2)}{$start2} = $length;

	if ($paid1 eq "") {
		$paid1 = $aid1;
		$aid2str = "$aid2:$start2 ";	
	} else {
		if ($paid1 eq $aid1) {
			$aid2str .= "$aid2:$start2 ";
		} else {
			$hs_out{$paid1} = $aid2str;

			my @ar = split(/\s+/, $aid2str);
			foreach my $idstr (@ar) {
				my ($id, $istart) = split(/:/, $idstr);
				my $abs_id = remove_sign($id);
				if (defined($hs_splits{$abs_id})) {
					$hs_splits{$abs_id}++;
				} else {
					$hs_splits{$abs_id} = 1;
				}
			}	
			$paid1 = $aid1;
			$aid2str = "$aid2:$start2 ";	
		}
	}
}
			
$hs_out{$paid1} = $aid2str;

my @ar = split(/\s+/, $aid2str);
foreach my $idstr (@ar) {
	my ($id, $istart) = split(/:/, $idstr);
	my $abs_id = remove_sign($id);
	if (defined($hs_splits{$abs_id})) {
		$hs_splits{$abs_id}++;
	} else {
		$hs_splits{$abs_id} = 1;
	}
}	

my %hs_max = ();
my @tmpkeys = keys %hs_splits;
foreach my $tkey (@tmpkeys) {
	my $scnt = $hs_splits{$tkey};
	if ($scnt == 1) {
		delete $hs_splits{$tkey};
	} else {
		$hs_max{$tkey} = $scnt;
	}
}

$hs_out{$paid1} = $aid2str;

my %hs_block_lens = ();

foreach my $paid (sort paid_sort keys %hs_out) {
	my $str = $hs_out{$paid};
	print "$paid\t";

	my @ar = split(/\s+/, $str);
	foreach my $bidstr (@ar) {
		my ($bid, $start) = split(/:/, $bidstr);
		my $scnt = $hs_splits{remove_sign($bid)};
		my $length = $hs_ends{remove_sign($bid)}{$start};
		if (defined($scnt)) {
			my $rhs_starts = $hs_starts{remove_sign($bid)};
			my @starts = sort {$a<=>$b} keys %$rhs_starts;
			my $spos = 0;
			foreach my $ostart (@starts) {
				if ($ostart == $start) { last; }
				$spos++;
			}			

			my $newbid = "$bid" . chr(97 + $spos);
			print "$newbid ";
			$hs_block_lens{$newbid} = $length;
			$hs_splits{remove_sign($bid)}--;
		} else {
			print "$bid ";
			$hs_block_lens{$bid} = $length;
		}
	}
	print "\n"; 
}

print "\n";                                                   
foreach my $bid (sort keys %hs_block_lens) {                  
    my $len = $hs_block_lens{$bid};                           
    print "$bid\t$len\n";                                     
}  


##########

sub remove_sign {
	my $aid = shift;

	my $newaid = $aid;
	if ($aid =~ /^\-/) {
		$newaid = substr($aid, 1);
	}

	return $newaid;
}

sub paid_sort {
	my $aid = $a;
	my $bid = $b;

	if (looks_like_number($aid) && looks_like_number($bid)) {
		return ($aid <=> $bid);
	} elsif (looks_like_number($aid)) {
		return -1;
	} elsif (looks_like_number($bid)) {
		return 1;
	} else {
		return ($aid cmp $bid);
	}
}
