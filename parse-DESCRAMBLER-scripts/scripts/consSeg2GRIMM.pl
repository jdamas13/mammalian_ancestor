#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Data::Dumper;

my $conseg = shift; #Conserved.Segments file
#>4
#Taegut.chr1:852391-1011434 +
#Geofor.scaffold409:546376-719270 -

my $racfs = shift; #Ancestor.APCF file
#>ANCESTOR	3488
## APCF 1
#342 396 397 -300 -299 -298 -297 -296

my $outPrefix = shift; #Prefix for output files

#READ conserved segments
my %consegs_hash;
my $id;
my $line_cnt=0;
open(F, $conseg) or die "Couldn't open $conseg!\n";
while (<F>) {
	chomp;
	if ($_ =~ /^>/){
    	$id = $_;
    	$id =~ s/>//;
  	}
  	elsif($_ ne ""){
  		my $t = $_;
  		$t =~ s/\./,/;
  		$t =~ s/:/,/;
  		$t =~ s/-/,/;
  		$t =~ s/\s/,/;
  		#print $t."\n";
  		my @tmp = split(/,/, $t);
  		#print Dumper @tmp;
  		my $sp = $tmp[0];
  		my $chr = $tmp[1];
  		shift(@tmp);
  		shift(@tmp);
  		push (@tmp, $id);
 		
  		push(@{$consegs_hash{$sp}{$chr}}, \@tmp);
  	}
  	$line_cnt++;
}
close F;

foreach my $sp (keys %consegs_hash){
	print "$sp\n";
	open (O, ">${outPrefix}_${sp}.out") or die "Couldn't create ${outPrefix}_${sp}.out!\n";
	foreach my $chr (keys %{$consegs_hash{$sp}}){
		my @multi = @{$consegs_hash{$sp}{$chr}};
		my @multi_sorted = sort { $a->[0] <=> $b->[0] } @multi;
		for (my $row = 0; $row <= $#multi_sorted; $row++){
			print scalar(@multi_sorted)."\t".$multi_sorted[$row][2]."\n";
			if ($multi_sorted[$row][2] eq "-"){ my $newBlock = "-".$multi_sorted[$row][3]; $multi_sorted[$row][3]=$newBlock; }
			if ($row == $#multi_sorted){
			 	print O $multi_sorted[$row][3]."\$\n";
			}
			else{
			 	print O $multi_sorted[$row][3]." ";
			} 
		}
	}
	close O;
}

#READ RACFs
my %racfs_hash;
my $racf_id;
open(F, $racfs) or die "Couldn't open $racfs!\n";
while (<F>) {
	chomp;
	next if ($_ =~ /^\>/);
	if($_ =~ /^#/){
		my @tmp = split(/\s+/,$_);
		$racf_id=$tmp[2];
		#@{$racfs_hash{$id}}=();
	}
	else{
		#print $conseg_id."\t";	
		my @tmp = split(/\s+/,$_);
		push (@{$racfs_hash{$racf_id}}, @tmp);	
	}
	
}
close F;

open(O, ">${outPrefix}_Ancestor.out") or die "Couldn't create ${outPrefix}_Ancestor.out!\n";
foreach my $racf (keys %racfs_hash){
	print O join(" ", @{$racfs_hash{$racf}})."\n";
}
close O;

#print Dumper %racfs_hash;


