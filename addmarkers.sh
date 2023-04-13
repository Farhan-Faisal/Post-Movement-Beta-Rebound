#!/bin/tcsh
# This is in magneto

# addmarkers_pmbr
# Audio Stimulus and Button Response triggers detected from UPPT001
# Need the following markers
# button response markers (LH and RH)
# Audio stimulus markers
# Block start/end markers

## For help
# addMarker -help
# scanMarkers -help 

##----------------------Port codes----------------------------------##
# Button Start 50 -> 110010 -> Flip and 16 bit  -> 0100110000000000
# Trial Start - 25 -> 11001 -> 1001100000000000

# Buttons press 254 -> 11111110 -> Flip and 16 bit -> 0111111100000000
# RH Hand || Press stimulus onset -> 10 -> 1010 -> 0101000000000000
# LH Hand || Press stimulus onset -> 9 -> 1001 -> 1001000000000000


#--------------------- Set these variables---------------------#
set subj = 20070
set date = 20230309
set RH = 008
set LH = 007
set project_folder = /rri_disks/eugenia/meltzer_lab/PMBR/


#--------------------- Do not change these variables---------------------#
set RH_dataset = ${subj}_AEF01_${date}_${RH}.ds
set LH_dataset = ${subj}_AEF01_${date}_${LH}.ds
set RH_events_file = ${project_folder}/raw/${date}/rhand_events.evt 
set LH_events_file = ${project_folder}/raw/${date}/lhand_events.evt

mkdir ${project_folder}/proc/${subj}

## Entering the desired MEG raw data directory
cd ${project_folder}/raw/${date}



#--------------------- RH processing ---------------------#
## Add markers for the RH dataset || Stimuli -> Button -> 
addMarker -f -n rhand_stimulus -s UPPT001 -l deepblue -c 0101000000000000 ${RH_dataset}
addMarker -f -n rhand_response -s UPPT001 -l deeppink -c 0111111100000000 ${RH_dataset}

## Save RH desired datarange, relative to selected markers, to output file
scanMarkers -f -includeBad -marker rhand_stimulus -marker rhand_response -overlap 6 -time -1 3 \
${RH_dataset} ${RH_events_file}


#--------------------- LH processing ---------------------#
## Add Markers for the LH dataset || Stimuli -> Button -> 
addMarker -f -n lhand_stimulus -s UPPT001 -l deepblue -c 1001000000000000 ${LH_dataset}
addMarker -f -n lhand_response -s UPPT001 -l deeppink -c 0111111100000000 ${LH_dataset}

## Save LH desired datarange, relative to selected markers, to output file
scanMarkers -f -includeBad -marker lhand_stimulus -marker lhand_response -overlap 6 -time -1 3 \
${LH_dataset} ${LH_events_file}





