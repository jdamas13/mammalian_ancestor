#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Data::Dumper;

my $dir = shift; #Jaebum's database file
my $ref = shift; #Reference name i.e. Taegut
my $res = shift; #Resolution short i.e. for 100,000 use 100
my $suffix = shift;

my $prefix = basename($dir);
#print $prefix."\n";

my $in = "$dir/APCFs.100K/dbfile.all.txt";
my $out = "$dir/blocksInAnc_${ref}_${res}K"; #Output file using ref
my $commands_file = "$dir/commands.txt";

#print $out."\n";
#FORMAT:
#(REF_GEN, REF_CHR, START_BP, END_BP, MODIFIED_ORDER_START, MODIFIED_ORDER_END, SIGN, COMP_GEN, COMP_CHR, LABEL)

open (IN, $in) or die "Couldn't open the $in!\n";
open (OUT,">$out") or die "Can't create the output file\n";

while (<IN>) {
	chomp $_;
	if ($_ =~ /insert into CONSENSUS.*/ && $_ =~ /\b$ref\b/) {
		$_ =~ s/'//g;
		my @tmp = split (/\(/, $_);
		my @tmp1 = split (/\,/, $tmp[1]);
		my ($sps) = $tmp1[7] =~/(.*)/;
		if ($tmp1[6] == 1 ){$tmp1[6] = "+1";}
		#$tmp1[6] =~ s/1//;
		#print Dumper @tmp1;

		my $ch = $tmp1[8];
		if ($ref eq "Taegut"){
			if ($ch eq "29"){ $ch = "1A"; }
			if ($ch eq "30"){ $ch = "1B"; }
			if ($ch eq "31"){ $ch = "4A"; }
			if ($ch eq "33"){ $ch = "Z"; }
		}
		if ($ref eq "Galgal"){
			if ($ch eq "34"){ $ch = "Z"; }
		}

		#print OUT "$ref:${res}K,$ch,$tmp1[4],$tmp1[5],$tmp1[2],$tmp1[3],$tmp1[6],$prefix$suffix,$tmp1[1],$tmp1[1]\n";
		print OUT "$prefix$suffix,$tmp1[1],$tmp1[2],$tmp1[3],$tmp1[4],$tmp1[5],$tmp1[6],$ref,$ch,$ch\n";
	}
}
close IN;
close OUT;


# open(C, ">$commands_file") or die "Couldn't open $commands_file!\n";
# print C "LOAD DATA local INFILE \'$out\' INTO TABLE CONSENSUS FIELDS TERMINATED BY \'\,\' LINES TERMINATED BY \'\\n\' (REF_GEN, REF_CHR, START_BP, END_BP, MODIFIED_ORDER_START, MODIFIED_ORDER_END, SIGN, COMP_GEN, COMP_CHR, LABEL);\n";
# print C "delete from CHROMOSOME_SIZE where GEN=\'$prefix$suffix\';\n";
# print C "delete from CHROMOSOME_SIZE where GEN=\'$ref:${res}K\';\n";
# print C "INSERT INTO CHROMOSOME_SIZE SELECT COMP_GEN as GEN, COMP_CHR as CHR, max(MODIFIED_ORDER_END) as SIZE from CONSENSUS where COMP_GEN = \'$prefix$suffix\' group by COMP_GEN, COMP_CHR;\n";
# print C "INSERT INTO CHROMOSOME_SIZE SELECT REF_GEN as GEN, REF_CHR as CHR, max(END_BP) as SIZE from CONSENSUS where REF_GEN = \'$ref:${res}K\' group by REF_GEN, REF_CHR;\n";
# close C;


#`mkdir -p $eba_dir/DESCHRAMBLER/$prefix`; 
#`mv $out $eba_dir/DESCHRAMBLER/$prefix`;