#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
require "/share/lewinlab/jmdamas/perl_scripts/modules/mergeBlocks.pm";

my $directory = shift;

my %blocks;
opendir (DIR, $directory) or die "Couldn't open ${directory}!\n";
while (my $file = readdir(DIR)) {
	if ($file =~ /\.map$/){
        #print "$file\n";
        open (IN, "$directory/$file") or die "Couldn't open ${file}!\n";
        open (OUT, ">${directory}/${file}.bedtools") or die "Couldn't create ${file}.bedtools!\n";
        while(<IN>){
        	chomp;
        	if ($_ =~ /^APCF/){ next; }
			elsif($_ ne "" && $_ !~ /^>/){
				my @temp1 = split(/\s+/, $_);
				my @temp2 = split(/[.]/, $temp1[0], 2);
				my @temp3 = split(/[:-]+/, $temp2[1]);

				my $chr = $temp3[0];
				#$chr =~ s/chr//;
				print OUT "$chr\t$temp3[1]\t$temp3[2]\t$temp1[1]\n";
				#print "$temp2[2],$temp2[3],$temp1[1],$temp2[0],$chr,$chr\n";
			}
		}
		close IN;
		close OUT;
    }
}
closedir DIR;
