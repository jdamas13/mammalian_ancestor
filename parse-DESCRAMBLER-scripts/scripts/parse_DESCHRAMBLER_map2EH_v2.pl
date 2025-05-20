#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $directory = shift;
my $ancestor = shift;
my $rename_sps = shift;

my %names;

my %blocks;
my $flag;
my $chromo;

my %orthoBlocks;
my $id = 0;

open(N, $rename_sps) or die "Couldn't open $rename_sps!\n";
while (<N>) {
	chomp;
	my ($new_name, $old_name) = split(/\s+/, $_);
	$names{$old_name} = $new_name;
}
close N;

opendir (DIR, $directory) or die "Couldn't open ${directory}!\n";
while (my $file = readdir(DIR)) {
	if ($file =~ /map$/ && $file !~ /^Ancestor/){
        print "$file\n";
        open (IN, "$directory/$file") or die "Couldn't open ${file}!\n";
		while (<IN>) {
			chomp;
			if ($_ =~ /^>/) {
				$id = $_;
				$id =~ s/>//;
			}
			# if ($_ =~ /^APCF/){
			# 	my @temp1 = split(/\s+/, $_);
			# 	my @temp2 = split(/[.:-]+/, $temp1[0]);
			# 	$id = $temp2[1];
			# 	#print OUT "$ancestor,$temp2[1],$temp2[2],$temp2[3],";
			# 	#$flag="middle";#print "$ancestor,$temp2[1],$temp2[2],$temp2[3],";
			# }
			# elsif($_ ne "" && $_ !~ /^>/){
			elsif($_ ne "" && $_ !~ /^APCF/){
				my @temp1 = split(/\s+/, $_);
				#my @temp2 = split(/[.:-]+/, $temp1[0]);
				#my ($blockSps, $blockChr, $blockStart, $blockEnd, $blockStrand) = $_ =~ /(\D+)\.(.*)\:(\d+)\-(\d+) ([-+])/;
				#my ($blockSps, $blockChr, $blockStart, $blockEnd) = split(/[.:-]+/, $temp1[0]);
				my ($blockSps, $remaining) = split(/\./, $temp1[0], 2);
				#print "$blockSps\t$remaining\n";
				my ($blockChr, $blockStart, $blockEnd) = split(/[:-]+/, $remaining);
				my $nname = $blockSps;
				if (exists $names{$blockSps}){ $nname = $names{$blockSps} };
				my $blockStrand = $temp1[1];
				$blockChr =~ s/chr//;
				$blockChr =~ s/[Ss]uper_[Ss]caffold_//;
				$blockChr =~ s/[Ss]caffold_//;
				$blockChr =~ s/[Ss]uper_[Ss]caffold//;
				$blockChr =~ s/[Ss]caffold//;
				$blockChr =~ s/[Cc]ontig/ctg/;
				#unlink "$label\_$blockSps.txt";
				my $blockLength = $blockEnd - $blockStart;
				if (exists $orthoBlocks{$id}) {
					push @{$orthoBlocks{$id}}, ("$nname,$blockChr,$blockStart,$blockEnd,$blockStrand,$blockLength");				
				}
				else {
					$orthoBlocks{$id} = ["$nname,$blockChr,$blockStart,$blockEnd,$blockStrand,$blockLength"];				
				}
			}
		}
		close IN;

		open (IN, "$directory/$file") or die "Couldn't open ${file}!\n";
		open (OUT, ">${directory}/${file}.EH") or die "Couldn't create ${file}.EH!\n";
 		my ($carID, $carStart, $carEnd, $carLen) = 0;
 		while (<IN>) {
 			chomp;
 			if ($_ =~ /^>/) {
 				$id = $_;
 				$id =~ s/>//;
 			}
 			elsif ($_ =~ /^APCF/){
 			 	my @temp1 = split(/\s+/, $_);
 			 	#my @temp2 = split(/[.:-]+/, $temp1[0]);
			 	#$carID = $temp2[1];
			 	#$carEnd = $carStart = 0;
			 	my ($carSps, $carID, $carStart, $carEnd) = split(/[.:-]+/, $temp1[0]);
			 	#print OUT "$ancestor,$temp2[1],$temp2[2],$temp2[3],";
				#$flag="middle";#print "$ancestor,$temp2[1],$temp2[2],$temp2[3],";
				$carLen = $carEnd - $carStart;
				my ($tarStart, $tarEnd, $tarLen) = 0;
				$tarStart=$carStart;
				my $number = scalar @{$orthoBlocks{$id}};
				#print "$id $number\n";
				if ($number == 1 ) {
					my @tmp = split /\,/, @{$orthoBlocks{$id}}[0];
					print OUT "$ancestor,$carID,$carStart,$carEnd,$tmp[2],$tmp[3],$tmp[4]1,$tmp[0],$tmp[1],$tmp[1]\n";					
 				}	
				else {
					my $frac1 = 0;
					my $frac2 = 0;
					foreach my $i (0..$number-1) {
						my @tmp2 = split /\,/, @{$orthoBlocks{$id}}[$i];
						$tarLen += $tmp2[5];
					}
					my $value = 0;
					if ($tarLen < $carLen) {
						$value = int((abs($tarLen - $carLen))/($number + 1));
					}
					foreach my $l (0..$number-1) {
						if ($l == 0 ) {
							my @tmp3 = split /\,/, @{$orthoBlocks{$id}}[$l];
							$tarStart+=$value;
							$frac1 = $tmp3[5]/$tarLen;
							$tarEnd = $tarStart + int($carLen * $frac1);
							#print "$sps\t$frac1\t$tarStart\t$tarEnd\t$tmp3[4]\n";
							print OUT "$ancestor,$carID,$tarStart,$tarEnd,$tmp3[2],$tmp3[3],$tmp3[4]1,$tmp3[0],$tmp3[1],$tmp3[1]\n";
						}
						else {
							my @tmp4 = split /\,/, @{$orthoBlocks{$id}}[$l];
							$tarStart= $tarEnd + $value;
							$frac2 = $tmp4[5]/$tarLen;
							$tarEnd = $tarStart + int($carLen * $frac2);
							if ($tarEnd > $carEnd){ $tarEnd = $carEnd; }
							print OUT "$ancestor,$carID,$tarStart,$tarEnd,$tmp4[2],$tmp4[3],$tmp4[4]1,$tmp4[0],$tmp4[1],$tmp4[1]\n";
						}
					}
				}
			}
		}
		close IN;
		close OUT;
		#print Dumper (\%orthoBlocks);
		undef %orthoBlocks;
	}
}
closedir DIR;

exit;
