#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;

##raca format:
#EUT,1,0,618124,46056616,46674740,-1,hg38,21,21
#anc,name_chr,start_0-based_chr,end_1-based_chr,start_0-based_scaff,end-1-b_scaff,strand,sps,scaff_id,scaff_id


#new format:
#name_chr	start_1-based	end_1-based	scaff_id	start_1-based	end_1bades	strand
#no GAPS


my $file = $ARGV[0];
my $out = $ARGV[1];
my @raca = @{ get_contents ($file)};


open (OUT, ">$out") or die "Cant' create outfile\n";
#print OUT "##\n";

for my $x (0..$#raca) {
	my $start_chr = $raca[$x][2] +1;
	my $start_scaff = $raca[$x][4] +1;
	print OUT "$raca[$x][1]\t$start_chr\t$raca[$x][3]\t$raca[$x][8]\t$start_scaff\t$raca[$x][5]\t$raca[$x][6]\n";
}	
close OUT;

exit;

##SUBROUTINES
sub get_contents {
	my ( $file ) = @_;
    my @contents;
    open (FH, "< $file") or die "I cannot open $file file: $!\n";
    my $x = 0;
    while (<FH>) {
        next unless /\S/;
        next if /^\s+/i;
        @{$contents[$x]} = split /,/;
        ++$x;
    }
   	
	return (\@contents);
}	# ----------  end of subroutine get_contents  ----------