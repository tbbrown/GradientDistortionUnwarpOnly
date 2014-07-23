#!/bin/bash

#
# Function description
#  Show usage information for this script
#
usage() {
    local scriptName=$(basename ${0})
    echo ""
    echo "  Usage: ${scriptName} --checkdir=<check-dir>"
    echo ""
}

#
# Function description
#  Get the command line options for this script
#
# Global output variables
#  ${checkdir} - directory to check
#
get_options() {
    local scriptName=$(basename ${0})
    local arguments=($@)

    # initialize global output variables
    unset checkdir

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
            --checkdir=*)
                checkdir=${argument/*=/""}
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
    if [ -z ${checkdir} ]; then
        usage
        echo "ERROR: <check-dir> not specified"
        exit 1
    fi

    # report
    echo "-- ${scriptName}: Specified command-line options - Start --"
    echo "   checkdir: ${checkdir}"
    echo "-- ${scriptName}: Specified command-line options - End --"
}

#
# Main processing
#
main() {
    get_options $@

    local filesCheckedCount=0
    local failuresCount=0

    filelist=`find ${checkdir} -name "*.nii.gz" | grep --invert-match "_gdc"`

    for image_file in ${filelist} ; do
        filesCheckedCount=$(( filesCheckedCount + 1 ))

        image_file_base=${image_file%.nii.gz}
        gdc_file=${image_file_base}_gdc.nii.gz

        if [ ! -f "${gdc_file}" ]; then
            echo "FAILURE: ${gdc_file} should exist but does not"
            failuresCount=$(( failuresCount + 1 ))
        fi
    done

    echo "-- ${scriptName}: Results - Start --"
    echo "   filesCheckedCount: ${filesCheckedCount}"
    echo "   failuresCount: ${failuresCount}"
    echo "-- ${scriptName}: Results - End --"
}

# Invoke the main function
main $@
