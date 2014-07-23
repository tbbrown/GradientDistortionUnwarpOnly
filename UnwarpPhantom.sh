#!/bin/bash

#./GradientDistortionUnwarpScansOnly.sh --project=Skyra_QC --subject=ACR_J4660_20140721 --outdir=${PWD} > subject_scripts/UnwarpPhantom.out 2>&1

cp GradientDistortionUnwarpScansOnly.sh subject_scripts/GradientDistortionUnwarpScansOnly.Phantom.sh
qsub -q hcp_standard.q -V subject_scripts/GradientDistortionUnwarpScansOnly.Phantom.sh \
    --project=Skyra_QC --subject=ACR_J4660_20140721 --outdir=${PWD}


