#!/usr/bin/perl

use strict;
use warnings;
use Statistics::Basic qw(:all);
use List::Util qw(min max);
use Data::Dumper;

my $gainedFile = shift;
my $output = shift;

unlink $output;

#Read file
my %bychr_len;
my $tot_length;
open (IN, $gainedFile) or die "Couldn't open $gainedFile!\n";
while (<IN>) {
	chomp;
	my @tmp = split(/\s+/, $_);
	my $chr = $tmp[0];
	my $start = $tmp[1];
	my $end = $tmp[2];
	my $len = $end - $start;
	$tot_length += $len;
	if (exists $bychr_len{$chr}){
		$bychr_len{$chr} += $len; 
	} else{
		$bychr_len{$chr} = $len;
	} 
}
close IN;
open (OUT, ">$output") or die "Couldn't create $output!\n";
my $l = commify($tot_length);
print OUT "Total\t$l\n";
foreach my $chr (keys %bychr_len){
	my $c_len = commify($bychr_len{$chr});
	print OUT "$chr\t$c_len\n";
}
close OUT;

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text
}