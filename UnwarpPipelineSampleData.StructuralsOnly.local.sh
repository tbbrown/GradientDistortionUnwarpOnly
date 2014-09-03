#!/bin/bash

Subjects="100307"

for subj in ${Subjects} ; do
    echo "Performing gradient distortion correction for subject ${subj}"
    ./GradientDistortionUnwarpOnly.sh --project=HCP_500 --subject=${subj} --outdir=${PWD} --structuralsonly --keepworkingdirs
done
