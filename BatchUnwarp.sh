#!/bin/bash

. /nrgpackages/scripts/sge_setup.sh

mkdir -p subject_scripts

Subjects="LS2009 LS2037 LS2043"

for subj in ${Subjects} ; do
    echo "Submitting gradient unwarping job for subject ${subj}"
    cp GradientDistortionUnwarpOnly.sh subject_scripts/GradientDistortionUnwarpOnly.${subj}.sh
    qsub -q hcp_standard.q -V subject_scripts/GradientDistortionUnwarpOnly.${subj}.sh \
        --project=PipelineTest --subject=${subj} --outdir=${PWD}
done
  