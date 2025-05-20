#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
require "/share/lewinlab/jmdamas/perl_scripts/modules/mergeBlocks.pm";

#Convert get EH file from db format

my $dbfile=shift; 
#insert into CONSENSUS values('APCF:Ancestor:14','1',0,148087,98231147,98379234,1,'M_Ancestor_1','2',null,'2','2');
my $EH_out = shift; #output file name
#'APCF:Ancestor:14','1',0,148087,98231147,98379234,1,'M_Ancestor_1','2',null,'2','2'
my $res = shift;

open (OUT, ">$EH_out") or die "Couldn't create $EH_out!\n";
open (IN, $dbfile) or die "Couldn't open $dbfile!\n"; 
while(<IN>){
    chomp;
    if ($_ =~ /CONSENSUS/){
    	if ($_ =~ /^INSERT/) { next; }
      	else {
      		my $nline = $_;
      		$nline =~ s/insert into CONSENSUS values\(//g;
      		$nline =~ s/\)\;//g;
      		$nline =~ s/'//g;
          my @tmp = split(",", $nline);
          my $len = $tmp[3] - $tmp[2];
          if ($len >= $res){
      		  print OUT join(",", @tmp[0..8]).",".$tmp[8]."\n";
          }
      	}
    }
}
close IN;
close OUT;

MergeBlocks::mergeBlocks("$EH_out", $res);
`mv ${EH_out}.merged $EH_out`;