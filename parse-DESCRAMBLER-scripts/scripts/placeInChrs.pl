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

my $cnt = 0;
open (IN, $EH_assembly) or die "Couldn't open $EH_assembly!\n"; #pFalcon,12,0,29578250,0,29578250,+1,FPEpcfs,9,9
while(<IN>){
	chomp;
	my $ID = (split(/,/, $_))[1];
	#print $ID."\n";
	@{$assembly{$cnt}}=split(/,/, $_);
	$cnt++;
}
close IN;
#print Dumper %assembly;
my $lc = 1;
open (OUT, ">$EH_out") or die "Couldn't create $EH_out!\n";
open(SP, $EH_species) or die "Couldn't open $EH_species!\n"; #RACA:Falper:Taegut,4d_T,438,757815,438,757815,+1,Falper,10,10
while(<SP>){
	chomp;
	#print "$lc\n";
	if ($_ eq ""){next;}
	my @tmp = split(/,/, $_);
	#print Dumper @tmp;
	my ($tarChr, $tinpStart, $tinpEnd, $tStart, $tEnd, $tOr, $tname, $tID) = ($tmp[1], $tmp[2], $tmp[3], $tmp[4], $tmp[5], $tmp[6], $tmp[7], $tmp[8]);
	
	foreach my $idx (keys %assembly) {
    	my ($x, $chr, $pincStart, $pincEnd, $pstart, $pend, $strand, $y, $racf) = @{$assembly{$idx}};
    	my $nID = $tID;
    	my $os = $pstart;
    	if ($tinpStart > $pstart) {$os = $tinpStart;}
    	my $oe = $pend;
    	if ($tinpEnd < $pend){$oe = $tinpEnd;}
    	my $over = $oe - $os;
    	if ($racf eq $tarChr && $pstart <= $tinpEnd && $tinpStart <= $pend && $over > 0){ 
			#my $strand = @{$assembly{$tarChr}}[6];
   			#print "Match $chr $racf $tarChr $over\n";
    		
 			if ($strand eq "+1" || $strand eq "1"){
   				my $gstart = $pincStart + ($tinpStart - $pstart);
   				my $gend = $pincStart + ($tinpEnd - $pstart);
   				my $nOr;
   				if ($tOr eq "-1"){ $nOr = "-1"; }
   				if ($tOr eq "+1" || $tOr eq "1"){ $nOr = "+1"; }
   				print OUT "$x,$chr,$gstart,$gend,$tStart,$tEnd,$nOr,$tname,$nID,$nID\n";
   				#next;
   			}
   			if ($strand eq "-1"){
   				my $gstart = $pincEnd - ($tinpEnd - $pstart);
   				my $gend = $pincEnd - ($tinpStart - $pstart);
   				my $nOr;
   				if ($tOr eq "-1"){ $nOr = "+1"; }
   				if ($tOr eq "+1" || $tOr eq "1"){ $nOr = "-1"; }
          		print OUT "$x,$chr,$gstart,$gend,$tStart,$tEnd,$nOr,$tname,$nID,$nID\n";
           		#next;
   			}
   			if ($strand eq "+"){
   				my $gstart = $pincStart + ($tinpStart - $pstart);
   				my $gend = $pincStart + ($tinpEnd - $pstart);
   				print OUT "$x,$chr,$gstart,$gend,$tStart,$tEnd,$tOr,$tname,$nID,$nID\n";
   				#next;
   			}
   		}
	}
	$lc++;
}
close SP;
close OUT;

MergeBlocks::mergeBlocks("$EH_out", $resolution);
`perl /share/lewinlab/jmdamas/perl_scripts/EvoHigh/add_letter_scaffv2.pl ${EH_out}.merged ${EH_out}.final`;
