#!/bin/bash

# Joana Damas
# June 17, 2020
#
# Part 1 of the parse DESCHRAMBLER pipeline
# Parse individual ancestors

FUS_RES=1 #in Mb
FUS_REF="HSA"
#FUS_REF="BTA"
#FUS_REF="CDI"

#REF=hg38 
REF=bosTau9
#REF=mChoDid1chr
RES=300 #in Kb
#RES=5 #in Kb

DATE=11MAR2021
SCRIPTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER_parse_scripts
MAINDIR=/share/lewinlab/jmdamas/MAMMAL_RECONS_${DATE}_${REF}
INPUTDIR=/share/lewinlab/jmdamas/DESCHRAMBLER

#Human
# declare -a ANC_LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" "euarchontoglires_${REF}_${DATE}_${RES}K" "euarchonta_${REF}_${DATE}_${RES}K" "primatomorpha_${REF}_${DATE}_${RES}K" "primata_${REF}_${DATE}_${RES}K")
# declare -a SANC_LIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "BOR_${REF}" "EUA_${REF}" "EUC_${REF}" "PMT_${REF}" "PRT_${REF}")

#Cattle
declare -a ANC_LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "boreoeutheria_${REF}_${DATE}_${RES}K" \
	"laurasiatheria_${REF}_${DATE}_${RES}K" "scrotifera_${REF}_${DATE}_${RES}K" "fereuungulata_${REF}_${DATE}_${RES}K" "cetartiodactyla_${REF}_${DATE}_${RES}K" "rumicetacea_${REF}_${DATE}_${RES}K" "ruminantia_${REF}_${DATE}_${RES}K")
declare -a SANC_LIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "BOR_${REF}" \
	"LAU_${REF}" "SCR_${REF}" "FER_${REF}" "CET_${REF}" "RCT_${REF}" "RUM_${REF}")

#Sloth
# declare -a ANC_LIST=("mammalia_${REF}_${DATE}_${RES}K" "theria_${REF}_${DATE}_${RES}K" "eutheria_${REF}_${DATE}_${RES}K" "atlantogenata_${REF}_${DATE}_${RES}K" "xenarthra_${REF}_${DATE}_${RES}K")
# declare -a SANC_LIST=("MAM_${REF}" "THE_${REF}" "EUT_${REF}" "ATL_${REF}" "XEN_${REF}")

ANCDB="/share/lewinlab/jmdamas/ancestor_DB.txt"
GENES="$SCRIPTDIR/annotations/hg38.genes.15AUG2019.tsv.unique.prot_coding"
REFGENOME="/share/lewinlab/jmdamas/genomes/mammal_recon/${REF}.2bit.fa"

#### START COMMANDS ####
module load kentutils/302.0.0 perl-libs/5.22.1 bioperl/1.7.3
export PERL5LIB=$PERL5LIB:/share/lewinlab/jmdamas/software/perl_libs/share/perl/5.22.1


