#!/bin/tcsh

#---------------------------------------------------------------------#
# Author: Tiana Wei
# Description: Epoching an MEG dataset
# Run it in Magneto
#---------------------------------------------------------------------#

## Set these variables
set subj = 20070
set date = 20230309

set LH = 7
set RH = 8

set outputdir = /rri_disks/eugenia/meltzer_lab/PMBR/proc/${subj}
set rawdir = /rri_disks/eugenia/meltzer_lab/PMBR/raw/${date}

## Do not change these variables
set RH_DS = ${rawdir}/${subj}_AEF01_${date}_00${RH}.ds
set LH_DS = ${rawdir}/${subj}_AEF01_${date}_00${LH}.ds

## Epoching the RH dataset
set tmpRHDS = ${outputdir}/tmp_dataset_00${RH}.ds
set outRHDS = ${outputdir}/cue_onset_rhand.ds

newDs -f -all \
-marker rhand_stimulus \
-time -1 3 -overlap 6 -includeBadChannels -includeBad \
${RH_DS} ${tmpRHDS}


## Epoching the LH dataset
set tmpLHDS = ${outputdir}/tmp_dataset_00${LH}.ds
set outLHDS = ${outputdir}/cue_onset_lhand.ds

newDs -f -all \
-marker lhand_stimulus \
-time -1 3 -overlap 6 -includeBadChannels -includeBad \
${LH_DS} ${tmpLHDS}



echo epoching done

## Filter the epoched LH and RH datasets
newDs -f -all \
-filter /rri_disks/eugenia/meltzer_lab/PMBR/code/baseline_corr.cfg \
-includeBadChannels -includeBad \
${tmpRHDS} ${outRHDS}

newDs -f -all \
-filter /rri_disks/eugenia/meltzer_lab/PMBR/code/baseline_corr.cfg \
-includeBadChannels -includeBad \
${tmpLHDS} ${outLHDS}


## Remove the temporary epoched but unfiltered datasets
rm -rf ${tmpRHDS}
rm -rf ${tmpLHDS}





