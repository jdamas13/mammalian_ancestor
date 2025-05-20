#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $oldapcf = shift; #RACF-based Ancestor.APCF file
my $assembly = shift; #EH format of chromosomes
#my $blocks = shift; #blocks_list.txt
my $output = shift; #output file name

#Read old Ancestor.APCF file
my $id = 0;
my %apcfs;
my $first_line;
open(IN, $oldapcf) or die "Couldn't open $oldapcf!\n";
while (<IN>) {
	chomp;
	if ($_ =~ /^>/) { $first_line = $_; }
	elsif ($_ =~ /^#/){
		## APCF 1
		$id = $_;
		$id =~ s/# APCF //;
	}
	elsif($_ ne ""){
		my @temp1 = split(/\s+/, $_);
		pop @temp1;
		@{$apcfs{$id}} = @temp1;
	}
}
close IN;
#print Dumper %apcfs;

#Read assembly file and create new data
my %new_data;
open(IN, $assembly) or die "Couldn't open $assembly!\n";
while (<IN>) {
	chomp;
	my @tmp = split(/,/, $_);
	my $chr = $tmp[1];
	#if ($chr eq "X"){ $chr = 100; }
	my $dir = $tmp[6];
	my $racf = $tmp[8];

	my @blocks;
	if ($dir !~ /-/){
		@blocks = @{$apcfs{$racf}};
	} else {
		foreach my $id (reverse(@{$apcfs{$racf}})){
			if ($id =~ /^-/){ $id =~ s/-//; push(@blocks, $id); }
			else { my $nID = "-".$id; push(@blocks, $nID); }
		}
	}
	if (exists $new_data{$chr}){
		push(@{$new_data{$chr}}, @blocks);
	} else {
		@{$new_data{$chr}} = @blocks;
	}
}
close IN;
#print Dumper %new_data{"7"};

#Print output file
open(OUT, ">$output") or die "Couldn't create $output!\n";
print OUT "$first_line\n";
foreach my $chr (keys %new_data) {
	print OUT "# APCF $chr\n";
	print OUT join(" ", @{$new_data{$chr}})." \$\n";
}
close OUT;
exit;