for IDX in "${!ANC_LIST[@]}"
do
	ANC=${ANC_LIST[$IDX]}
	SANC=${SANC_LIST[$IDX]}

	# echo "Convert DESCHRAMBLER format"
	# perl $SCRIPTDIR/scripts/parse_DESCHRAMBLER_format.pl $MAINDIR/$ANC $MAINDIR/$ANC/APCFs $REF $REF "${SANC}" "${RES}000"
	# wait
	# perl $SCRIPTDIR/scripts/parse_DESCHRAMBLER_map2EH_v2.pl $MAINDIR/$ANC $SANC $SCRIPTDIR/species_rename.txt
	# wait
	perl $SCRIPTDIR/scripts/parse_DESCHRAMBLER_map2EH_REF.pl $MAINDIR/$ANC/SFs "${RES}000"
	wait

	# cd $MAINDIR/$ANC
	# cat *.merged.map.EH > ${ANC}.all.EH
	# cd $MAINDIR

	# rm "$MAINDIR/$ANC/${ANC}.nonMerged.all.EH"
	# find $MAINDIR/$ANC -name "*.map.EH" ! -name "*.merged.map.EH" -exec cat {} \; > "$MAINDIR/$ANC/${ANC}.nonMerged.all.EH"

	# echo "DESCHRAMBLER stats"
	# perl $SCRIPTDIR/scripts/parse_DESCHRAMBLER_stats.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH" $REF $SANC /share/lewinlab/jmdamas/genomes/genome_sizes.txt
	# wait
	# perl $SCRIPTDIR/scripts/parse_DESCHRAMBLER_stats.pl "$MAINDIR/$ANC/APCF_${REF}.map.EH" $REF $SANC /share/lewinlab/jmdamas/genomes/genome_sizes.txt
	# wait

	# perl $SCRIPTDIR/scripts/parse_DESCHRAMBLER_spsSTATS.pl $MAINDIR/$ANC $ANC "merged"
	# wait
	# perl $SCRIPTDIR/scripts/parse_DESCHRAMBLER_spsSTATS.pl $MAINDIR/$ANC $ANC "notMerged"
	# wait

	# echo "DESCHRAMBLER fusions"
	# perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH" $ANCDB "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH.${FUS_RES}M.FUSIONS" ${FUS_RES}000000 $FUS_REF
	# wait
	# perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH" $ANCDB "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH.0.FUSIONS" 0 $FUS_REF
	# wait

	# if [[ $REF != "hg38" ]]; then
	# 	perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/$ANC/APCF_hg38.merged.map.EH" $ANCDB "$MAINDIR/$ANC/APCF_hg38.merged.map.EH.${FUS_RES}M.FUSIONS" ${FUS_RES}000000 $FUS_REF
	# 	wait
	# 	perl $SCRIPTDIR/scripts/parse_EHfile_FUSIONS_v1.pl "$MAINDIR/$ANC/APCF_hg38.merged.map.EH" $ANCDB "$MAINDIR/$ANC/APCF_hg38.merged.map.EH.0.FUSIONS" 0 $FUS_REF
	# 	wait
	# fi

	# echo "Changing EH labels"
	# perl $SCRIPTDIR/scripts/sed_custom.pl "$MAINDIR/$ANC/${ANC}.all.EH"
	# wait
	# perl $SCRIPTDIR/scripts/sed_custom.pl "$MAINDIR/$ANC/${ANC}.nonMerged.all.EH"
	# wait

	# echo "CREATING EH UPLOAD FILE"
	# perl $SCRIPTDIR/scripts/parse_EHfile_mysql.pl "$MAINDIR/$ANC/${ANC}.all.EH" "$MAINDIR/$ANC/${ANC}.all.EH.mysql"
	# wait
	# perl $SCRIPTDIR/scripts/parse_EHfile_mysql.pl "$MAINDIR/$ANC/${ANC}.nonMerged.all.EH" "$MAINDIR/$ANC/${ANC}.nonMerged.all.EH.mysql"
	# wait

	# echo "Verify RACF adjacency support"
	# perl $SCRIPTDIR/scripts/mergeRACFs.pl "$MAINDIR/$ANC/${ANC}.all.EH" "$MAINDIR/$ANC/${ANC}.adjSupport"
	# wait
	# perl $SCRIPTDIR/scripts/mergeRACFs.pl "$MAINDIR/$ANC/${ANC}.nonMerged.all.EH" "$MAINDIR/$ANC/${ANC}.nonMerged.adjSupport"
	# wait

	# echo "Mapping genes in ancestor"
	# perl $SCRIPTDIR/scripts/parse_DESCHRAMBLER_map2bed.pl $MAINDIR/$ANC
	# wait
	# perl $SCRIPTDIR/scripts/getGenes.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.bed" $GENES "$MAINDIR/$ANC/APCF_${REF}.merged.map.mappedGenes"
	# wait
	# perl $SCRIPTDIR/scripts/getGenes.pl "$MAINDIR/$ANC/APCF_${REF}.map.bed" $GENES "$MAINDIR/$ANC/APCF_${REF}.map.mappedGenes"
	# wait

	# echo "Get smoothed regions stats"
	# perl $SCRIPTDIR/scripts/smoothedRegions_stats.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH" "$MAINDIR/$ANC/APCF_${REF}.map.EH" "$MAINDIR/$ANC/APCF_${REF}.map.smoothed"
	# wait

	# echo "Generating ancestor genome"
	# #NonMerged
	# perl $SCRIPTDIR/scripts/changeCoordNotation.pl "$MAINDIR/$ANC/APCF_${REF}.map.EH" "$MAINDIR/$ANC/APCF_${REF}.map.EH.1notation"
	# wait
	# perl $SCRIPTDIR/scripts/create_genome_ancestor.pl "$MAINDIR/$ANC/APCF_${REF}.map.EH.1notation" $REFGENOME "$MAINDIR/$ANC/${ANC}.genome.fa"
	# wait
	# #Merged
	# perl $SCRIPTDIR/scripts/changeCoordNotation.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH" "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH.1notation"
	# wait
	# perl $SCRIPTDIR/scripts/create_genome_ancestor.pl "$MAINDIR/$ANC/APCF_${REF}.merged.map.EH.1notation" $REFGENOME "$MAINDIR/$ANC/${ANC}.merged.genome.fa"
	# wait
	# echo $ANC "- done!"

done