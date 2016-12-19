#! /bin/bash

# Step 1. Brain extraction & initial N4 bias correction - https://github.com/ntustison/antsBrainExtractionExample

DATA_DIR=${PWD}/
TEMPLATE_DIR=${DATA_DIR}/Template/
OUT_DIR=${DATA_DIR}/Output/

bash ${ANTSPATH}antsBrainExtraction.sh \
  -d 2 \
  -a ${DATA_DIR}IXI002-Guys-0828-T1_slice90.nii.gz \
  -e ${TEMPLATE_DIR}T_template0_slice122.nii.gz \
  -m ${TEMPLATE_DIR}T_template0ProbabilityMask.nii.gz \
  -o ${OUT_DIR}example

# Step 2. Prior-based segmentation + weighted bias correction - https://github.com/ntustison/antsAtroposN4Example

DATA_DIR=${PWD}/Images/
TEMPLATE_DIR=${DATA_DIR}/Template/
OUT_DIR=${PWD}/Output/

bash ${ANTSPATH}/antsAtroposN4.sh \
  -d 2 \
  -a ${DATA_DIR}/KKI2009-01-MPRAGE_slice150.nii.gz \
  -x ${DATA_DIR}/KKI2009-01-MPRAGE_slice150_mask.nii.gz \
  -p ${DATA_DIR}/priorWarped%d.nii.gz \
  -c 3 \
  -y 2 \
  -y 3 \
  -w 0.25 \
  -o ${OUT_DIR}example

# Step 3. DiReCT-based cortical thickness estimation - https://github.com/ntustison/antsCorticalThicknessExample

DATA_DIR=${PWD}
TEMPLATE_DIR=${DATA_DIR}/Template/
OUT_DIR=${DATA_DIR}/OutputT1Only/

bash ${ANTSPATH}antsCorticalThickness.sh -d 2 \
  -a ${DATA_DIR}/IXI002-Guys-0828-T1_slice90.nii.gz \
  -e ${TEMPLATE_DIR}template_slice80.nii.gz \
  -m ${TEMPLATE_DIR}template_cerebrum_mask_slice80.nii.gz \
  -p ${TEMPLATE_DIR}prior%d_slice80.nii.gz \
  -o ${OUT_DIR}example

# Step 4. Multivariate template construction - https://github.com/ntustison/TemplateBuildingExample

inputPath=${PWD}/

${ANTSPATH}/buildtemplateparallel.sh \
  -d 2 \
  -o BTP/T_ \
  -i 4 \
  -g 0.2 \
  -j 1 \
  -c 0 \
  -m 100x70x50x10 \
  -n 1 \
  -r 1 \
  -s CC \
  -t RI \
  OASIS*1.nii.gz

inputPath=${PWD}/
outputPath=${PWD}/TemplateSyN/

${ANTSPATH}/antsMultivariateTemplateConstruction.sh \
  -d 2 \
  -o ${outputPath}T_ \
  -i 4 \
  -g 0.2 \
  -j 4 \
  -c 2 \
  -k 1 \
  -w 1 \
  -m 100x70x50x10 \
  -n 1 \
  -r 1 \
  -s CC \
  -t GR \
  ${inputPath}/OASIS*1.nii.gz

inputPath=${PWD}/
outputPath=${PWD}/TemplateMultivariateBSplineSyN/

${ANTSPATH}/antsMultivariateTemplateConstruction2.sh \
  -d 2 \
  -o ${outputPath}T_ \
  -i 4 \
  -g 0.2 \
  -j 2 \
  -c 0 \
  -k 2 \
  -w 1x1 \
  -f 8x4x2x1 \
  -s 3x2x1x0 \
  -q 100x70x50x10 \
  -n 1 \
  -r 1 \
  -l 1 \
  -m CC[2] \
  -t BSplineSyN[0.1,26,0] \
  ${inputPath}/OASIS*.nii.gz

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