#!/bin/bash

# Joana Damas
# December 22, 2021
#
# Gets overlaps between blocks in reconstructions with different references

module load bedtools2/2.29.2

SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts
INPUTDIR=/share/lewinlab/jmdamas/software/DESCHRAMBLER

DATE=11MAR2021
#echo $DATE
RES=300 #in KB for DESCHRAMBLER

RES2=300000 #in bp for analysis 
#RES2=1000000 #in bp for analysis 

declare -a LIST=("hg38" "bosTau9" "mChoDid1chr")
SPS="hg38"
#ANC="boreoeutheria" #"mammalia" "theria" "eutheria" "boreoeutheria"
ANC="MAM" #"MAM" "THE" "EUT" "BOR"

#OUTDIR=$SCRIPTDIR/${ANC}_diffRefs_${BLOCK_OVERLAP}
OUTDIR=$SCRIPTDIR/${ANC}_diffRefs_blocksOverlap_22DEC2021

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
			#REFFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF1}/${ANC}_${REF1}_${DATE}_${RES}K/APCF_${SPS}.merged.map.EH
			#TARFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF2}/${ANC}_${REF2}_${DATE}_${RES}K/APCF_${SPS}.merged.map.EH
			REFFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF1}/${ANC}_${REF1}_CHRS/APCF_${SPS}.merged.map.EH.chrs.EH.merged
			TARFILE=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF2}/${ANC}_${REF2}_CHRS/APCF_${SPS}.merged.map.EH.chrs.EH.merged
			#label,chr,start,end,sstart,send,or,slabel,schr,schr

			awk -F',' '{print $9"\t"$5"\t"$6}' $REFFILE > "$OUTDIR/${ANC}_${REF1}_${SPS}.bed"
			awk -F',' '{print $9"\t"$5"\t"$6}' $TARFILE > "$OUTDIR/${ANC}_${REF2}_${SPS}.bed"

			OUTFILE=$OUTDIR/${ANC}_${REF1}_vs_${REF2}_${SPS}.blockOverlap.out

			bedtools intersect -F 0.5 -wa -wb -a "$OUTDIR/${ANC}_${REF1}_${SPS}.bed" -b "$OUTDIR/${ANC}_${REF2}_${SPS}.bed" > $OUTFILE
			bedtools intersect -F 0.5 -C -a "$OUTDIR/${ANC}_${REF1}_${SPS}.bed" -b "$OUTDIR/${ANC}_${REF2}_${SPS}.bed"> ${OUTFILE}.count
			bedtools coverage -F 0.5 -a "$OUTDIR/${ANC}_${REF1}_${SPS}.bed" -b "$OUTDIR/${ANC}_${REF2}_${SPS}.bed"> ${OUTFILE}.cov

		fi
	done
done