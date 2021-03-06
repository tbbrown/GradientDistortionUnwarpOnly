#!/bin/bash

. /nrgpackages/scripts/sge_setup.sh

mkdir -p subject_scripts

#Project="WU_L1A_Staging"
#Subjects="LS2001 LS2008 LS2009 LS2037 LS2043 LS3017 LS3019 LS3026 LS3029 LS3040 LS3046 LS4004 LS4025 LS4036 LS4041 LS4043 LS4047 LS5007 LS5040 LS5041 LS5049 LS6003 LS6006 LS6009 LS6038 LS6046"
#Subjects="LS3029"
#Subjects="LS2003 LS5038"

#Project="WU_L1A_Unproc"
#Subjects="LS2001 LS2008 LS2009 LS2037 LS2043 LS3017 LS3019 LS3026 LS3040 LS3046 LS4025 LS4036 LS4041 LS4043 LS4047 LS5007 LS5040 LS5041 LS5049 LS6003 LS6006 LS6009 LS6038 LS6046"

Project="WU_L1A_Staging"
Subjects="LS2001 LS2003 LS2008 LS2009 LS2037 LS2043 LS3017 LS3019 LS3026 LS3029 LS3040 LS3046 LS4025 LS4036 LS4041 LS4043 LS4047 LS5007 LS5038 LS5040 LS5041 LS5049 LS6003 LS6006 LS6009 LS6038 LS6046"

for subj in ${Subjects} ; do
    echo "Submitting gradient unwarping job for subject ${subj}"
    cp GradientDistortionUnwarpOnly.sh subject_scripts/${subj}.GradientDistortionUnwarpOnly.sh
    qsub -q hcp_priority.q -V subject_scripts/${subj}.GradientDistortionUnwarpOnly.sh \
        --project=${Project} --subject=${subj} --outdir=/home/shared/HCP/TimB
done
  