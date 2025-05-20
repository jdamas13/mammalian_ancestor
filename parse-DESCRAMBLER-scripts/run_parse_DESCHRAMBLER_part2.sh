#!/bin/bash

# Joana Damas
# June 25, 2020
#
# Part 2 of the parse DESCHRAMBLER pipeline
# Parse ancestors pairwise

SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts
INPUTDIR=/share/lewinlab/jmdamas/software/DESCHRAMBLER

FUS_RES=1 #in Mb
#FUS_REF="HSA"
#FUS_REF="BTA"
FUS_REF="CDI"

#REF=hg38 
#REF=bosTau9
REF=mChoDid1chr
RES=300 #in Kb

DATE=11MAR2021

MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF}
#MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}

#Human
# declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
# 	"euarchontoglires_${REF}_${DATE}_${RES}K" "euarchonta_${REF}_${DATE}_${RES}K" "primatomorpha_${REF}_${DATE}_${RES}K" "primata_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "BOR_${REF}" "EUA_${REF}" "EUC_${REF}" "PMT_${REF}" "PRT_${REF}")

#Cattle
# declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
# 	"laurasiatheria_${REF}_${DATE}_${RES}K" "scrotifera_${REF}_${DATE}_${RES}K" "fereuungulata_${REF}_${DATE}_${RES}K" "cetartiodactyla_${REF}_${DATE}_${RES}K" \
# 	"rumicetacea_${REF}_${DATE}_${RES}K" "ruminantia_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "BOR_${REF}" "LAU_${REF}" "SCR_${REF}" "FER_${REF}" "CET_${REF}" "RCT_${REF}" "RUM_${REF}")

#Sloth
declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "atlantogenata_${REF}_${DATE}_${RES}K" \
	"xenarthra_${REF}_${DATE}_${RES}K")
declare -a SLIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "ATL_${REF}" "XEN_${REF}")

ANCDB="/share/lewinlab/jmdamas/ancestor_DB.txt"
#GENES="$MAINDIR/hg38.genes.15AUG2019.tsv.unique.prot_coding"

module load kentutils/302.0.0 perl-libs/5.22.1 bioperl/1.7.3

for IDX in "${!LIST[@]}"
do
	for IDX2 in "${!LIST[@]}"
	do
		if [[ $IDX != $IDX2 ]]; then
			ANC1="${LIST[$IDX]}"
			ANC2="${LIST[$IDX2]}"
			SANC1="${SLIST[$IDX]}"
			SANC2="${SLIST[$IDX2]}"
			echo "Starting" $SANC1 $SANC2
			echo "Place ANCESTOR 2 in ANCESTOR 1 - Jaebum's scripts"
			perl $SCRIPTDIR/scripts/jaebum_cmp/AncCmp.pl "${RES}000" "${SANC1}" $MAINDIR/$ANC1 "${SANC2}" $MAINDIR/$ANC2 "$MAINDIR/${REF}_${SANC1}_${SANC2}"

			echo "Convert DESCHRAMBLER format from step above"
			perl $SCRIPTDIR/scripts/db2eh.pl "$MAINDIR/${REF}_${SANC1}_${SANC2}/dbfile.txt" "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "${RES}000"
			wait

			echo "DESCHRAMBLER fusions"
			perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" $ANCDB "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.${FUS_RES}M.FUSIONS" ${FUS_RES}000000 $FUS_REF
			wait
			perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" $ANCDB "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.0.FUSIONS" 0 $FUS_REF
			wait
			echo "CREATING EH UPLOAD FILE"
			perl $SCRIPTDIR/scripts/parse_EHfile_mysql.pl "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.mysql"
			wait

			echo "Verify RACF adjacency support"
			perl $SCRIPTDIR/scripts/mergeRACFs.pl "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.adjSupport"
			wait

			echo "Add letter to EH UPLOAD FILE"
			perl $SCRIPTDIR/scripts/add_letter_scaffv2.pl "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${REF}_${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.letter"
			wait

			echo $SANC1 $SANC2 "- done!"
		fi
	done
done