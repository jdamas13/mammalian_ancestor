#!/bin/bash

# Joana Damas
# April 14, 2021
#
# Place ancestor chromosomes in ancestor chromosomes

#REF=hg38
REF=bosTau9
#REF=mChoDid1chr
DATE=11MAR2021

SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts

MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF}
INPUTDIR=/share/lewinlab/jmdamas/software/DESCHRAMBLER

FUS_RES=1 #in Mb
#FUS_REF="HSA"
FUS_REF="BTA"
#FUS_REF="CDI"

RES=300 #in Kb

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


ANCDB="/share/lewinlab/jmdamas/ancestor_DB.txt"
#GENES="$MAINDIR/${REF}.genes.15AUG2019.tsv.unique.prot_coding"

module load kentutils/302.0.0 perl-libs/5.22.1 bioperl/1.7.3
export PERL5LIB=$PERL5LIB:/share/lewinlab/jmdamas/software/perl_libs/share/perl/5.22.1
for IDX in "${!LIST[@]}"
do
	ANC="${LIST[$IDX]}"
	SANC="${SLIST[$IDX]}"
	## This won't work when changing orientations
	#Careful with RUM ancestor APCF 10 and 15 #
	if [[ $SANC != "ATL_mChoDid1chr_CHRS" && $SANC != "CET_bosTau9_CHRS" && $SANC != "RCT_bosTau9_CHRS" && $SANC != "RUM_bosTau9_CHRS" && $SANC != "MAM_hg38_CHRS" && $SANC != "THE_hg38_CHRS" && $SANC != "MAM_mChoDid1chr_CHRS" ]]; then
		perl $SCRIPTDIR/scripts/createAncestorAPCF_chr.pl "${MAINDIR}/${ANC}/Ancestor.APCF" "${MAINDIR}/${SANC}/${SANC}.EH" "${MAINDIR}/${SANC}/Ancestor.APCF"
		wait
		mkdir -p ${MAINDIR}/${SANC}/SFs
		cp ${MAINDIR}/${ANC}/SFs/block_list.txt ${MAINDIR}/${SANC}/SFs/block_list.txt
		cp ${MAINDIR}/${ANC}/SFs/block_consscores.txt ${MAINDIR}/${SANC}/SFs/block_consscores.txt
	fi
done

rm ${MAINDIR}/ANC_CHRS_${REF}/ANC.CHRS.CHRS.EH
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
			perl $SCRIPTDIR/scripts/jaebum_cmp/AncCmp.pl "${RES}000" "${SANC1}" "${MAINDIR}/${SANC1}" "${SANC2}" "${MAINDIR}/${SANC2}" "$MAINDIR/${SANC1}_${SANC2}"

			echo "Convert DESCHRAMBLER format from step above"
			perl $SCRIPTDIR/scripts/db2eh.pl "$MAINDIR/${SANC1}_${SANC2}/dbfile.txt" "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "${RES}000"
			wait

			echo "DESCHRAMBLER fusions"
			perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" $ANCDB "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.${FUS_RES}M.FUSIONS" ${FUS_RES}000000 $FUS_REF
			wait
			perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" $ANCDB "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.0.FUSIONS" 0 $FUS_REF
			wait
			echo "CREATING EH UPLOAD FILE"
			perl $SCRIPTDIR/scripts/parse_EHfile_mysql.pl "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.mysql"
			wait

			echo "Verify RACF adjacency support"
			perl $SCRIPTDIR/scripts/mergeRACFs.pl "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.adjSupport"
			wait

			echo "Add letter to EH UPLOAD FILE"
			perl $SCRIPTDIR/scripts/add_letter_scaffv2.pl "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH" "$MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH.letter"
			wait

			cat $MAINDIR/${SANC1}_${SANC2}/APCF_${SANC2}.merged.map.EH >> ${MAINDIR}/ANC_CHRS_${REF}/ANC.CHRS.CHRS.EH
			echo $SANC1 $SANC2 "- done!"
		fi
	done
done

perl $SCRIPTDIR/scripts/sed_custom.pl ${MAINDIR}/ANC_CHRS_${REF}/ANC.CHRS.CHRS.EH