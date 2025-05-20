#!/bin/bash

SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts

#REF=hg38
REF=bosTau9
#REF=mChoDid1chr

DIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_11MAR2021_${REF}


mkdir $DIR/ANC_CHRS_${REF}
mkdir $DIR/ANC_comp_${REF}

bash $SCRIPTDIR/run_placeANCchrsInANCchrs.sh
bash $SCRIPTDIR/run_placeInAnc.sh

rm $DIR/ANC_CHRS_${REF}/CHRS.${REF}.EH
cat $DIR/ANC_CHRS_${REF}/* > $DIR/ANC_CHRS_${REF}/CHRS.${REF}.EH