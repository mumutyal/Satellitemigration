#!/bin/bash
# Array pretending to be a Pythonic dictionary
ARRAY=( "n2-standard-4:b3c.4x16"
        "n2-standard-16:b3c.4x16"
        "n2-standard-64:b3c.16x64"
        "n2-standard-32:b3c.32x128"
        "n2-standard-128:m3c.16x128"
        "n2-standard-384:m3c.48x384" )
get_ibm_flavor() {
    type=$1
    for instance_type in "${ARRAY[@]}" ; do
        KEY="${instance_type%%:*}"
        VALUE="${instance_type##*:}"
        if [ $KEY == $type ]
        then
	   retval="$VALUE"
           printf "$VALUE"
        fi
    done
    #echo "$retval"
}
