#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;

## Removed scaffold IDs adn changes COMP_GEN IDs for EH 

my $input = shift;
my $output = "tmp";

open(OUT, ">$output") or die "Couldn't create $output!\n";
open(IN, $input) or die "Couldn't open $input!\n";
while (<IN>) {
    chomp;
    my $line = $_;
    if ($line eq ""){ next; }
    $line =~ s/,MAM/,1_MAM/g;
    $line =~ s/,THE/,2_THE/g;
    $line =~ s/,EUT/,3_EUT/g;
    $line =~ s/,BOR/,4_BOR/g;
    $line =~ s/,EUA/,5_EUA/g;
    $line =~ s/,EUC/,6_EUC/g;
    $line =~ s/,PMT/,7_PMT/g;
    $line =~ s/,PRT/,8_PRT/g;
    $line =~ s/,LAU/,5_LAU/g;
    $line =~ s/,SCR/,6_SCR/g;
    $line =~ s/,FER/,7_FER/g;
    $line =~ s/,CET/,8_CET/g;
    $line =~ s/,RCT/,9_RCT/g;
    $line =~ s/,RUM/,10_RUM/g;
    $line =~ s/,ATL/,4_ATL/g;
    $line =~ s/,XEN/,5_XEN/g;
    $line =~ s/;HRSCAF=/_/g;
    $line =~ s/(HiC_|Sc9Yeyj_|ScGVr9J_|SUPER_|arrow_|ScNnEE3_|VOSF|ScPeMD7_)//g;
    $line =~ s/__(\d+)_ctgs__length_(\d+)//g;
    $line =~ s/:APCF:(\d+)//g;
    $line =~ s/Chr//g;
    $line =~ s/superctg_//g;
    print OUT "$line\n";
}
close IN;
close OUT;

`mv $output $input`;