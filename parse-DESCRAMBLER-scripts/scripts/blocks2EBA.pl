#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Data::Dumper;

my $dir = shift; #Jaebum's database file
#my $ref = shift; #Reference name i.e. Taegut
my $res = shift; #Resolution short i.e. for 100,000 use 100

my $eba_dir = "/users/jdamas/EBA_v1.45";
my @chrs=("Taegut","Ficalb","pFalcon","rPigeon","Galgal","Melgal","Allsin","Anocar","Mondom");

print Dumper @chrs;
my $prefix = basename($dir);
print $prefix."\n";

my $in = "$dir/APCFs.100K/dbfile.all.txt";
my $out = "$dir/blocks_${prefix}_${res}K_2EBA"; #Output file using ref

print $out."\n";
#FORMAT:
#chicken:100K	1	126798	419477	Scaffold478	325	447801	+	Pygoscelis_adeliae	Scaffolds

open (IN, $in) or die "Couldn't open the $in!\n";
open (OUT,">$out") or die "Can't create the output file\n";

while (<IN>) {
	chomp $_;
	if ($_=~/insert into CONSENSUS.*/) {
		$_ =~ s/'//g;
		my @tmp = split (/\(/, $_);
		my @tmp1 = split (/\,/, $tmp[1]);
		my ($sps) = $tmp1[7] =~/(.*)/;
		if ($tmp1[6] == 1 ){$tmp1[6] = "+1";}
		$tmp1[6] =~ s/1//;
		my $ref_len = $tmp1[2] - $tmp1[1];
		my $tar_len = $tmp1[5] - $tmp1[4];

		my $resolution = $res * 1000;
		if ($ref_len >= $resolution and $tar_len >= $resolution){
			my $type="Scaffolds";
			if (grep( /^$sps$/, @chrs ) ){$type="Chromosomes";}
			print OUT "$prefix\t$tmp1[1]\t$tmp1[2]\t$tmp1[3]\t$tmp1[8]\t$tmp1[4]\t$tmp1[5]\t$tmp1[6]\t$sps\t$type\n";
		}
	}
}
close IN;
close OUT;

`mkdir -p $eba_dir/DESCHRAMBLER/$prefix`; 
`mv $out $eba_dir/DESCHRAMBLER/$prefix`;