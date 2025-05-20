#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

#					0	1    2     3   4         5       6     7       8    9	
my $input = shift; #ANC,RACF,start,end,scafstart,scafend,orien,species,scaf,scaf - needs to be without letter
my $output = shift;

my @comp_gens;
my @ref_gens;
open (IN, $input) or die "Couldn't open $input!\n";
while(<IN>){
	chomp;
	my @t = split(/,/, $_);
	my $r_gen = $t[0];
	my $c_gen = $t[7];
	#print "$r_gen\t$c_gen\n";
	#print "$r_gen\n";
	$c_gen =~ s/_loose$//g;
	$c_gen =~ s/_ucscpar$//g;
	$c_gen =~ s/_ucsc$//g;
	push (@comp_gens, $c_gen);
	push (@ref_gens, $r_gen);
}
close IN;

my @unique_comp = uniq(@comp_gens);
my @unique_refs = uniq(@ref_gens);

open(OUT, ">$output") or die "Couldn't create $output!\n";
## For REF_GEN 

print OUT "
DROP PROCEDURE IF EXISTS select_or_insert;
DELIMITER \/\/
CREATE PROCEDURE select_or_insert ( IN gen VARCHAR(50) )
	BEGIN
		IF EXISTS (SELECT * FROM CONSENSUS WHERE REF_GEN=gen) THEN
			SELECT DISTINCT(REF_GEN) FROM CONSENSUS WHERE REF_GEN=gen; 
			CREATE TEMPORARY TABLE tmp_size SELECT REF_GEN as GEN, REF_CHR as CHR, max(END_BP) as SIZE from CONSENSUS where REF_GEN=gen group by REF_GEN, REF_CHR;
		ELSE	
			SELECT DISTINCT(COMP_GEN) FROM CONSENSUS WHERE COMP_GEN=gen; 
   			CREATE TEMPORARY TABLE tmp_size SELECT COMP_GEN as GEN, COMP_CHR as CHR, max(MODIFIED_ORDER_END) as SIZE from CONSENSUS where COMP_GEN=gen group by COMP_GEN, COMP_CHR;
		END IF;
	END \/\/
DELIMITER ;
";

## For each COMP_GEN
foreach my $comp_g (@unique_comp) {
	print OUT "
DELETE FROM CHROMOSOME_SIZE WHERE GEN='$comp_g';
CALL select_or_insert('$comp_g');
INSERT INTO CHROMOSOME_SIZE SELECT * FROM tmp_size WHERE GEN='$comp_g';
DROP TABLE tmp_size;
";
}

foreach my $ref_g (@unique_refs){
	print OUT "
DELETE FROM CHROMOSOME_SIZE WHERE GEN = \"$ref_g\";
INSERT INTO CHROMOSOME_SIZE SELECT REF_GEN as GEN, REF_CHR as CHR, max(END_BP) as SIZE from CONSENSUS where REF_GEN = \"$ref_g\" group by REF_GEN, REF_CHR;";
}
close OUT;

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}