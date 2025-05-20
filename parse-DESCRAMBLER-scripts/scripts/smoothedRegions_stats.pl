#!/usr/bin/perl

use strict;
use warnings;
use Statistics::Basic qw(:all);
use List::Util qw(min max);
use Data::Dumper;

my $mergedFile = shift;
my $notMergedFile = shift;
my $output = shift;

unlink $output;

#Read merged file
my %finalBlocks;
open (IN, $mergedFile) or die "Couldn't open $mergedFile!\n";
while (<IN>) {
	chomp;
	my @tmp = split(/,/, $_);
	my $chr = $tmp[8];
	my $start = $tmp[4];
	my $end = $tmp[5];
	${$finalBlocks{$chr}{"$start-$end"}}=""; 
}
close IN;

#Read non merged file and remove duplicated regions
open (IN2, $notMergedFile) or die "Couldn't open $notMergedFile!\n";
while (<IN2>) {
	chomp;
	my @temp = split(/,/, $_);
	my $chr1 = $temp[8];
	my $start1 = $temp[4];
	my $end1 = $temp[5];
	my $flag;
	do {
		$flag = 0;
		foreach my $value (keys %{$finalBlocks{$chr1}}){
			my ($start2, $end2) = split(/-/, $value);
			if ($start1 <= $end2 && $start2 <= $end1){ #overlapping
				if ($start1 == $start2 && $end1 == $end2){ #full overlap
					delete $finalBlocks{$chr1}{$value};
					$flag++;
				}	
				if ($start1 == $start2 && $end1 < $end2){ #overlap at beginning
					my $nstart = $end1;
					delete $finalBlocks{$chr1}{$value};
					$finalBlocks{$chr1}{"$nstart-$end2"}="";
					$flag++;
				}
				if ($start1 > $start2 && $end1 == $end2){ #overlap at end
					my $nend = $start1;
					delete $finalBlocks{$chr1}{$value};
					$finalBlocks{$chr1}{"$start2-$nend"}="";
					$flag++;	
				}
				if ($start1 > $start2 && $end1 < $end2){ #overlap in middle
					my $nend = $start1;
					my $nstart = $end1;
					delete $finalBlocks{$chr1}{$value};
					$finalBlocks{$chr1}{"$start2-$nend"}="";
					$finalBlocks{$chr1}{"$nstart-$end2"}="";
					$flag++;
				}
			}
		}
	} until ($flag == 0);
	$flag = 0;
}
close IN2;
#print Dumper %finalBlocks{'19'};

open (OUT, ">$output") or die "Couldn't create $output!\n";
print OUT "Chr\tStart\tEnd\tLength\n";
my $totalNo = 0;
my %lenByChr;
my @lens;
foreach my $chr (keys %finalBlocks){
	foreach my $value (keys %{$finalBlocks{$chr}} ){
		$totalNo++;
		my ($start, $end) = split(/-/, $value);
		my $len = $end - $start;
		push(@lens, $len);
		push(@{$lenByChr{$chr}}, $len);
		print OUT "$chr\t$start\t$end\t$len\n";
	}
}
close OUT;

open (OUT2, ">${output}.total") or die "Couldn't create ${output}.total!\n";
print OUT2 "Chr\tCnt\tMin\tMax\tMean\tMedian\tSD\n";
foreach my $chr (keys %lenByChr){
	my $cnt = commify(scalar(@{$lenByChr{$chr}}));
	my $min = commify(min(@{$lenByChr{$chr}}));
	my $max = commify(max(@{$lenByChr{$chr}}));
	my $mean = commify(mean(@{$lenByChr{$chr}}));
	my $median = commify(median(@{$lenByChr{$chr}}));
	my $sd = commify(stddev(@{$lenByChr{$chr}}));
	print OUT2 "$chr\t$cnt\t$min\t$max\t$mean\t$median\t$sd\n";
}
my $t_cnt = commify(scalar(@lens));
my $t_min = commify(min(@lens));
my $t_max = commify(max(@lens));
my $t_mean = commify(mean(@lens));
my $t_median = commify(median(@lens));
my $t_sd = commify(stddev(@lens));
print OUT2 "Total\t$t_cnt\t$t_min\t$t_max\t$t_mean\t$t_median\t$t_sd\n";
close OUT2;

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text
}