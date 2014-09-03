#!/bin/bash

. /nrgpackages/scripts/sge_setup.sh

mkdir -p subject_scripts

Subjects="100307"

for subj in ${Subjects} ; do
    echo "Submitting gradient unwarping job for subject ${subj}"
    cp GradientDistortionUnwarpOnly.sh subject_scripts/GradientDistortionUnwarpOnly.${subj}.sh
    qsub -q hcp_standard.q -V subject_scripts/GradientDistortionUnwarpOnly.${subj}.sh \
        --project=HCP_500 --subject=${subj} --outdir=${PWD} --structuralsonly --keepworkingdirs
done
  