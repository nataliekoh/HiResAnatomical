#! /bin/bash

export ANTSPATH=/usr/local/ANTs-2.1.0-rc3/bin

# Step 1. Multivariate template construction - https://github.com/ntustison/TemplateBuildingExample

inputPath=${PWD}/

${ANTSPATH}/buildtemplateparallel.sh \
  -d 2 \ # Image dimension
  -o BTP/T_ \ # Output prefix
  -i 4 \ # Iterations
  -g 0.2 \ # Gradient step size (default = 0.25); smaller numbers = more cautious template update steps
  -j 1 \ # No. of CPU cores to use
  -c 0 \ # Control for parallel computation; 0 = serial, 1 = SGE qsub, etc
  -m 100x70x50x10 \ # Max iterations for each reg
  -n 1 \ # N4BiasFieldCorrection; 0 = off, 1 = on
  -r 1 \ # Rigid body registration; 0 = off, 1 = on
  -s CC \ # Type of similarity metric for registration
  -t RI \ # Type of transformation model for registration
  OASIS*1.nii.gz # Images for template building

outputPath=${PWD}/TemplateSyN/

${ANTSPATH}/antsMultivariateTemplateConstruction.sh \
  -d 2 \ # Image dimensions
  -o ${outputPath}T_ \ # Output prefix
  -i 4 \ # Iterations
  -g 0.2 \ # Gradient step
  -j 4 \ # No. of CPU cores to use
  -c 2 \ # Control for parallel computation
  -k 1 \ # No. of modalities to construct template (default = 1)
  -w 1 \ # Modality weights used in similarity matric (default = 1)
  -m 100x70x50x10 \ # Max interations for each reg
  -n 1 \ # N4Biasfield correction; 0 = off, 1 = on
  -r 1 \ # Rigid body registration; 0 = off, 1 = on
  -s CC \ # Type of similarity metric for registration
  -t GR \ # Type of transformation model for registration 
  ${inputPath}/OASIS*1.nii.gz

outputPath=${PWD}/TemplateMultivariateBSplineSyN/

${ANTSPATH}/antsMultivariateTemplateConstruction2.sh \
  -d 2 \
  -o ${outputPath}T_ \
  -i 4 \
  -g 0.2 \
  -j 2 \ 
  -c 0 \ # Parallel computation option
  -k 2 \ # No. of modalities used to construct template (e.g. if using T1, T2 & FA, k = 3)
  -w 1x1 \ # Modality weights used in similarity metric
  -f 8x4x2x1 \ # Shrink factors (default = 6x4x2x1) 
  -s 3x2x1x0 \
  -q 100x70x50x10 \ # Max iterations for each pairwise registration in the form ?xJxKxL; J = max iter at coarsest resolutions, K = middle resolution iter, L = fine resolution iter
  -n 1 \ # N4biasfieldcorrection
  -r 1 \ # Rigid body registration
  -l 1 \ # Use linear image registration during pairwise deformable reg. 
  -m CC[2] \
  -t BSplineSyN[0.1,26,0] \ # Options: SyN = Greedy SyN; BSplineSyN = Greedy Bspline SyN; TimeVaryingVelocityField; TimeVaryingBSplineVelocityField
  ${inputPath}/OASIS*.nii.gz

# Step 2. Brain extraction & initial N4 bias correction - https://github.com/ntustison/antsBrainExtractionExample

DATA_DIR=${PWD}/
TEMPLATE_DIR=${DATA_DIR}/Template/
OUT_DIR=${DATA_DIR}/Output/

bash ${ANTSPATH}antsBrainExtraction.sh \
  -d 2 \
  -a ${DATA_DIR}IXI002-Guys-0828-T1_slice90.nii.gz \
  -e ${TEMPLATE_DIR}T_template0_slice122.nii.gz \ # Template
  -m ${TEMPLATE_DIR}T_template0ProbabilityMask.nii.gz \ # Brain extraction probability mask
  -o ${OUT_DIR}example

# Step 3. Prior-based segmentation + weighted bias correction - https://github.com/ntustison/antsAtroposN4Example

DATA_DIR=${PWD}/Images/
TEMPLATE_DIR=${DATA_DIR}/Template/
OUT_DIR=${PWD}/Output/

bash ${ANTSPATH}/antsAtroposN4.sh \
  -d 2 \
  -a ${DATA_DIR}/KKI2009-01-MPRAGE_slice150.nii.gz \ # Input
  -x ${DATA_DIR}/KKI2009-01-MPRAGE_slice150_mask.nii.gz \ # Mask image
  -p ${DATA_DIR}/priorWarped%d.nii.gz \ # Segmentation priors 
  -c 3 \ # No. of segmentation classes
  -y 2 \ # Posterior label for N4 weight mask
  -y 3 \ # Same as above? Why is this defined twice?!
  -w 0.25 \ # Spatial prior probability segmentation weight; default = 0 
  -o ${OUT_DIR}example 

# Step 4. DiReCT-based cortical thickness estimation - https://github.com/ntustison/antsCorticalThicknessExample

DATA_DIR=${PWD}
TEMPLATE_DIR=${DATA_DIR}/Template/
OUT_DIR=${DATA_DIR}/OutputT1Only/

bash ${ANTSPATH}antsCorticalThickness.sh -d 2 \
  -a ${DATA_DIR}/IXI002-Guys-0828-T1_slice90.nii.gz \
  -e ${TEMPLATE_DIR}template_slice80.nii.gz \ # Brain template
  -m ${TEMPLATE_DIR}template_cerebrum_mask_slice80.nii.gz \ # Brain extraction probability mask
  -p ${TEMPLATE_DIR}prior%d_slice80.nii.gz \ # Brain segmentation priors
  -o ${OUT_DIR}example

# Step 5. Parcellation - https://github.com/ntustison/MalfLabelingExample

inputPath=${PWD}/

${ANTSPATH}/antsJointLabelFusion.sh \
  -d 2 \
  -c 2 -j 4 \
  -x or \
  -o ${inputPath}/Output/example \
  -p ${inputPath}/Output/examplePosteriors%02d.nii.gz \
  -t ${inputPath}/T_template0.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-10_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-10_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-11_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-11_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-12_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-12_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-13_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-13_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-14_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-14_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-15_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-15_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-16_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-16_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-17_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-17_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-18_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-18_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-19_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-19_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-1_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-1_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-20_slice118.nii.gz -l ${inputPath}/Labels/OASIS-TRT-20-20_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-2_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-2_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-3_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-3_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-4_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-4_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-5_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-5_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-6_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-6_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-7_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-7_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-8_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-8_DKT31_CMA_labels_slice118.nii.gz \
  -g ${inputPath}/Atlases/OASIS-TRT-20-9_slice118.nii.gz  -l ${inputPath}/Labels/OASIS-TRT-20-9_DKT31_CMA_labels_slice118.nii.gz \
  -k 1