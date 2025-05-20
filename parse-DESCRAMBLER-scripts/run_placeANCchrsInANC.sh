#!/bin/bash

# Joana Damas
# April 14, 2021
#
# Place ancestor chromosomes in ancestor chromosomes

SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts
INPUTDIR=/share/lewinlab/jmdamas/software/DESCHRAMBLER

FUS_RES=1 #in Mb
#FUS_REF="HSA"
#FUS_REF="CDI"
FUS_REF="BTA"

#REF=hg38 
#REF=mChoDid1chr
REF=bosTau9
RES=300 #in Kb

DATE=11MAR2021

MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF}

#Human
# declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
# 	"euarchontoglires_${REF}_${DATE}_${RES}K" "euarchonta_${REF}_${DATE}_${RES}K" "primatomorpha_${REF}_${DATE}_${RES}K" "primata_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "BOR_${REF}_CHRS" "EUA_${REF}_CHRS" "EUC_${REF}_CHRS" "PMT_${REF}_CHRS" "PRT_${REF}_CHRS")


#Cattle
declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
	"laurasiatheria_${REF}_${DATE}_${RES}K" "scrotifera_${REF}_${DATE}_${RES}K" "fereuungulata_${REF}_${DATE}_${RES}K" "cetartiodactyla_${REF}_${DATE}_${RES}K" \
	"rumicetacea_${REF}_${DATE}_${RES}K" "ruminantia_${REF}_${DATE}_${RES}K")
declare -a SLIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "BOR_${REF}" "LAU_${REF}" "SCR_${REF}" "FER_${REF}" "CET_${REF}" "RCT_${REF}" "RUM_${REF}")

#Sloth
# declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "atlantogenata_${REF}_${DATE}_${RES}K" \
# 	"xenarthra_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "ATL_${REF}_CHRS" "XEN_${REF}_CHRS")

# declare -a LIST=("theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "atlantogenata_${REF}_${DATE}_${RES}K" \
# 	"xenarthra_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("THE_${REF}_CHRS" "EUT_${REF}_CHRS" "ATL_${REF}_CHRS" "XEN_${REF}_CHRS")

ANCDB="/share/lewinlab/jmdamas/ancestor_DB.txt"
#GENES="$MAINDIR/${REF}.genes.15AUG2019.tsv.unique.prot_coding"

module load kentutils/302.0.0 perl-libs/5.22.1 bioperl/1.7.3

rm ${MAINDIR}/ANC_CHRS_${REF}/ANC.CHRS.inRACF.EH
for IDX in "${!LIST[@]}"
do
	for IDX2 in "${!LIST[@]}"
	do
		if [[ $IDX != $IDX2 ]]; then
			ANC1="${LIST[$IDX]}"
			ANC2="${LIST[$IDX2]}"
			SANC1="${SLIST[$IDX]}"
			SANC2="${SLIST[$IDX2]}"
			echo "Starting" $ANC1 $SANC2
			echo "Place ANCESTOR 2 in ANCESTOR 1 - Jaebum's scripts"
			perl $SCRIPTDIR/scripts/jaebum_cmp/AncCmp.pl "${RES}000" "${ANC1}" "${MAINDIR}/${ANC1}" "${SANC2}" "${MAINDIR}/${SANC2}" "$MAINDIR/${ANC1}_${SANC2}"

			echo "Convert DESCHRAMBLER format from step above"
			perl $SCRIPTDIR/scripts/db2eh.pl "$MAINDIR/${ANC1}_${SANC2}/dbfile.txt" "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "${RES}000"
			wait

			echo "DESCHRAMBLER fusions"
			perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" $ANCDB "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.${FUS_RES}M.FUSIONS" ${FUS_RES}000000 $FUS_REF
			wait
			perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" $ANCDB "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.0.FUSIONS" 0 $FUS_REF
			wait
			echo "CREATING EH UPLOAD FILE"
			perl $SCRIPTDIR/scripts/parse_EHfile_mysql.pl "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.mysql"
			wait

			echo "Verify RACF adjacency support"
			perl $SCRIPTDIR/scripts/mergeRACFs.pl "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.adjSupport"
			wait

			echo "Add letter to EH UPLOAD FILE"
			perl $SCRIPTDIR/scripts/add_letter_scaffv2.pl "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.letter"
			wait

			cat $MAINDIR/${ANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH >> ${MAINDIR}/ANC_CHRS_${REF}/ANC.CHRS.inRACF.EH
			echo $ANC1 $SANC2 "- done!"
		fi
	done
done

perl $SCRIPTDIR/scripts/rename_and_sed.pl ${MAINDIR}/ANC_CHRS_${REF}/ANC.CHRS.inRACF.EH