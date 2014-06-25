#!/bin/bash

# 
# Function description
#  Setup the environment
#
setup_environment() {
    export FSLDIR=/nrgpackages/tools.release/fsl-5.0.6-centos6_64
    . ${FSLDIR}/etc/fslconf/fsl.sh

    export HCPPIPEDIR=/home/NRG/tbrown01/projects/Pipelines
    export HCPPIPEDIR_Global=${HCPPIPEDIR}/global/scripts
    export HCPPIPEDIR_Config=${HCPPIPEDIR}/global/config
}

#
# Function description
#  Show usage information for this script
#
usage() {
    local scriptName=$(basename ${0})
    echo ""
    echo "  Usage: ${scriptName} --project=<project-id> --subject=<subject-id> --outdir=<output-directory>"
    echo ""
}

#
# Function description
#  Get the command line options for this script
#
# Global output variables
#  ${project} - project id
#  ${subject} - subject id
#  ${outdir} - output directory
#
get_options() {
    local scriptName=$(basename ${0})
    local arguments=($@)

    # initialize global output variables
    unset project
    unset subject
    unset outdir

    # parse arguments
    local index=0
    local numArgs=${#arguments[@]}
    local argument

    while [ ${index} -lt ${numArgs} ]; do
        argument=${arguments[index]}

        case ${argument} in
            --help)
                usage
                exit 1
                ;;
            --project=*)
                project=${argument/*=/""}
                index=$(( index + 1 ))
                ;;
            --subject=*)
                subject=${argument/*=/""}
                index=$(( index + 1 ))
                ;;
            --outdir=*)
                outdir=${argument/*=/""}
                index=$(( index + 1 ))
                ;;
            *)
                usage
                echo "ERROR: Unrecognized Option: ${argument}"
                exit 1
                ;;
        esac
    done

    # check required parameters
    if [ -z ${project} ]; then
        usage
        echo "ERROR: <project-id> not specified"
        exit 1
    fi

    if [ -z ${subject} ]; then
        usage
        echo "ERROR: <subject-id> not specified"
        exit 1
    fi

    if [ -z ${outdir} ]; then
        usage
        echo "ERROR: <output-directory> not specified"
        exit 1
    fi

    # report
    echo "-- ${scriptName}: Specified command-line options - Start --"
    echo "   project: ${project}"
    echo "   subject: ${subject}"
    echo "   outdir: ${outdir}"
    echo "-- ${scriptName}: Specified command-line options - End --"
}

#
# Unwarp images in directory list
#
unwarp_images() {
    resource_spec=${1}
    resources=`ls -d ${resource_spec}`

    for resource_dir in ${resources} ; do

        # copy files that need to be unwarped
        resource_name=${resource_dir##*/}
        scan_name=${resource_name%_unproc}
        copy_to_dir=${outdir}/${subject}/unprocessed/3T/${scan_name}

        log_Msg "copying image files from ${resource_dir}"
        mkdir -p ${copy_to_dir}
        cp --dereference ${resource_dir}/*.nii.gz ${copy_to_dir}

        # copy associated files
        if [ -d ${resource_dir}/LINKED_DATA ] ; then
            log_Msg "copying LINKED_DATA"
            cp --recursive --dereference ${resource_dir}/LINKED_DATA ${copy_to_dir}
        fi

        if [ "${scan_name}" == "Diffusion" ] ; then
            log_Msg "copying bval"
            cp --dereference ${resource_dir}/*.bval ${copy_to_dir}
            log_Msg "copying bec"
            cp --dereference ${resource_dir}/*.bvec ${copy_to_dir}
        fi

        # unwarp image files
        image_dir=${copy_to_dir}
        working_dir=${image_dir}/gdc
        mkdir -p ${working_dir}/xfms
                
        image_files=`ls ${image_dir}/*.nii.gz`
        
        for image_file in ${image_files} ; do
            
            image_file_base=${image_file%.nii.gz}
            image_file_base=${image_file_base##*/}
            
            coeffs_file=${HCPPIPEDIR_Config}/coeff_SC72C_Skyra.grad
            in_file=${image_dir}/${image_file_base}
            out_file=${working_dir}/${image_file_base}_gdc 
            out_warpfile=${working_dir}/xfms/${image_file_base}_gdc_warp
            
            log_Msg "working_dir: ${working_dir}"
            log_Msg "coeffs_file: ${coeffs_file}"
            log_Msg "in_file: ${in_file}"
            log_Msg "out_file: ${out_file}"
            log_Msg "out_warpfile: ${out_warpfile}"
            
            ${HCPPIPEDIR_Global}/GradientDistortionUnwarp.sh \
                --workingdir=${working_dir} \
                --coeffs=${coeffs_file} \
                --in=${in_file} \
                --out=${out_file} \
                --owarp=${out_warpfile}

            if [ "${scan_name}" == "Diffusion" ] ; then

                if [[ ${image_file_base} == *DWI* && ${image_file_base} != *SBRef* ]] ; then

                    echo "Computing gradient coil tensor"
                    ${FSLDIR}/bin/calc_grad_perc_dev --fullwarp=${out_warpfile} -o ${working_dir}/grad_dev
                    ${FSLDIR}/bin/fslmerge -t ${working_dir}/grad_dev ${working_dir}/grad_dev_x ${working_dir}/grad_dev_y ${working_dir}/grad_dev_z
                    ${FSLDIR}/bin/fslmaths ${working_dir}/grad_dev -div 100 ${working_dir}/grad_dev # Convert from % deviation to absolute
                    ${FSLDIR}/bin/imrm ${working_dir}/grad_dev_?
                    ${FSLDIR}/bin/imrm ${working_dir}/trilinear
                    ${FSLDIR}/bin/imrm ${working_dir}/data_warped_vol1
                fi
            fi

        done
        
    done
}

#
# Main processing
#
main() {
    get_options $@

    resources_dir="/data/hcpdb/archive/${project}/arc001/${subject}_3T/RESOURCES"

    # gradient unwarp T1w images
    unwarp_images "${resources_dir}/T1w*_unproc"

    # gradient unwarp T2w images
    unwarp_images "${resources_dir}/T2w*_unproc"

    # gradient unwarp functional resting state images
    unwarp_images "${resources_dir}/rfMRI*_unproc"

    # gradient unwarp functional task images
    unwarp_images "${resources_dir}/tfMRI*_unproc"

    # gradient unwarp diffusion imags
    unwarp_images "${resources_dir}/Diffusion_unproc"

    log_Msg "Complete"
}


# Setup environment
setup_environment

# Load function libraries
source ${HCPPIPEDIR}/global/scripts/log.shlib # log_ functions
log_SetToolName $(basename ${0})

# Invoke the main function
main $@
