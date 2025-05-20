#!/bin/bash

# Joana Damas
# April 04, 2021
#
# Place species and other ancestors in ancestor chromosomes

SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts

#REF=hg38
REF=bosTau9
#REF=mChoDid1chr
DATE=11MAR2021

MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF}
INPUTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER

FUS_RES=1 #in Mb
#FUS_REF="HSA"
FUS_REF="BTA"
#FUS_REF="CDI"

RES=300 #in Kb

#Human
# declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
# 	"euarchontoglires_${REF}_${DATE}_${RES}K" "euarchonta_${REF}_${DATE}_${RES}K" "primatomorpha_${REF}_${DATE}_${RES}K" "primata_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "BOR_${REF}" "EUA_${REF}" "EUC_${REF}" "PMT_${REF}" "PRT_${REF}")

Cattle
declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
	"laurasiatheria_${REF}_${DATE}_${RES}K" "scrotifera_${REF}_${DATE}_${RES}K" "fereuungulata_${REF}_${DATE}_${RES}K" "cetartiodactyla_${REF}_${DATE}_${RES}K" \
	"rumicetacea_${REF}_${DATE}_${RES}K" "ruminantia_${REF}_${DATE}_${RES}K")
declare -a SLIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "BOR_${REF}" "LAU_${REF}" "SCR_${REF}" "FER_${REF}" "CET_${REF}" "RCT_${REF}" "RUM_${REF}")

#Sloth
# declare -a LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "atlantogenata_${REF}_${DATE}_${RES}K" \
# 	"xenarthra_${REF}_${DATE}_${RES}K")
# declare -a SLIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "ATL_${REF}" "XEN_${REF}")


#### START COMMANDS ####
module load kentutils/302.0.0 perl-libs/5.22.1 bioperl/1.7.3
export PERL5LIB=$PERL5LIB:/share/lewinlab/jmdamas/software/perl_libs/share/perl/5.22.1

for IDX in "${!LIST[@]}"
do
	OR_DIR="${LIST[$IDX]}"
	ANC="${SLIST[$IDX]}"

	NEW_DIR="${ANC}_CHRS"

	#For placing species
	for FILE in ${MAINDIR}/${OR_DIR}/*.merged.map.EH
	do
		echo $FILE
		BNAME=$( basename $FILE )
		perl $SCRIPTDIR/scripts/placeInChrs.pl ${MAINDIR}/${NEW_DIR}/${NEW_DIR}.EH $FILE ${MAINDIR}/${NEW_DIR}/${BNAME}.chrs.EH
		if [[ -f  "${MAINDIR}/${NEW_DIR}/${NEW_DIR}_X.EH" ]]; then
			perl $SCRIPTDIR/scripts/placeInChrs.pl ${MAINDIR}/${NEW_DIR}/${NEW_DIR}_X.EH $FILE ${MAINDIR}/${NEW_DIR}/${BNAME}_X.chrs.EH
		fi
	done
	cat ${MAINDIR}/${NEW_DIR}/${NEW_DIR}.EH ${MAINDIR}/${NEW_DIR}/${NEW_DIR}_X.EH ${MAINDIR}/${NEW_DIR}/*.chrs.EH.merged > ${MAINDIR}/ANC_CHRS_${REF}/${NEW_DIR}.chrs.all.EH
	perl $SCRIPTDIR/scripts/sed_custom.pl ${MAINDIR}/ANC_CHRS_${REF}/${NEW_DIR}.chrs.all.EH
	
	#For ancestors RACFs
	for DIR in `find $MAINDIR/ANC_comp_${REF} -type d -wholename "*/${REF}_${ANC}*"`
	do
		echo $DIR

		for FILE in ${DIR}/*.merged.map.EH
		do
			echo $FILE
			BNAME=$( basename $FILE )
			perl $SCRIPTDIR/scripts/placeInChrs.pl ${MAINDIR}/${NEW_DIR}/${NEW_DIR}.EH $FILE ${MAINDIR}/${NEW_DIR}/${BNAME}.chrs.ANC.EH
			if [[ -f  "${MAINDIR}/${NEW_DIR}/${NEW_DIR}_X.EH" ]]; then
				perl $SCRIPTDIR/scripts/placeInChrs.pl ${MAINDIR}/${NEW_DIR}/${NEW_DIR}_X.EH $FILE ${MAINDIR}/${NEW_DIR}/${BNAME}_X.chrs.ANC.EH
			fi
		done
	done
	cat ${MAINDIR}/${NEW_DIR}/*.chrs.ANC.EH.merged > ${MAINDIR}/ANC_CHRS_${REF}/${NEW_DIR}.chrs.ANC.EH

	perl $SCRIPTDIR/scripts/sed_custom.pl ${MAINDIR}/ANC_CHRS_${REF}/${NEW_DIR}.chrs.ANC.EH
done