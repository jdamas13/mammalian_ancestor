#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

#					0	  1    2      3    4          5        6      7        8     9	
my $input = shift; #ANC\tRACF\tstart\tend\tscafstart\tscafend\torien\tspecies\tscaf\tscaf - needs to be without letter
my $anc_db = shift;
my $output = shift;
my $resolution = shift; #minimum length of scaffolds to be included
my $ref_short = shift;

my @matrix;
my $cnt = 0;
open (IN, $input) or die "Couldn't open $input";
while(<IN>){
	chomp;
	my @t = split(/,/, $_);
	my $len = $t[3] - $t[2];
	if ($len >= $resolution){
		@{$matrix[$cnt]} = split(/,/, $_);
		push(@{$matrix[$cnt]}, $cnt);
		$cnt++;
	}
}
close IN;

my %anc_state;
open(ANC, $anc_db) or die "Couldn't open $anc_db!\n";
while (<ANC>) {
	chomp;
	if ($_ !~ /^#/){
		my ($state, $chr_cnt, $ancestor) = split(/\s+/, $_);
		if (exists $anc_state{$chr_cnt}){
			push (@{$anc_state{$chr_cnt}}, "$state->$ancestor");
		} else {
			@{$anc_state{$chr_cnt}} = "$state->$ancestor";
		}
	}
}
close ANC;
#print Dumper %anc_state;

my @sorted_matrix = sort { $a->[1] cmp $b->[1] || $a->[2] <=> $b->[2] } @matrix; #sort by refCHR, refStart

my %summary;
my $tot_len = 0;
my $cnt2 = 0;
for my $i (0 .. scalar(@sorted_matrix)-2){ 				#for each line in sorted file
	my @tmp1 = @{$sorted_matrix[$i]};
	my @tmp2 = @{$sorted_matrix[$i+1]};
	if ($tmp1[8] eq $tmp2[8] && $tmp1[1] eq $tmp2[1]){	#scaf is the same & ref chromosome in the same
		if ($tot_len == 0){ $tot_len = ($tmp1[5] - $tmp1[4]) + ($tmp2[5] - $tmp2[4]); }
		else{ my $plen = $tot_len; $tot_len = $plen + ($tmp2[5] - $tmp2[4]); }
	} else { 
		if (exists $summary{$tmp1[1]}){
			if ($tot_len == 0){ $tot_len = ($tmp1[5] - $tmp1[4]); }
			my $fusion = ${$summary{$tmp1[1]}}[1]."-".$tmp1[8];
			$fusion =~ s/chr/$ref_short/g;
			my $len =  ${$summary{$tmp1[1]}}[2]."-".$tot_len;
			$cnt2++;
			@{$summary{$tmp1[1]}} = ($cnt2, $fusion, $len);
			$tot_len = 0;
		} else {
			if ($tot_len == 0){ $tot_len = ($tmp1[5] - $tmp1[4]); }
			$cnt2++;
			my $ref_chr = $tmp1[8];
			$ref_chr =~ s/chr/$ref_short/g;
			@{$summary{$tmp1[1]}} = ($cnt2, $ref_chr, $tot_len);
			$tot_len = 0;		
		}
		if ($tmp1[1] ne $tmp2[1]){ $cnt2 = 0; }
	}
}
#print Dumper %summary;

#Classification
open (OUT, ">$output") or die "Couldn't create $output!\n";
print OUT "Scaffold\tNoChrs\tFusion\tSizes\tClassifications\n";
my $flag = "Unique";
my @classes;
for my $scaffold (keys %summary){
	my ($nochrs, $fusion, $size) = @{$summary{$scaffold}};
	if ($nochrs == 1){ $flag = "na"; }
	else {
		print $scaffold."\n";
		my @idx = reverse(2 .. $nochrs);
		for my $nc (@idx){ #for each chromosome combination
			if (exists $anc_state{$nc}){ #if number of chromosomes exists in ancestral state
				for my $st (0 .. scalar(@{$anc_state{$nc}})-1){	#for each combination with specific number of chromosomes
					#print $anc_state{$nc}[$st]."\n";
					my ($as, $cl) = split(/->/, $anc_state{$nc}[$st]);
					my $r_as = join("-", reverse(split (/-/, $as))); #reverse string
					if ($fusion =~ /^$as$/ || $fusion =~ /^$r_as$/ || $fusion =~ /^$as-/ || $fusion =~ /^$r_as-/ || \
						$fusion =~ /-$as$/ || $fusion =~ /-$r_as$/ || $fusion =~ /-$as-/ || $fusion =~ /-$r_as-/){
						if($nochrs == $nc){ push(@classes, $cl); }
						else { push(@classes, $anc_state{$nc}[$st]); }
						$flag = "Classified";
						#print "$fusion\t".$anc_state{$nc}[$st]."\n";
					}
				}
			} else { next; }
		}
	}
	if ($flag eq "na" || $flag eq "Unique"){
		print OUT "$scaffold\t$nochrs\t$fusion\t$size\t$flag\n";
	} else {
		my @un_classes = &uniq(@classes);
		$flag = join("||", @un_classes);
		print OUT "$scaffold\t$nochrs\t$fusion\t$size\t$flag\n";
	}
	$flag = "Unique";
	@classes = ();
}
close OUT;


sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}