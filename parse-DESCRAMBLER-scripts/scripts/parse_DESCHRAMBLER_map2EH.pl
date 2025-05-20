#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
require "/share/lewinlab/jmdamas/perl_scripts/modules/mergeBlocks.pm";

my $directory = shift;
my $ancestor = shift;

my %blocks;
my $flag;
my $chromo;
opendir (DIR, $directory) or die "Couldn't open ${directory}!\n";
while (my $file = readdir(DIR)) {
	if ($file =~ /map$/){
        print "$file\n";
        open (IN, "$directory/$file") or die "Couldn't open ${file}!\n";
        open (OUT, ">${directory}/${file}.EH") or die "Couldn't create ${file}.EH!\n";
        while(<IN>){
        	chomp;
        	if ($_ =~ /^APCF/){
        		my @temp1 = split(/\s+/, $_);
				my @temp2 = split(/[.:-]+/, $temp1[0]);
				$chromo = $temp2[1];
				print OUT "$ancestor,$temp2[1],$temp2[2],$temp2[3],";
				$flag="middle";#print "$ancestor,$temp2[1],$temp2[2],$temp2[3],";
			}
			elsif($_ ne "" && $_ !~ /^>/){
				my @temp1 = split(/\s+/, $_);
				my @temp2 = split(/[.]/, $temp1[0], 2);
				my @temp3 = split(/[:-]+/, $temp2[1]);
				my $chr = $temp3[0];
				$chr =~ s/chr//;
				my $orient = "+1";
				if ($temp1[1] eq "-"){ $orient = "-1"; }
				if ($flag eq "end"){
					print OUT "$ancestor,$chromo,0,0,$temp3[1],$temp3[2],$orient,$temp2[0],$chr,$chr\n";
				} else {
					print OUT "$temp3[1],$temp3[2],$orient,$temp2[0],$chr,$chr\n";
					$flag="end";
				}
				#print "$temp2[2],$temp2[3],$temp1[1],$temp2[0],$chr,$chr\n";
			}
		}
		close IN;
		close OUT;
    }
}
closedir DIR;

