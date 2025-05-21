package FilterOverlaps;
use strict;
use warnings;

use Exporter qw(import);
 
our @EXPORT_OK = qw(filterOverlaps);

#Filter overlapping HSBs after ancestor reconstruction

sub filterOverlaps {
	my ($in, $out) = @_;

open IN, $in or die "Can't open the input file\n";
open OUT, ">$out" or die "Can't create output file\n";

my @hsb = ();
my $x = 0;
while (<IN>) {
	chomp $_;
	@{$hsb[$x]} = split /\,/;
	++$x;
}

#PEC_3aPigHuman,1,775,1957677,110874328,112831230,+1,hg,chr5,chr5
#PEC_3aPigHuman,1,1958451,2509696,112840025,113391270,+1,hg,chr5,chr5


JUMP: for my $i (0..$#hsb) {
	if ($hsb[$i][1] eq $hsb[$i+1][1] and $hsb[$i][3] > $hsb[$i+1][2]) { #Reference blocks are overlapping
		splice @{$hsb[$i]}, 3, 1, $hsb[$i+1][2];
		print OUT "$hsb[$i][0]\,$hsb[$i][1]\,$hsb[$i][2]\,$hsb[$i][3]\,$hsb[$i][4]\,$hsb[$i][5]\,$hsb[$i][6]\,$hsb[$i][7]\,$hsb[$i][8]\,$hsb[$i][9]\n";
		next JUMP;
	}

	else { #Reference blocks are not overlapping
		print OUT "$hsb[$i][0]\,$hsb[$i][1]\,$hsb[$i][2]\,$hsb[$i][3]\,$hsb[$i][4]\,$hsb[$i][5]\,$hsb[$i][6]\,$hsb[$i][7]\,$hsb[$i][8]\,$hsb[$i][9]\n";		
	}
}
}

1;