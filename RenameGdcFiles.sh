#!/bin/bash

filelist=`find . -name "*_gdc.nii.gz"`

for gdc_file in ${filelist} ; do

    image_file_base=${gdc_file%_gdc.nii.gz}
    image_file=${image_file_base}.nii.gz

    #echo "About to mv ${gdc_file} ${image_file}"
    mv -v ${gdc_file} ${image_file}
done
