#!usr/bin/perl
use strict;
use warnings;

### IMPORTANT: DOES NOT REMOVE OVERLAPPING REGIONS ###
###     USE ONLY TO GET REFERENCE GENOME STATS     ###

#Calculate stats of ancestor reconstructions from APCF_Taegut.merged.map. Print results to screen. 

my $inCars = shift;
print $inCars."\n";
#format
#>1
#APCF.1:0-1181636 +
#Taegut.chr1:92930418-96729915 +

my $sizesfile = shift;
#genomeSizes file format
#Taegut 1020453418

my $total_lenght = 0;
my $species;
open(IN, $inCars) or die "Couldn't open $inCars!\n";
while (<IN>) {
    chomp;
    next unless /\S/;
    if ($_ =~ /^>/ || $_ =~ /^APCF/){ next; }
    else{
        #my
        #print "$_\n";
        my ($ref, $chr, $start, $end, $or) = split(/[.:-\s]/,$_);
        #print "$ref, $chr, $start, $end, $or\n";
        my $len = $end - $start;
        $total_lenght += $len;
        $species = $ref;
        #print "$ref, $chr, $start, $end, $or\n";
    }
}
close IN;

my $sp_length;
open(S, $sizesfile) or die "Couldn't open $sizesfile!\n";
while (<S>) {
    chomp;
    my ($sp, $size) = split(/\s+/,$_);
    if($sp eq $species){ $sp_length = $size; }
}
close S;

#print "Coverages\n";
my $coverage = $total_lenght / $sp_length * 100;
print "$species = $coverage\n";
