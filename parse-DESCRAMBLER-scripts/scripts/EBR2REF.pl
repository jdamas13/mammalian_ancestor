#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

#Converts EBR coordinates from ancestor to reference
#Uses EBA output and EH format APCF_ref.map file
#
# Joana Damas September 4, 2019

my $ebr_file = shift; 
#Format:
#Reference genomme name\tReference Chr.\tFinal classification\tNarrowest  EBR interval start (bp)\t
#Narrowest  EBR interval end (bp)\tClass\tScores\tetc...
my $map_file = shift; #name,pcf,pcf_start,pcf_end,chr_start,chr_end,orient,species,chr,chr -> RACF > HSA
my $outFile = shift; #output file

my (%ebrs, %results);

my $line_cnt = 0;
open(E, $ebr_file) or die "Couldn't open $ebr_file!\n";
while(<E>){
	chomp;
	my @line=split(/\t/, $_);
	if ($line[0] =~ /^Ref/){ next; }
	@{$ebrs{$line_cnt}}=($line[1], $line[3], $line[4], $line[2], $line[5]);
	$line_cnt++;
}
close E;
#print Dumper %ebrs;

my $count = 0;
open(MAP, $map_file) or die "Couldn't open $map_file!\n";
while(<MAP>){
  	chomp;
	my @lines=split(/,/, $_);
	if ($#lines > 0){
		foreach my $ebr (keys %ebrs){
      		my ($chr, $start, $end) = @{$ebrs{$ebr}};
      		#print "$chr\n";
			if ($lines[1] =~ /^$chr$/){
        		if ($start <= $lines[3] && $lines[2] <= $end){
          			my $distStart = $start - $lines[2];
          			my $distEnd = $end - $lines[2];
          			my $distance = $lines[3] - $end;
          			my $length = $end - $start;
          			my $bStart = $lines[4] + $distStart;
          			my $bEnd = $lines[4] + $distEnd;
          			if ($lines[6] eq "-1"){
            			$bStart = $lines[4] + $distance;
            			$bEnd = $lines[4] + $distance + $length;
          			}
          			if ($bStart < $lines[4]){ 
            			$bStart = $lines[4]; 
            			$bEnd = $lines[4] + $length;
          			}
          			if ($bEnd > $lines[5]){
            			$bStart = $lines[5] - $length;
            			$bEnd = $lines[5];
          			}
					if ($bStart < 1){ $bStart = 1; }
            		if (scalar(@{$ebrs{$ebr}}) <= 5){
            			push(@{$ebrs{$ebr}},($lines[8], $bStart, $bEnd));
            		} else {
            			my $old_start = ${$ebrs{$ebr}}[6];
            			my $old_end = ${$ebrs{$ebr}}[7];
            			if ( $old_start >= $bEnd ){ @{$ebrs{$ebr}} = (@{$ebrs{$ebr}}[0 .. 5], $bStart, $old_end); }
            			else { @{$ebrs{$ebr}} = (@{$ebrs{$ebr}}[0 .. 5], $old_start, $bEnd); }
            		}
          			#if (scalar(@{$ebrs{$ebr}}) > 7){ @{$ebrs{$ebr}} = (@{$ebrs{$ebr}}[0 .. 4], "Multiple hits"); }  
          			# if (scalar(@{$ebrs{$ebr}}) <= 5){
            			#if ($bStart < 1){ $bStart = 1; }
            			#push(@{$ebrs{$ebr}},($lines[8], $bStart, $bEnd));
          			# }
				}
			}
		}
	}
}
close MAP;

open(OUT, ">$outFile") or die "Couldn't create $outFile";
foreach my $ebr (keys %ebrs){
  	if (scalar(@{$ebrs{$ebr}}) <= 5){
    	print OUT join("\t", @{$ebrs{$ebr}})."\tNo hits\n";
  	} else {  
    	print OUT join("\t", @{$ebrs{$ebr}})."\n";
  	}
}
close OUT;