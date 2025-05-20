#!/bin/bash

# Joana Damas
# April 14, 2021
#
# Place ancestor chromosomes in ancestor chromosomes
SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts

#REF=hg38 
REF=bosTau9
#REF=mChoDid1chr
echo $REF

MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_11MAR2021_${REF}
#MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_11MAR2021
INPUTDIR=/share/lewinlab/jmdamas/software/DESCHRAMBLER

RES=300 #in Kb

DATE=11MAR2021

#Human
# declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
# 	"euarchontoglires_${REF}_${DATE}_${RES}K" "euarchonta_${REF}_${DATE}_${RES}K" "primatomorpha_${REF}_${DATE}_${RES}K" "primata_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "BOR_${REF}_CHRS" "EUA_${REF}_CHRS" "EUC_${REF}_CHRS" "PMT_${REF}_CHRS" "PRT_${REF}_CHRS")

#Cattle
declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
	"laurasiatheria_${REF}_${DATE}_${RES}K" "scrotifera_${REF}_${DATE}_${RES}K" "fereuungulata_${REF}_${DATE}_${RES}K" "cetartiodactyla_${REF}_${DATE}_${RES}K" \
	"rumicetacea_${REF}_${DATE}_${RES}K" "ruminantia_${REF}_${DATE}_${RES}K")
declare -a SLIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "BOR_${REF}_CHRS" "LAU_${REF}_CHRS" "SCR_${REF}_CHRS" "FER_${REF}_CHRS" "CET_${REF}_CHRS" "RCT_${REF}_CHRS" "RUM_${REF}_CHRS")

#Sloth
# declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "atlantogenata_${REF}_${DATE}_${RES}K" \
# 	"xenarthra_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "ATL_${REF}_CHRS" "XEN_${REF}_CHRS")


module load kentutils/302.0.0 perl-libs/5.22.1 bioperl/1.7.3
export PERL5LIB=$PERL5LIB:/share/lewinlab/jmdamas/software/perl_libs/share/perl/5.22.1

OUTFILE=$MAINDIR/to_EH_hg38_${REF}.EH
rm $OUTFILE

LEN=${#LIST[@]}
for IDX in "${!LIST[@]}"
do
	# if [[ $IDX == $(( $LEN - 1 )) ]]; then
	# 	#Get species pairwise blocks in reference coordinates
	# 	for FILE in `find $MAINDIR/$ANC/SFs -wholename '*.processed.segs.EH.merged'`
	# 	do 
	# 		#echo $FILE
	# 		cat $FILE >> $OUTFILE
	# 	done
	# fi
	ANC="${LIST[$IDX]}"
	SANC="${SLIST[$IDX]}"

	#Get ancestor RACFs in human coordinates
	INFILE=$MAINDIR/$ANC/APCF_hg38.merged.map.EH
	awk -F',' '{print $8","$9","$5","$6","$3","$4","$7","$1","$2","$2}' $INFILE >> $OUTFILE

	#Get ancestor CHRS in human coordinates
	INFILE2=$MAINDIR/$SANC/APCF_hg38.merged.map.EH.chrs.EH.merged
	awk -F',' '{print $8","$9","$5","$6","$3","$4","$7","$1","$2","$2}' $INFILE2 >> $OUTFILE
done

#Rename species and ancestors
perl $SCRIPTDIR/scripts/rename_and_sed.pl $OUTFILE hg38_DESC $SCRIPTDIR/species_rename.txt
#Create mysql file
perl $SCRIPTDIR/scripts/parse_EHfile_mysql.pl $OUTFILE ${OUTFILE}.mysql