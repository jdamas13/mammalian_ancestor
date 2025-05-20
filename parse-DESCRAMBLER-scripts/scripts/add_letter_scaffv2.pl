#!/usr/bin/perl
#use strict;
#use warnings;
use Data::Dumper;

#print "Add a letter to broken scaffolds.\n";

my $in = $ARGV[0];
my $out = $ARGV[1];
open (IN, $in) or die "Can't open IN\n";


my $x = 0;
my @contents =();
while (<IN>) {
        chomp;
        @{$contents[$x]} = split /\,/;
        ++$x;
}

#print Dumper @contents;
my @contents_sorted = sort {$a->[8] cmp $b->[8] || $a->[4] <=> $b->[4]} @contents; 



#chicken:100K,1,31118,423773,651278,1172649,-1,falcon,122,122
#chicken:100K,1,426956,616204,282291,583287,1,falcon,122,122


my $prevTag = "";
my $currentTag ="";
my $sum = 0;
my $hadFirst = '0';
my $m = $#contents_sorted;
#print "$m\n";
my $n = 10;
#print "$n\n";



for my $i (0..$m) {
	$currentTag = $contents_sorted [$i][$n-1];
	#print "$currentTag\n";
	if ($currentTag eq $prevTag) {
		if ($hadFirst == '1') {
			#print $contents[$i][$n-1];
			push (@{$contents_sorted[$i]},chr(ord('a') + $sum));
#print $contents[$i][$n-1];
#print $contents[$n-1][$i];
			$sum++;
		}
		else {
			
			#$contents[$i-1][$n-1] .= chr(ord('a') + $sum);
			push (@{$contents_sorted[$i-1]}, chr(ord('a') + $sum));
			$sum++;
			push (@{$contents_sorted[$i]}, chr(ord('a') + $sum));
			$sum++;
			$hadFirst = '1';
		}
	}
	else {
		$hadFirst = '0';
		$sum = 0;
	}
	$prevTag = $currentTag;
}

open (OUT, ">$out") or die "Can't create OUT\n";
for my $x (0..$#contents_sorted){
    print OUT "$contents_sorted[$x][0]\,$contents_sorted[$x][1]\,$contents_sorted[$x][2]\,$contents_sorted[$x][3]\,$contents_sorted[$x][4]\,$contents_sorted[$x][5]\,$contents_sorted[$x][6]\,$contents_sorted[$x][7]\,$contents_sorted[$x][8]$contents_sorted[$x][10]\,$contents_sorted[$x][9]$contents_sorted[$x][10]\n";
}
close (OUT);

exit;

