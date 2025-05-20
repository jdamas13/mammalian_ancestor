#!usr/bin/perl
use strict;
use warnings;
require "/share/lewinlab/jmdamas/perl_scripts/modules/mergeBlocks.pm";

my $outdir = shift;
my $inferCars = shift;
my $reference = shift;
my $refracaLabel = shift;
my $ancestorLabel = shift;
my $resolution = shift;

my $inferOut1 = "${outdir}/${ancestorLabel}_DESCHR_racaFormat";
my $inferOut2 = "${outdir}/${ancestorLabel}_DESCHR_2EH";

my %orthoBlocks;
my ($id, $car, $carStart, $carEnd) = 0;

## Read INFERCARS CARs
open (OUT1, ">$inferOut1") or die "Couldn't create $inferOut1";
open (OUT2, ">$inferOut2") or die "Couldn't create $inferOut2";
open (IN, $inferCars) or die "Couldn't open $inferCars";
while(<IN>){
  chomp;
  if ($_ =~ /^\#/){
    $car = $_;
    $car =~ s/\#//;
    $carStart = $carEnd = 0;
    #print "CAR = $car\n";
  }
  elsif($_ ne "" && $_ =~ /^$reference/){
    #print $_."\n";
    $carStart = $carEnd;
    my @temp1 = split(/\s+/, $_);
    my @temp2 = split(/[.:-]+/, $temp1[0]);
    my ($CHR, $CHRstart, $CHRend) = ($temp2[1],$temp2[2], $temp2[3]);
    $CHR =~ s/chr//;
    if ($reference eq "Taegut"){
      if ($CHR eq "29"){ $CHR = "1A";}
      if ($CHR eq "30"){ $CHR = "1B";}
      if ($CHR eq "31"){ $CHR = "4A";}
      if ($CHR eq "33"){ $CHR = "Z";}
    }
    if ($reference eq "Galgal"){
      if ($CHR eq "33"){ $CHR = "W";}
      if ($CHR eq "34"){ $CHR = "Z";}
    }
    my $blockLen = $CHRend - $CHRstart + 1;
    $carEnd = $carStart + $blockLen;
    #print join(",", @temp2)."\n";
    print OUT1 "CAR${car}\t$carStart\t$carEnd\t$CHR\t$CHRstart\t$CHRend\t$temp1[1]\n";
    my $orient = "+1";
    if ($temp1[1] eq "-"){ $orient = "-1"; }
    print OUT2 "$refracaLabel,$CHR,$CHRstart,$CHRend,$carStart,$carEnd,$orient,${ancestorLabel},$car,$car\n";
  }
}
close IN;
close OUT1;
close OUT2;

MergeBlocks::mergeBlocks("$inferOut2", $resolution);
