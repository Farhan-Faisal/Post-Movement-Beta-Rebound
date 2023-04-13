#----------------------------------------
# STEP ONE - DOWNLOAD THE MRI SCANS
#----------------------------------------

# set some variables
# changes these ones:
set Username = xxxx

set SubjectID = 15434
set ScanDate = 20180717
set ProjectID = 147

# don't change these ones!
set ProjectLabel = MeJe_M${ProjectID}_BA
set rrinidsubj = ${ProjectLabel}_${SubjectID}
set mridir = ${rrinidsubj}_MRI_${ScanDate}
set physdir = ${rrinidsubj}_PhysioData_${ScanDate}

# create directory to download to 
set DOWNLOAD_DIR = /rri_disks/eugenia/meltzer_lab/mridata2023/raw/${SubjectID}/
echo $DOWNLOAD_DIR
mkdir $DOWNLOAD_DIR
cd $DOWNLOAD_DIR


# to see list of subject IDs
echo "##################################################################"
echo "List of SubjectIDs:"
curl --silent -k -u ${Username}:Kikos100$ -X GET --url "https://rrinid.rotman-baycrest.on.ca/spred/data/projects/${ProjectLabel}/subjects?format=csv"  | awk -F'["_]' '$2 == "spred" {print $0}' | awk -F'["]' '{print $6}' | awk -F'[_]' '{print $NF}'

# to see sessions for a given subject
echo "##################################################################"
echo "List of sessions:"
curl --silent -u ${Username}:Kikos100$ -k -X GET --url "https://rrinid.rotman-baycrest.on.ca/spred/data/projects/${ProjectLabel}/subjects/${rrinidsubj}/experiments?format=csv"  | awk -F'["]' '$2 ~ /^spred/ {print $10}' | cut -d'_' -f 5- 

# to download scans for a given subject
echo "##################################################################"
echo "Downloading MRI and PSYSIO Data"
curl --silent -u ${Username}:Kikos100$ -k -X GET -o ${mridir}.zip --url "https://rrinid.rotman-baycrest.on.ca/spred/data/projects/${ProjectLabel}/subjects/${rrinidsubj}/experiments/${mridir}/scans/ALL/resources/DICOM/files?format=zip"
curl --silent -u ${Username}:Kikos100$ -k -X GET -o ${physdir}.zip --url "https://rrinid.rotman-baycrest.on.ca/spred/data/projects/${ProjectLabel}/subjects/${rrinidsubj}/experiments/${physdir}/scans/ALL/files?format=zip"
echo "Download Complete"

# unzip the zipped MRI files
echo "##################################################################"
echo "Unzipping MRI Data"
unzip ${mridir}





#----------------------------------------
# STEP TWO - CONVERT TO .NII
#----------------------------------------

set rawdirroot = /rri_disks/eugenia/meltzer_lab/mridata2023/raw/${SubjectID}/${mridir}/scans

set procdir = /rri_disks/eugenia/meltzer_lab/mridata2023/proc/${SubjectID}/

mkdir $procdir
cd $rawdirroot

##### IMPORTANT STEP - CHECK SCAN NAMES #####
# check to confirm which scan number is which
ls $rawdirroot


#### Start Conversion #####
#-i N -n Y -s N -v Y -x N
# /rri_disks/artemis/meltzer_lab/ffaisal/MRI/XNAT_data/
echo "##################################################################"
echo "Starting DICOM to Nii conversion"
# dcm2niix -i n -b n -ba n -f %s_%p_%d -o ${procdir} ./1-anat_scout/resources/DICOM/files
# dcm2niix -i n -b n -ba n -f %s_%p_%d -o ${procdir} ./2-anat_scout_MPR_sag/resources/DICOM/files
# dcm2niix -i n -b n -ba n -f %s_%p_%d -o ${procdir} ./3-anat_scout_MPR_cor/resources/DICOM/files
# dcm2niix -i n -b n -ba n -f %s_%p_%d -o ${procdir} ./4-anat_scout_MPR_tra/resources/DICOM/files
dcm2niix -i n -b n -ba n -f %s_%p_%d -o ${procdir} ./5-anat_T1w/resources/DICOM/files

# dcm2niix -i n -b n -ba n -f %s_%p_%d -o ${procdir} ./6-T1_MPRAGE_OB_AXIAL/resources/DICOM/files

# dcm2niix -i n -b n -ba n -f %s_%p_%d -o ${procdir} ./6-anat_T1w_MPR_cor/resources/DICOM/files
# dcm2niix -i n -b n -ba n -f %s_%p_%d -o ${procdir} ./7-anat_T1w_MPR_tra/resources/DICOM/files
echo "##################################################################"
echo "Conversion complete"

echo "##################################################################"
echo "Removing unzipped raw data"
cd $DOWNLOAD_DIR
rm -r ${mridir}
echo "##################################################################"
echo "DONE!"