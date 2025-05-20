#!/usr/bin/perl

use strict;
use warnings;

my $in = shift; #Jaebum's database file
my $ref = shift; #Reference name
my $res = shift; #Resolution suffix
my $out = shift; #Output file using cattle as reference
my $out2 = shift; #Otuput file using Anc as reference

open IN, $in or die "Can't open the input\n";
open OUT,">$out" or die "Can't create the output file\n";
open OUT1,">$out\_EBA" or die "Can't create the output file\n";
open OUT2, ">$out2" or die "Can't create the output file for ancestor\n";
open A, ">otherSps_${ref}${res}.txt" or die "Can't create the other outputs for ancestor\n";

while (<IN>) {
	chomp $_;
	if ($_=~/insert into CONSENSUS.*\'$ref\'.*/) {
		my @tmp = split /\(/;
		my @tmp1 = split /\,/, $tmp[1];
		my $chrAnc = $tmp1[1]=~s/\'//g;
		my $chrRef = $tmp1[8]=~s/\'//g;
		print OUT "$ref\:$res\,$tmp1[8]\,$tmp1[4]\,$tmp1[5]\,$tmp1[2]\,$tmp1[3]\,$tmp1[6]\,$tmp1[0]\,$tmp1[1]\,$tmp1[1]\n";
		print OUT1 "$ref\:$res\t$tmp1[8]\t$tmp1[4]\t$tmp1[5]\t$tmp1[1]\t$tmp1[2]\t$tmp1[3]\t$tmp1[6]\t$tmp1[0]\n";
		print OUT2 "$tmp1[0]\t$tmp1[1]\t$tmp1[2]\t$tmp1[3]\t$tmp1[8]\t$tmp1[4]\t$tmp1[5]\t$tmp1[6]\t$ref\n";
	}
	elsif ($_=~/insert into CONSENSUS.*/) {
		my @tmp = split /\(/;
		my @tmp1 = split /\,/, $tmp[1];
		my ($sps) = $tmp1[7] =~/(.*)/;
		print A "$tmp1[0]\t$tmp1[1]\t$tmp1[2]\t$tmp1[3]\t$tmp1[8]\t$tmp1[4]\t$tmp1[5]\t$tmp1[6]\t$sps\n";
	}
}


