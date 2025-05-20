#!/bin/bash

# Joana Damas
# April 14, 2021
#
# Place ancestor chromosomes in ancestor chromosomes

#REF=hg38
#REF=bosTau9
REF=mChoDid1chr
DATE=11MAR2021

SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts

MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF}
INPUTDIR=/share/lewinlab/jmdamas/software/DESCHRAMBLER

FUS_RES=1 #in Mb
#FUS_REF="HSA"
#FUS_REF="BTA"
FUS_REF="CDI"

RES=300 #in Kb

#Human
#declare -a SLIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "BOR_${REF}_CHRS" "EUA_${REF}_CHRS" "EUC_${REF}_CHRS" "PMT_${REF}_CHRS" "PRT_${REF}_CHRS")

#Cattle
#declare -a SLIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "BOR_${REF}_CHRS" "LAU_${REF}_CHRS" "SCR_${REF}_CHRS" "FER_${REF}_CHRS" "CET_${REF}_CHRS" "RCT_${REF}_CHRS" "RUM_${REF}_CHRS")

#Sloth
declare -a SLIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "ATL_${REF}_CHRS" "XEN_${REF}_CHRS")


ANCDB="/share/lewinlab/jmdamas/ancestor_DB.txt"
#GENES="$MAINDIR/${REF}.genes.15AUG2019.tsv.unique.prot_coding"

module load kentutils/302.0.0 perl-libs/5.22.1 bioperl/1.7.3
export PERL5LIB=$PERL5LIB:/share/lewinlab/jmdamas/software/perl_libs/share/perl/5.22.1
for IDX in "${!SLIST[@]}"
do
	ANC="${SLIST[$IDX]}"
	echo "DESCHRAMBLER fusions"
	perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH.chrs.EH.merged" $ANCDB "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH.chrs.EH.merged.${FUS_RES}M.FUSIONS" ${FUS_RES}000000 $FUS_REF
	wait
	perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH.chrs.EH.merged" $ANCDB "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH.chrs.EH.merged.0.FUSIONS" 0 $FUS_REF
	wait

	if [[ $REF != "hg38" ]]; then
		perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/$ANC/APCF_hg38.merged.map.EH.chrs.EH.merged" $ANCDB "$MAINDIR/$ANC/APCF_hg38.merged.map.EH.chrs.EH.merged.${FUS_RES}M.FUSIONS" ${FUS_RES}000000 $FUS_REF
		wait
		perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/$ANC/APCF_hg38.merged.map.EH.chrs.EH.merged" $ANCDB "$MAINDIR/$ANC/APCF_hg38.merged.map.EH.chrs.EH.merged.0.FUSIONS" 0 $FUS_REF
		wait
	fi
			
done
