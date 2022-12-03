#!/bin/bash
gce_login () {
    export GCE_PROJECT="satellite-runtime"
    echo "Setting the configuration for the google provider for profiling"
    gcloud config set account mumutyal@in.ibm.com
        # shellcheck disable=SC2181
        if [[ $? != 0 ]]; then
            error "$gce_auth"
            return 1
        fi
        # shellcheck disable=SC2153
        gce_project=$(gcloud config set project "${GCE_PROJECT}")
        # shellcheck disable=SC2181
        if [[ $? != 0 ]]; then
            error "$gce_project"
            return 1
        fi
    return 0
}
get_gce_worker_info () {
	instance_name=$1
        gcloud compute instances describe $instance_name
        echo -e "\n\n"
 	machine_type_url=$(gcloud compute instances describe $instance_name  --format="json" | jq -r .machineType)
        echo "Trying to get the google cloud virtual instance machinetype ..."
        echo -e "\n"
        sleep 5
        gce_worker_type=$(echo $machine_type_url | sed 's:.*/::')
        echo "Found the google instance of machinetype $gce_worker_type"
        export gce_worker_type
}




