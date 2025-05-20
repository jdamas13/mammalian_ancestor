#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;

my $regions = shift; #bed file
#chr13   19344547        19905086        +       chr13   19346469        19346582        SINE    MIR     MIRc    113
my $output = shift; 

#READ REGIONS
my %regions;
my @class1;
my @class2;
my @class3;
open (IN, $regions) or die "Couldn't open $regions!\n";
while(<IN>){
	chomp;
	my @t = split(/\t/, $_);
	my $key = $t[0]."_".$t[1]."_".$t[2];
	push(@class1, $t[7]);
	push(@class2, $t[8]);
	push(@class3, $t[9]);
	if (exists $regions{$key}){
		push(@{$regions{$key}}, @t);
	} else {
		@{regions{$key}} = @t;
	}
}
close IN;

foreach my $k (keys %regions){
	my @tmp = split(/_/, $k);
	

}

my @u_class1 = uniq(@class1);
my @u_class2 = uniq(@class2);
my @u_class3 = uniq(@class3);

foreach my $cla (@u_class1){
	print $cla."\n";
	foreach my $k (keys %regions){
		foreach my $idx (0 .. $#@{regions{$k}}){
			my ($chr, $start, $end, $s, $repc, $reps, $repe, $repc1, $repc2, $repc3, $everlen) = @{$regions{$k}{$idx}};
			if ($repc1 eq $cla) {
				# body...
			}


	}

	##HERE
	#Need to loop matrix
	#Need to create array with each repeat class, subclass and subsubclass

	my ($chr, $start, $end, $s, $repc, $reps, $repe, $repc1, $repc2, $repc3, $everlen = )
	my ($s, $e) = @{$regions{$name}{$k}};
	if ($s <= $start && $e >= $end){ #complete overlap
		print OUT "$name\t$s\t$e\t$name\t$start\t$end\t$c1\t$c2\t$c3\n"; 		
	}
}

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
