#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;

my $regions = shift; #bed file
#chr start end
my $genes = shift; #bed file with feature
#Ensembl Gene ID Chromosome Name Gene Start (bp) Gene End (bp)   Strand  Associated Gene Name    Human Ensembl Gene ID   Human Chromosome Name Human Chromosome start (bp)      Human Chromosome end (bp)       Human homology type
my $output = shift; 

#READ REGIONS
my %regions;
my $cnt = 1;
open (IN, $regions) or die "Couldn't open $regions!\n";
while(<IN>){
	chomp;
	my ($chr, $start, $end) = split(/\t/, $_);
	@{$regions{$chr}{$cnt}} = ($start, $end);
	$cnt++;
}
close IN;

#READ GENES FILE
open(OUT, ">$output") or die "Couldn't create $output!\n";
open(IN, $genes) or die "Couldn't open $genes!\n";
while(<IN>){
	chomp;
	my ($ensID, $chr, $start, $end) = split(/\t/, $_);
	#print "$ensID, $chr, $start, $end\n";
	my $name=$chr;
	#print $chr."\n";
	foreach my $k (keys %{$regions{$name}}){
		my ($s, $e) = @{$regions{$name}{$k}};
		if ($s <= $start && $e >= $end){ #complete overlap
			print OUT "$_\n"; 		
		}
	}
}
close IN;
close OUT;
