#* UDALL freesurfer makefile: modified for processing high resolution data 

# Set open MP number of threads to be 1, so that we can parallize using make.
export OMP_NUM_THREADS=1

# for Freesurfer (running version 5.3)
export SUBJECTS_DIR=/mnt/home/natkoh/hires_structural/FS_HIRES
export QA_TOOLS=/usr/local/freesurfer/QAtools_v1.1
export FSBIN=/usr/local/freesurfer/stable5_3/bin
export FREESURFER_SETUP=/usr/local/freesurfer/stable5_3/SetUpFreeSurfer.sh
export RECON_ALL=/usr/local/freesurfer/stable5_3/bin/recon-all
export TKMEDIT=/usr/local/freesurfer/stable5_3/bin/tkmedit
export SHELL=/bin/bash

EXPERT_FILE=$(SUBJECTS_DIR)/expertfile

#! session number
WAVE=1

#! where the subject directories live
PROJHOME=/mnt/home/natkoh/hires_structural

#! get subject IDs
#FS_subjects=$(notdir $(wildcard $(PROJHOME)/1?????))
FS_subjects=$(shell cat /mnt/home/natkoh/hires_structural/sublist)

#! append session number to subject IDs
FS_subsess:=$(FS_subjects:%=%.s$(WAVE))

define usage
   @echo Usage:
   @echo "make, or make interactive	Makes interactive targets"
   @echo "make noninteractive		Makes noninteractive targets"
   echo 
   @echo Noninteractive targets:
   @echo "make setup			Copies source files to this directory"
   @echo "make freesurfer		Runs freesurfer"
   @echo
   @echo Other useful targets:
   @echo "make clean			Remove everything! Be careful!"
   @echo "make mostlyclean		Remove everything but the good bits."
   @echo "make help			Print this message."
   @echo
   @echo Variables:
   @echo "RECON_FLAGS			Set to flags to recon-all, by default"
endef

.PHONY: FreesurferSetup FreesurferQA hires all
.SECONDARY:

#? make both downsampled and freesurfer
all: FreesurferSetup hires

#? 0.7 mm isotropic run
hires: $(FS_subsess:%=%/mri/aparc+aseg.mgz)

#? Create just the brainmasks (debug)
brainmasks: $(FS_subsess:%=%/mri/brainmask.nii.gz)

## FreesurferSetup
FreesurferSetup: $(FS_subsess)

#> this matches the setup recipe
%.s1:  $(PROJHOME)/%_3T_T1w_MPR1.nii.gz 
	mkdir -p $@/mri/orig ;\
	cp $^ $@/mri/orig/T1.nii.gz ;\
	cd $@/mri/orig ;\
	$(FSBIN)/mri_convert -cs 0.7 T1.nii.gz 001.mgz

#> now try the hires pipeline
%/mri/aparc+aseg.mgz: 
	source $${FREESURFER_SETUP} ;\
	export SUBJECTS_DIR=$(SUBJECTS_DIR) ;\
	recon-all -all -hires -s $* -3T -expert $(EXPERT_FILE)
#-i $(SUBJECTS_DIR)/$*/mri/orig/T1.nii.gz 

help:
	$(usage)

## QA
qafiles=$(FS_subsess:%=QA/%)
FreesurferQA: $(qafiles)

QA/%: %
	source $${FREESURFER_SETUP} ;\
	$(QA_TOOLS)/recon_checker -s $*
