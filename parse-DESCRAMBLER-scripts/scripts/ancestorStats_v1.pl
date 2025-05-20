#!usr/bin/perl
use strict;
use warnings;

### IMPORTANT: DOES NOT REMOVE OVERLAPPING REGIONS ###
###     USE ONLY TO GET REFERENCE GENOME STATS     ###

#Calculate stats of ancestor reconstructions from APCF_Taegut.merged.map. Print results to screen. 

my $dir = shift;
my $ref = shift;
my $sizesfile = shift;
#genomeSizes file format
#Taegut 1020453418

my $inCars = "$dir/APCF_${ref}.merged.map";
print $inCars."\n";
#format
#>1
#APCF.1:0-1181636 +
#Taegut.chr1:92930418-96729915 +
my $inADJ = "$dir/Ancestor.ADJS";
my $APCFsize = "$dir/APCF_size.txt";

my $total_lenght = 0;

my $species;
open(IN, $inCars) or die "Couldn't open $inCars!\n";
while (<IN>) {
    chomp;
    next unless /\S/;
    if ($_ !~ /^>/ && $_ !~ /^APCF/ && $_ ne ""){ 
        my ($ref, $chr, $start, $end, $or) = split(/[.:-\s]+/,$_);
        my $len = $end - $start;
        $total_lenght += $len;
        $species = $ref;
        #print "$ref, $chr, $start, $end, $or\n";
    }
}
close IN;
my $noAPCF = 0;
open(S, $APCFsize) or die "Couldn't open $APCFsize!\n";
while (<S>) {
    if ($_ =~ /^total/ or $_ eq ""){next;}
    else{ $noAPCF ++; }
}
close S;

my $sp_length;
open(S, $sizesfile) or die "Couldn't open $sizesfile!\n";
while (<S>) {
    chomp;
    my ($sp, $size) = split(/\s+/,$_);
    if($sp eq $species){ $sp_length = $size; }
}
close S;

my $max = 0;
my $min = 1;
my $sum = 0;
my $cnt = 0;
my $mean = 0;

open(IN2, $inADJ) or die "Couldn't open $inADJ!\n";
while (<IN2>) {
    chomp;
    my($block1, $block2, $score) = split(/\t/, $_);
    if($score > $max){ $max=$score; }
    if($score < $min){ $min=$score; }
    $cnt++;
    $sum=+$score;
}
close IN;
$mean = $sum/$cnt;

#print "Coverages\n";
my $coverage = $total_lenght / $sp_length * 100;
print "No. APCFs = $noAPCF\n";
print "$species = $coverage\n";
print "ADJS\nmin=$min\nmax=$max\nmean=$mean\n";
