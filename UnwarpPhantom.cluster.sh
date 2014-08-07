#!/bin/bash

. /nrgpackages/scripts/sge_setup.sh

cp GradientDistortionUnwarpScansOnly.sh subject_scripts/GradientDistortionUnwarpScansOnly.Phantom.sh
qsub -q hcp_standard.q -V subject_scripts/GradientDistortionUnwarpScansOnly.Phantom.sh \
    --project=Skyra_QC --subject=ACR_J4660_20140721 --outdir=${PWD}


