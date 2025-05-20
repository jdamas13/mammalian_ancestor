#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
require "/share/lewinlab/jmdamas/perl_scripts/modules/mergeBlocks.pm";

my $EH_assembly=shift; #GFF file without gaps
my $EH_species=shift; #EHspecies file (can be target/reference/outgroup) 
my $EH_out = shift; #output file name

my $resolution = 10000;

my %assembly;

open (IN, $EH_assembly) or die "Couldn't open $EH_assembly!\n"; #pFalcon,12,0,29578250,0,29578250,+1,FPEpcfs,9,9
while(<IN>){
  chomp;
  my $ID = (split(/,/, $_))[8];
  #print $ID."\n";
  @{$assembly{$ID}}=split(/,/, $_);
}
close IN;
#print Dumper %assembly;

open (OUT, ">$EH_out") or die "Couldn't create $EH_out!\n";
open(SP, $EH_species) or die "Couldn't open $EH_species!\n"; #RACA:Falper:Taegut,4d_T,438,757815,438,757815,+1,Falper,10,10
while(<SP>){
  chomp;
  my @tmp = split(/,/, $_);
  #print Dumper @tmp;
  my $tarChr = $tmp[1];
  if (exists $assembly{$tarChr}){
    #print Dumper @{$assembly{$tarChr}};
      #print $_."\n";

      my $strand = @{$assembly{$tarChr}}[6];
      my ($tinpStart, $tinpEnd, $tStart, $tEnd, $tOr, $tname, $tID) = ($tmp[2], $tmp[3], $tmp[4], $tmp[5], $tmp[6], $tmp[7], $tmp[8]);
      #print $tname."\n";
      my ($x, $chr, $pincStart, $pincEnd, $pstart, $pend) = @{$assembly{$tarChr}};
      my $nID = $tID;
    
      if ($tname eq "Taegut" or $tname eq "Zebra finch"){
          if ($nID eq "29"){ $nID = "1A"; }
          if ($nID eq "30"){ $nID = "1B"; }
          if ($nID eq "31"){ $nID = "4A"; }
          if ($nID eq "33"){ $nID = "Z"; }
      }
      if ($tname eq "Galgal" or $tname eq "Chicken"){
          if ($nID eq "33"){ $nID = "W"; }
          if ($nID eq "34"){ $nID = "Z"; }
      }
    
      if ($strand eq "+1" || $strand eq "1"){
          my $gstart = $pincStart + ($tinpStart - $pstart);
          my $gend = $pincStart + ($tinpEnd - $pstart);
          my $nOr;
          if ($tOr eq "-1"){ $nOr = "-1"; }
          if ($tOr eq "+1" || $tOr eq "1"){ $nOr = "+1"; }
          #print OUT "$x,$chr,$gstart,$gend,$tStart,$tEnd,$nOr,$tname,$nID,$nID\n";
          print OUT "$tname,$nID,$tStart,$tEnd,$gstart,$gend,$nOr,$x,$chr,$chr\n";
      }

      if ($strand eq "-1"){
          my $gstart = $pincEnd - ($tinpEnd - $pstart);
          my $gend = $pincEnd - ($tinpStart - $pstart);
          my $nOr;
          if ($tOr eq "-1"){ $nOr = "+1"; }
          if ($tOr eq "+1" || $tOr eq "1"){ $nOr = "-1"; }
          #print OUT "$x,$chr,$gstart,$gend,$tStart,$tEnd,$nOr,$tname,$nID,$nID\n";
          print OUT "$tname,$nID,$tStart,$tEnd,$gstart,$gend,$nOr,$x,$chr,$chr\n";
      }
      
      if ($strand eq "+"){
          my $gstart = $pincStart + ($tinpStart - $pstart);
          my $gend = $pincStart + ($tinpEnd - $pstart);
          #print OUT "$x,$chr,$gstart,$gend,$tStart,$tEnd,$tOr,$tname,$nID,$nID\n";
          print OUT "$tname,$nID,$tStart,$tEnd,$gstart,$gend,$tOr,$x,$chr,$chr\n";
      }
    }
    else { next; }
}
close SP;
close OUT;

MergeBlocks::mergeBlocks("$EH_out", $resolution);
`perl /share/lewinlab/jmdamas/MAMMAL_RECONS_11MAR2021/scripts/add_letter_scaffv2.pl ${EH_out}.merged ${EH_out}.final`;
