#!usr/bin/perl
use strict;
use warnings;
use File::Basename;
use List::Util qw(min max);
#Calculate stats of ancestor reconstructions from ref EH format
#ANClabel,racf,racfstart,racfend,refStart,refEnd,orient,ref,refChr,refChr

my $inCars = shift;
my $ref = shift;
my $anc = shift;
my $sizesfile = shift;
my $out = "${inCars}.stats";

my $sp_length;
open(S, $sizesfile) or die "Couldn't open $sizesfile!\n";
while (<S>) {
    chomp;
    my ($sp, $size) = split(/\s+/,$_);
    if($sp eq $ref){ $sp_length = $size; }
}
close S;

my @cars = @{ get_contents ($inCars) };
my @sorted_cars = sort { $cars[1] cmp $cars[1] || $cars[2] <=> $cars[2] } @cars;

my $length = 0; #coverage of reference genome
my @fusions = (); 
my @racfs = ();

#print scalar (@sorted_cars)."\n";
for my $i (0..$#sorted_cars) {
	push (@racfs, $sorted_cars[$i][1]);
	$length += ($sorted_cars[$i][5] - $sorted_cars[$i][4]);
	if ($sorted_cars[$i][1] eq $sorted_cars[$i+1][1] && $sorted_cars[$i][8] ne $sorted_cars[$i+1][8]) {
		push @fusions, "$sorted_cars[$i][8]\/$sorted_cars[$i+1][8]";
	}
	else {next;}

}

my @uniq_racfs = uniq (@racfs);
my $coverage = $length / $sp_length * 100;

my $dirname = dirname($inCars);
#print $dirname;
#Get shortest and longest RACFs
my @racf_len;
my $racf_cnt;
open(RS, "${dirname}/APCF_size.txt") or die "Couldn't open ${dirname}/APCF_size.txt!\n";
while (<RS>) {
	chomp;
	if ($_ !~ /^total/){
		my @tmp = split(/\s+/, $_);
		push(@racf_len, $tmp[1]);
		$racf_cnt++;
	}
}
close RS;

my $long_racf = max(@racf_len);
my $short_racf = min(@racf_len);
#print "$racf_cnt\t$long_racf\t$short_racf\n";

#Get no. SF, min and max length
my @sf_len;
my $sf_cnt;
open(SF, "${dirname}/SFs/block_list.txt") or die "Couldn't open ${dirname}/SFs/block_list.txt!\n";
while (<SF>) {
	chomp;
	my @tmp = split(/\s+/, $_);
	my $len = $tmp[2] - $tmp[1];
	push(@sf_len, $len);
	$sf_cnt++;
}
close SF;

my $long_sf = max(@sf_len);
my $short_sf = min(@sf_len);

#print "$sf_cnt\t$long_sf\t$short_sf\n";

open (OUT, ">$out") or die "Can't create output\n";

print OUT "No. RACFs = ".scalar(@uniq_racfs)."\n";
print OUT "Total length in $ref = $length\n";
print OUT "$ref coverage = $coverage\n";
print OUT "Fusions of reference chr".join(";", @fusions)."\n";
print OUT "Max RACF lenght = $long_racf\nMin RACF length = $short_racf\n";
print OUT "No. SFs = $sf_cnt\nMax SF lenght = $long_sf\nMin SF length = $short_sf\n";
close OUT;


##### SUBROUTINES ########
sub get_contents {
	my	( $file )	= @_;
    my @contents;
    open (FH, "< $file") or die "I cannot open $file file: $!\n";
    my $x = 0;
    while (<FH>) {
        next unless /\S/;
        #next if /^\s*[A-Z]+/i;
        @{$contents[$x]} = split /,/;
        ++$x;
    }
   	
	return (\@contents);
}	# ----------  end of subroutine get_contents  ----------

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
