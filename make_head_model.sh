#-----------------------Step 1--------------------------------#
# Import the nifti data into the working directory
# Convert it to mprage format
# Do this part in magneto

set subj = 20070
set workdir = /rri_disks/eugenia/meltzer_lab/PMBR/proc/${subj}
mkdir ${workdir}

mkdir ${workdir}/samresults
mkdir ${workdir}/anat
cd ${workdir}/anat



# Convert to mprage format
3dcopy ${subj}_mprage.nii mprage+orig
afni &
#-------------------------------------------------------------#



#-----------------------Step 2--------------------------------#
# Datamode -> plugins -> edit tagset
# Dataset -> select the mprage file -> apply -> set
# Tag File: /auto/baucis/jed/sw/brainhulllib/null.tag -> Read

# Click on Nasion -> Match the three slices with brainSite
# ls


# Click set
# Repeat for left and right ear -> Save -> Close AFNI

#-------------------------------------------------------------#



#-----------------------Step 3--------------------------------#
# Need Brainhull package for 
# Warping MRI image to ORTHO Space
# Skull stripping
# Approximating inner skull surface

set libdir = /home/jed/data/sw/brainhulllib

# Warping into ortho space
cd ${workdir}/anat
3dTagalign -matvec orthomat -prefix ./ortho -master $libdir/master+orig mprage+orig

# This line is necessary for AFNI-internal reasons. '
3drefit -markers ortho+orig
#-------------------------------------------------------------#



#-----------------------Step 4--------------------------------#
# Strip the skull off

3dSkullStrip -input ortho+orig -prefix mask -mask_vol -no_avoid_eyes 

# Brainhull procedure documented on the NIH webpage.
# Construct the brain hull

3dcalc -a ortho+orig -b mask+orig -prefix brain -expr 'a * step(b - 2.9)'
brainhull mask+orig > hull

## Problems in this line

hull2fid ortho+orig hull ortho
hull2suma hull

# Visualize the hull

suma -novolreg -spec hull.spec &

# Cant see all three markers 
afni -niml -dset ortho+orig
#-------------------------------------------------------------#


#-----------------------Step 5--------------------------------#
# Warp the dataset from ortho space to MNI space

cd ${workdir}/anat

# Getting the MNI brain from Jed's reference
set refdir = /auto/baucis/jed/refbrains
set reference = ${refdir}/MNI_avg152T1.nii.gz
set loresreference = /auto/baucis/jed/refbrains/MNI_avg152T1_5mm.nii.gz
cp ${reference} .

# Convert the skull stripped ortho brain into a gzipped file
# ANTS i.e., the MNI warp calculator needs a gzipped file as input
3dcopy brain+orig orthoanat.nii.gz

# Use ANTS to calculate the MNI warp ## Problems in this line # Do this in MELGS1
ANTS 3 -m PR\[./MNI_avg152T1.nii.gz, orthoanat.nii.gz,1,2\] -o orthoanat_to_mni_SYN.nii.gz -r Gauss\[2,0\] -t SyN\[0.5\] -i 30x99x11 -use-Histogram-Matching 


# This ANTS command is used to APPLY the warp computed above to the anatomical image
# Open the MNI brain and the newly warped brain in two AFNI viewers linked together, '
# and click on various points ensuring that they match up. '

WarpImageMultiTransform 3 orthoanat.nii.gz mnisyn_orthoanat.nii.gz -R ./MNI_avg152T1.nii.gz orthoanat_to_mni_SYNWarp.nii.gz \
orthoanat_to_mni_SYNAffine.txt 
3drefit -space MNI mnisyn_orthoanat.nii.gz

# This next step is needed because it allows the use of AFNI volume render plugin to make pretty pictures
# It requires the anatomical underlay image to be stored as "short" numbers. So we are copying into short format

3dcalc -a mnisyn_orthoanat.nii.gz -expr a -prefix mnisyn_orthoanat_short+tlrc -datum short

#-------------------------------------------------------------#


#-----------------------Step 6--------------------------------#
# This step does an inverse warp from MNI space (with 116 marked regions)
# to the individuals Ortho space
# We will use the centers of these 116 regions as ROIs
# The coordinates of these 116 ROIs will be extracted using 3dclust in AFNI coordinates
# The coordinates will then be converted into CTF format target file using a python script
# Finally this target file is fed into SAMsrc to produce beamformer weights

# Do this portion in magneto
set samresultsdir = ${workdir}/samresults
set anatdir = ${workdir}/anat

mkdir $samresultsdir
mv mnisyn_orthoanat_short+tlrc.* $samresultsdir
cd ${anatdir}
cp ${refdir}/mni_coord116_3sphvals.nii.gz .

# Do this in MELGS1
# Doing the inverse warp
# warps 116 Brain regions from ATLAS from MNI to individual's ortho space

WarpImageMultiTransform 3 mni_coord116_3sphvals.nii.gz ${anatdir}/ortho_coord116_3sphvals.nii.gz \
-R orthoanat.nii.gz --use-NN -i orthoanat_to_mni_SYNAffine.txt \
orthoanat_to_mni_SYNInverseWarp.nii.gz 

3dclust -isomerge 0 2 ortho_coord116_3sphvals.nii.gz > ortho_coord116_clustreport.txt

# This computes the AFNI coordinates of the centers of each 116 brain region in the indivudual's ortho space
clustreport_to_ctf_coords2023.py ortho_coord116_clustreport.txt ${refdir}/coord116_vals.txt targets116

#-------------------------------------------------------------#

#'these commands are applied to MEG dataset'
#'To make a head model, we have to do localspheres on each MEG dataset, incorporating the head position information.'
#' Make sure you have the updated head position based on the continuous localization data'
#'See the NIH webpage for details.'

set mri = ${workdir}/anat
set dspath = ${workdir}
set ds = ${dspath}/cue_onset_lhand.ds
localSpheres -d $ds -s $mri/ortho.shape -M -v > ${ds}/sphereinfo.txt
checkSpheres $ds >> ${ds}/sphereinfo.txt
inflateSpheres $ds >> ${ds}/sphereinfo.txt

set mri = ${workdir}/anat
set dspath = ${workdir}
set ds = ${dspath}/cue_onset_rhand.ds
localSpheres -d $ds -s $mri/ortho.shape -M -v > ${ds}/sphereinfo.txt
checkSpheres $ds >> ${ds}/sphereinfo.txt
inflateSpheres $ds >> ${ds}/sphereinfo.txt

