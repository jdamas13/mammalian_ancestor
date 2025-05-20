#!/usr/bin/perl -w

#Convert the original scaffolds to RACA chained chromosomes
# raca_out_modified (Use modify_racaout.pl before!!!)

use strict;
use Data::Dumper;


die "usage: perl $0 <raca_out_mod> <genome> <output>\n$!" if(@ARGV <3);

my $chain_gff=shift;
my $genome=shift;
my $out = shift;
my (%Raca,%Genome);
Read_raca($chain_gff,\%Raca);
Read_fa($genome,\%Genome);

open OUT1, ">$out";
for my $supk (keys %Raca){
    my $count=1;
    my ($tem_seq,$seq);
    #Chain the superscaffolds
    foreach( @{$Raca{$supk}} ){
        #print $supk."\n";
        my $num_bases = $Raca{$supk}[$count-1][4]-$Raca{$supk}[$count-1][3]+1;
        $tem_seq= substr($Genome{$Raca{$supk}[$count-1][2]}, $Raca{$supk}[$count-1][3]-1, $num_bases); #$tem_seq is the seq for this scaffold
        my $interval;
        $interval=$Raca{$supk}[$count][0]-$Raca{$supk}[$count-1][1]-1 if($count < @{$Raca{$supk}}); #gap N length
        if($Raca{$supk}[$count-1][5]=~/-/){
            $tem_seq=~tr/ATCGatcg/TAGCtagc/;
            $tem_seq=reverse $tem_seq;
        }
        if( defined $interval && $interval >0 ){
            my $interval_seq="N"x$interval;
            #print STDERR"$interval\n";
            $tem_seq.=$interval_seq;
            $seq.=$tem_seq;
        }
        else{
            $seq.=$tem_seq;
        }
        $count++;
    }
    print OUT1 ">$supk\n$seq\n";
}

close OUT1;

sub Read_raca{
    my $f=shift;
    my $h=shift;
    open IN,$f;
    while(<IN>){
        chomp;
        next if(/^#/);
        my @t=split"\t";
        push @{$h->{"\L$t[0]"}},[$t[1],$t[2],$t[3],$t[4],$t[5],$t[6]] ;
    }
    close IN;
}

sub Read_fa{
    my $fa=shift;
    my $h=shift;
    open IN, $fa;
    $/=">";<IN>;$/="\n";
    while(<IN>){
        chomp;
        my $name=$1 if(/^(\S+)/);
        $name=~s/chr//;
        $/=">";
        my $seq=<IN>;
        chomp $seq;
        $seq=~s/\s+//g;
        $/="\n";
        $h->{$name}=$seq;
    }
    close IN;
}
