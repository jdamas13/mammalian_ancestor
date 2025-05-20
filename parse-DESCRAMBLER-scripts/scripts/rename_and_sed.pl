#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $file = shift;
my $ref = shift;
my $rename_sps = shift;

my %names;
open(N, $rename_sps) or die "Couldn't open $rename_sps!\n";
while (<N>) {
	chomp;
	my ($new_name, $old_name) = split(/\s+/, $_);
	$names{$old_name} = $new_name;
}
close N;

unlink "tmp";
open (IN, $file) or die "Couldn't open $file!\n";
open (OUT, ">tmp") or die "Couldn't create tmp!\n";
while (<IN>) {
	chomp;
	$_ =~ s/[Cc]hr//;
	$_ =~ s/[Ss]uper_[Ss]caffold_//;
	$_ =~ s/[Ss]caffold_//;
	$_ =~ s/[Ss]uper_[Ss]caffold//;
	$_ =~ s/[Ss]caffold//;
	$_ =~ s/[Cc]ontig/ctg/;
	$_ =~ s/;HRSCAF=/_/g;
    $_ =~ s/(HiC_|Sc9Yeyj_|ScGVr9J_|SUPER_|arrow_|ScNnEE3_|VOSF|ScPeMD7_)//g;
    $_ =~ s/__(\d+)_ctgs__length_(\d+)//g;
	$_ =~ s/:APCF:(\d+)//g;
    $_ =~ s/superctg_//g;
	my ($r,$rc,$rs,$re,$ts,$te,$or,$t,$tc,$l) = split(/,/, $_);
	my $nname=$t;
	if (exists $names{$t}){ $nname = $names{$t} };

    $nname =~ s/^MAM/1_MAM/g;
    $nname =~ s/^THE/2_THE/g;
    $nname =~ s/^EUT/3_EUT/g;
    $nname =~ s/^BOR/4_BOR/g;
    $nname =~ s/^EUA/5_EUA/g;
    $nname =~ s/^EUC/6_EUC/g;
    $nname =~ s/^PMT/7_PMT/g;
    $nname =~ s/^PRT/8_PRT/g;
	$nname =~ s/^LAU/5_LAU/g;
    $nname =~ s/^SCR/6_SCR/g;
    $nname =~ s/^FER/7_FER/g;
    $nname =~ s/^CET/8_CET/g;
    $nname =~ s/^RCT/9_RCT/g;
    $nname =~ s/^RUM/10_RUM/g;
    $nname =~ s/^ATL/4_ATL/g;
    $nname =~ s/^XEN/5_XEN/g;
    
    print OUT "$ref,$rc,$rs,$re,$ts,$te,$or,$nname,$tc,$tc\n";
}					

close IN;
close OUT;

`mv "tmp" $file`;
unlink "tmp";

exit;
