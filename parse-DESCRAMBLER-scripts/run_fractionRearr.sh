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
DATE=11MAR2021

MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF}
INPUTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts

RES=300 #in Kb

REF_ANC="MAM_${REF}_CHRS"
REFDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF}/${REF_ANC}
#Human
#declare -a LIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "BOR_${REF}_CHRS" "EUA_${REF}_CHRS" "EUC_${REF}_CHRS" "PMT_${REF}_CHRS" "PRT_${REF}_CHRS")

#Cattle
declare -a LIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "BOR_${REF}_CHRS" "LAU_${REF}_CHRS" "SCR_${REF}_CHRS" "FER_${REF}_CHRS" "CET_${REF}_CHRS" "RCT_${REF}_CHRS" "RUM_${REF}_CHRS")

#Sloth
#declare -a LIST=("MAM_${REF}_CHRS" "THE_${REF}_CHRS" "EUT_${REF}_CHRS" "ATL_${REF}_CHRS" "XEN_${REF}_CHRS")

rm $REFDIR/${REF_ANC}.all.fraction
rm $REFDIR/${REF_ANC}.all.fraction.inter
#For species
for FILE in `find $REFDIR -wholename '*.merged.map.EH.chrs.EH.merged'`
do 
	echo $FILE
	#perl $INPUTDIR/scripts/EH2fraction_byblocksize_NEW_orient.pl $FILE $REFDIR/${REF_ANC}.sizes ${FILE}.fraction; wait
	perl $INPUTDIR/scripts/EH2fraction_byblocksize_NEW_orient_12AUG2021.pl $FILE $REFDIR/${REF_ANC}.sizes ${FILE}.fraction; wait
	cat ${FILE}.fraction >> $REFDIR/${REF_ANC}.all.fraction; wait
	perl $INPUTDIR/scripts/EH2fraction_byblocksize_NEW_orient_INTER.pl $FILE $REFDIR/${REF_ANC}.sizes ${FILE}.fraction.inter 0; wait
	cat ${FILE}.fraction.inter >> $REFDIR/${REF_ANC}.all.fraction.inter; wait
	perl $INPUTDIR/scripts/EH2fraction_byblocksize_NEW_orient_INTER.pl $FILE $REFDIR/${REF_ANC}.sizes ${FILE}.fraction.1M.inter 1000000; wait
	cat ${FILE}.fraction.1M.inter >> $REFDIR/${REF_ANC}.all.fraction.1M.inter; wait
done

#For ancestors

for IDX in "${!LIST[@]}"
do
	ANC="${LIST[$IDX]}"
	if [[ $ANC != "${REF_ANC}" ]]; then
		FILE="$MAINDIR/${REF_ANC}_${ANC}/APCF_${ANC}.merged.map.EH"
		echo $FILE
		#perl $INPUTDIR/scripts/EH2fraction_byblocksize_NEW_orient.pl $FILE $REFDIR/${REF_ANC}.sizes ${FILE}.fraction; wait
		perl $INPUTDIR/scripts/EH2fraction_byblocksize_NEW_orient_12AUG2021.pl $FILE $REFDIR/${REF_ANC}.sizes ${FILE}.fraction; wait
		cat ${FILE}.fraction >> $REFDIR/${REF_ANC}.all.fraction; wait
		perl $INPUTDIR/scripts/EH2fraction_byblocksize_NEW_orient_INTER.pl $FILE $REFDIR/${REF_ANC}.sizes ${FILE}.fraction.inter 0; wait
		cat ${FILE}.fraction.inter >> $REFDIR/${REF_ANC}.all.fraction.inter; wait
		perl $INPUTDIR/scripts/EH2fraction_byblocksize_NEW_orient_INTER.pl $FILE $REFDIR/${REF_ANC}.sizes ${FILE}.fraction.1M.inter 1000000; wait
		cat ${FILE}.fraction.1M.inter >> $REFDIR/${REF_ANC}.all.fraction.1M.inter; wait
	fi
done

sort $REFDIR/${REF_ANC}.all.fraction | uniq -u > tmp
mv tmp $REFDIR/${REF_ANC}.all.fraction

sort $REFDIR/${REF_ANC}.all.fraction.inter | uniq -u > tmp
mv tmp $REFDIR/${REF_ANC}.all.fraction.inter

sort $REFDIR/${REF_ANC}.all.fraction.1M.inter | uniq -u > tmp
mv tmp $REFDIR/${REF_ANC}.all.fraction.1M.inter