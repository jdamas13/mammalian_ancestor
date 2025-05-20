#!usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Data::Dumper;
#Calculate ancestor coverage in each species from ref EH format
#ANClabel,racf,racfstart,racfend,refStart,refEnd,orient,ref,refChr,refChr


#perl $MAINDIR/scripts/parse_DESCHRAMBLER_stats.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH" $REF $SANC /share/lewinlab/jmdamas/genomes/genome_sizes.txt

my $dir = shift; #output directory
my $outfile = shift;
my $suffix = shift;

$outfile = "${dir}/APCF_${outfile}_coverage_ALLsps.${suffix}.txt";
my $ancSize = "${dir}/APCF_size.txt";
my $sizesfile = "/share/lewinlab/jmdamas/genomes/genome_sizes.txt";

unlink $outfile;
unlink "${outfile}.data";

open (OUT, ">$outfile") or die "Couldn't create ${outfile}!\n";
print OUT "Species\tAncestor coverage (%)\tSpecies genome coverage (%)\n";
open (OUT2, ">${outfile}.data") or die "Couldn't create ${outfile}.data!\n";
print OUT2 "Species\tAncestor coverage (%)\tLength of ancestor genome covered (bp)\tLength of ancestor genome not covered (bp)\tSpecies genome coverage (%)\tLength of species genome covered (bp)\tLength of species genome not covered (bp)\n";


my $ancLen;
open (SZ, $ancSize) or die "Couldn't open ${ancSize}!\n";
while (<SZ>) {
	chomp;
	if ($_ =~ /total/){
		my @tmp = split(/\s+/, $_);
		$ancLen = $tmp[1];
	}
}
close SZ;

my %sps_sizes;
open (S, $sizesfile) or die "Couldn't open ${sizesfile}!\n";
while (<S>) {
	chomp;
	my @tmp = split(/\s+/, $_);
	$sps_sizes{$tmp[0]} = $tmp[1];
}
close S;
#print Dumper %sps_sizes;

opendir (DIR, $dir) or die "Couldn't open ${dir}!\n";
while (my $file = readdir(DIR)) {
	if ($suffix eq "merged"){
		if ($file =~ /^APCF/ && $file =~ /merged\.map\.EH$/){
			my $anc_len = my $sps_len = 0;
			my $bname = basename($file, ".merged.map.EH");
			my ($x, $sps) = split(/_/, $bname);
			print "$file -> ${sps}\n";

			my @data = @{ get_contents ("${dir}/${file}") };

			foreach my $x (0 .. $#data) {
				$anc_len += $data[$x][3] - $data[$x][2];
				$sps_len += $data[$x][5] - $data[$x][4];
			}	

			my $sps_total_len = $sps_sizes{$sps};
		
			my $cov_anc_in_sps = ($anc_len / $ancLen) * 100;
			my $anc_not_cov = $ancLen - $anc_len;
			my $sps_gen_cov = ($sps_len / $sps_total_len) * 100;
			my $sps_not_cov = $sps_total_len - $sps_len;

			my $round_AIS = sprintf("%.4f", $cov_anc_in_sps);
			my $round_SGC = sprintf("%.4f", $sps_gen_cov);

			print OUT "$sps\t$round_AIS\t$round_SGC\n";
			print OUT2 "$sps\t$round_AIS\t$anc_len\t$anc_not_cov\t$round_SGC\t$sps_len\t$sps_not_cov\n";
		}
	}
	if ($suffix eq "notMerged"){
		if ($file =~ /^APCF/ && $file =~ /map\.EH$/ && $file !~ /merged/){
			my $anc_len = my $sps_len = 0;
			my $bname = basename($file, ".map.EH");
			my ($x, $sps) = split(/_/, $bname);
			print "$file -> ${sps}\n";

			my @data = @{ get_contents ("${dir}/${file}") };

			foreach my $x (0 .. $#data) {
				$anc_len += $data[$x][3] - $data[$x][2];
				$sps_len += $data[$x][5] - $data[$x][4];
			}	

			my $sps_total_len = $sps_sizes{$sps};
		
			my $cov_anc_in_sps = ($anc_len / $ancLen) * 100;
			my $anc_not_cov = $ancLen - $anc_len;
			my $sps_gen_cov = ($sps_len / $sps_total_len) * 100;
			my $sps_not_cov = $sps_total_len - $sps_len;

			my $round_AIS = sprintf("%.4f", $cov_anc_in_sps);
			my $round_SGC = sprintf("%.4f", $sps_gen_cov);

			print OUT "$sps\t$round_AIS\t$round_SGC\n";
			print OUT2 "$sps\t$round_AIS\t$anc_len\t$anc_not_cov\t$round_SGC\t$sps_len\t$sps_not_cov\n";
		}
	}
}
close DIR;
close OUT;
close OUT2;

##### SUBROUTINES ########
sub get_contents {
	my	( $file )	= @_;
    my @contents;
    open (FH, "< $file") or die "I cannot open $file file: $!\n";
    my $x = 0;
    while (<FH>) {
    	chomp;
        next unless /\S/;
        #next if /^\s*[A-Z]+/i;
        @{$contents[$x]} = split /,/;
        ++$x;
    }
   	
	return (\@contents);
}	# ----------  end of subroutine get_contents  ----------
