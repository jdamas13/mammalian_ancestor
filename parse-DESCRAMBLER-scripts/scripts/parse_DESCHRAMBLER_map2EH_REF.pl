#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
require "/share/lewinlab/jmdamas/perl_scripts/modules/mergeBlocks.pm";

my $directory = shift;
my $resolution = shift;
#my $reference = shift;

my %blocks;
opendir (DIR, $directory) or die "Couldn't open ${directory}!\n";
while (my $file = readdir(DIR)) {
	if ($file =~ /processed\.segs$/){
        print "$file\n";
        open (IN, "$directory/$file") or die "Couldn't open ${file}!\n";
        open (OUT, ">${directory}/${file}.EH") or die "Couldn't create ${file}.EH!\n";
        while(<IN>){
        	chomp;
        	if ($_ =~ /^#/){ next; }
        	elsif($_ ne ""){
        		#hg38.chr3:12059-1037613 blackRhino.Sc7dOMt_2400;HRSCAF=34493:52004814-52972840 - 10
        		my @temp1 = split(/\s+/, $_);
				my @temp_ref1 = split(/[.]/, $temp1[0], 2);
				my @temp_ref2 = split(/[:-]+/, $temp_ref1[1]);
				my $refchr = $temp_ref2[0];
				$refchr =~ s/chr//g;
				my @temp_tar1 = split(/[.]/, $temp1[1], 2);
				my @temp_tar2 = split(/[:-]+/, $temp_tar1[1]);
				my $str = $temp1[2];
				print OUT "$temp_ref1[0],$refchr,$temp_ref2[1],$temp_ref2[2],$temp_tar2[1],$temp_tar2[2],${str}1,$temp_tar1[0],$temp_tar2[0],$temp_tar2[0]\n";
			}
		}
		close IN;
		close OUT;
		MergeBlocks::mergeBlocks("${directory}/${file}.EH", $resolution);
    }
}
closedir DIR;


