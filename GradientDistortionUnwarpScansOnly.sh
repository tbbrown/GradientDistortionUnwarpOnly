#!/bin/bash

# 
# Function description
#  Setup the environment
#
setup_environment() {
    node_indicator=`uname -n | cut -c1-6`

    export FSLDIR=/nrgpackages/tools.release/fsl-5.0.6-centos6_64
    export HCPPIPEDIR=/home/NRG/tbrown01/projects/Pipelines

    if [ "${node_indicator}" == "ubuntu" ] ; then
        export FSLDIR=/usr/share/fsl/5.0
        export HCPPIPEDIR=/home/tbb/projects/Pipelines
    fi

    . ${FSLDIR}/etc/fslconf/fsl.sh

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
# Main processing
#
main() {
    get_options $@

    # copy subject files to output directory
    subject_dir="/data/intradb/archive/${project}/arc001/${subject}"
    
    log_Msg "copying specified subject directory to output location"
    log_Msg "From: ${subject_dir}"
    log_Msg "To: ${outdir}"
    cp --verbose --recursive --dereference ${subject_dir} ${outdir}

    scans_dir="${outdir}/${subject}/SCANS"

    scan_dirs=`ls ${scans_dir}`
    for scan_dir in ${scan_dirs} ; do
        log_Msg "Processing scan_dir: ${scan_dir}"

        full_scan_dir=${scans_dir}/${scan_dir}
        log_Msg "full_scan_dir: ${full_scan_dir}"

        image_dir=${full_scan_dir}/NIFTI
        log_Msg "image_dir: ${image_dir}"

        working_dir=${image_dir}/gdc
	echo "mkdir -p ${working_dir}/xfms"
        mkdir -p ${working_dir}/xfms

        image_files=`ls ${image_dir}/*.nii.gz`

        for image_file in ${image_files} ; do

            log_Msg "image_file: ${image_file}"
            
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

        done

        # move the generated _gdc.nii.gz files out of the gdc subdirectory up to the main directory
        mv -v ${working_dir}/*_gdc.nii.gz ${image_dir}

        # remove the working directory with all the unneeded intermediate files
        rm -rfv ${working_dir}

    done

    log_Msg "Complete"
}

# Setup environment
setup_environment

# Load function libraries
source ${HCPPIPEDIR}/global/scripts/log.shlib # log_ functions
log_SetToolName $(basename ${0})

# Invoke the main function
main $@
