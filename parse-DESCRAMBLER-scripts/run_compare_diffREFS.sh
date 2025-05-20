#!/bin/bash

# Joana Damas
# July 23, 2021
#
# Runs adjacecny comparison for multiple references reconstructions

SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts
INPUTDIR=/share/lewinlab/jmdamas/software/DESCHRAMBLER

DATE=11MAR2021
#echo $DATE
RES=300 #in KB for DESCHRAMBLER

#RES2=300000 #in bp for analysis 
RES2=1000000 #in bp for analysis 

declare -a LIST=("hg38" "bosTau9" "mChoDid1chr")
SPS="hg38"
ANC="boreoeutheria" #"mammalia" "theria" "eutheria" "boreoeutheria"
#ANC="BOR" #"MAM" "THE" "EUT" "BOR"
#BLOCK_OVERLAP=0.8 #minimum 80% block overlap
BLOCK_OVERLAP=0.5 #minimum 50% block overlap

#OUTDIR=$SCRIPTDIR/${ANC}_diffRefs_${BLOCK_OVERLAP}
OUTDIR=$SCRIPTDIR/${ANC}_diffRefs_1Mb_50_20DEC2021

mkdir -p $OUTDIR
#echo $OUTDIR

for IDX in "${!LIST[@]}"
do
	for IDX2 in "${!LIST[@]}"
	do
		if [[ $IDX != $IDX2 ]]; then
			REF1="${LIST[$IDX]}"
			REF2="${LIST[$IDX2]}"
			echo $ANC - $REF1 vs $REF2 - $SPS
			REFFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF1}/${ANC}_${REF1}_${DATE}_${RES}K/APCF_${SPS}.merged.map.EH
			TARFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF2}/${ANC}_${REF2}_${DATE}_${RES}K/APCF_${SPS}.merged.map.EH
			#REFFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF1}/${ANC}_${REF1}_CHRS/APCF_${SPS}.merged.map.EH.chrs.EH.merged
			#TARFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF2}/${ANC}_${REF2}_CHRS/APCF_${SPS}.merged.map.EH.chrs.EH.merged

			# REFFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF1}/${ANC}_${REF1}_${DATE}_${RES}K/APCF_${REF1}.map.EH
			# TARFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF2}/${ANC}_${REF2}_${DATE}_${RES}K/APCF_${REF1}.map.EH
			OUTFILE=$OUTDIR/${ANC}_${REF1}_vs_${REF2}_${SPS}.comp.adjs
			OUTADJ=$OUTDIR/${ANC}_${REF1}_${SPS}.all.adjs

			perl $SCRIPTDIR/scripts/compare_Adjacencies_20DEC2021.pl $REFFILE $TARFILE $OUTFILE $OUTADJ $BLOCK_OVERLAP $RES2; wait;
		fi
	done
done