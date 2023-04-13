
################################################
set subj = 20070
set workdir = /rri_disks/eugenia/meltzer_lab/PMBR/proc/${subj}

set ds = ${workdir}/cue_onset_lhand.ds
set win = win_lhand_stimulus_-1-3
set targetfilepath = ${workdir}/anat/
set targetfilename = targets116
cp ${targetfilepath}/${targetfilename} ${ds}/SAM
set cov = ${win},0-100Hz
set newdsname = ${workdir}/virt116_cue_onset_lhand.ds

echo '' > ${workdir}/samlogvirt.txt

cp /rri_disks/eugenia/meltzer_lab/PMBR/code/samparam/${win} ${ds}/SAM/
SAMcov -v -m $win -r $ds -f "0 100" >> ${workdir}/samlogvirt.txt

SAMsrc -r $ds -c $cov -t $targetfilename -W 0 -Z >> ${workdir}/samlogvirt.txt

newDs2 -marker lhand_stimulus -time -1 3 -band 0 100 \
     -includeSAM ${cov},${targetfilename}.wts  $ds $newdsname

##Then import into eeglab (import data from ctf folder (MEG), choose channels 341:456*, and save as virt116_pic_onset.set, delete the virtual .ds dataset

-excludeMEG