#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $input = shift;
my $ancestor = shift;

my %blocks;

open (IN, $input) or die "Couldn't open $input!\n";
open (OUT, ">${input}.EH") or die "Couldn't create ${input}.EH!\n";
while(<IN>){
   	chomp;
   	if ($_ =~ /^APCF/){
   		my @temp1 = split(/\s+/, $_);
		my @temp2 = split(/[.:-]+/, $temp1[0]);
		print OUT "$ancestor,$temp2[1],$temp2[2],$temp2[3],";
	}
	elsif($_ ne "" && $_ !~ /^>/){
		my @temp1 = split(/\s+/, $_);
		my @temp2 = split(/[.]/, $temp1[0], 2);
		my @temp3 = split(/[:-]+/, $temp2[1]);
		my $chr = $temp3[0];
		$chr =~ s/chr//;
		my $orient = "+1";
		if ($temp1[1] eq "-"){ $orient = "-1"; }
		print OUT "$temp3[1],$temp3[2],$orient,$temp2[0],$chr,$chr\n";
	}
}
close IN;
close OUT;
