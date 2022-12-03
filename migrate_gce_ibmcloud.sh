#!/bin/bash

export gce_workers_array=()
export gce_worker_type=""
source retrive_provider_data.sh
source get_mapping_ibm_flavor.sh
get_location_id_v2() {
    location_get_info_json() {
        ibmcloud sat location get --location "${CRUISER_CLUSTER}" --output json >/tmp/location_id.json
    }
    retry_function_v2 location_get_info_json || return 1
    LOCATION_ID=$(jq -r '.id' /tmp/location_id.json)
    rm /tmp/location_id.json
    export LOCATION_ID
}

get_location_deployment_v2() {
    location_get_info_json() {
        ibmcloud sat location get --location "${LOCATION_ID}" --json >/tmp/location_deployment.json
    }
    retry_function_v2 location_get_info_json || return 1
}

get_location_zones_v2() {
    get_location_deployment_v2 || return 1
    WORKER_ZONES=$(jq -r '.workerZones | .[]' /tmp/location_deployment.json)
    rm /tmp/location_deployment.json
    export WORKER_ZONES
}

get_location_workers_v2() {
    LOCATION_ID=$1
    WORKER_IDS=$(ibmcloud sat host ls --location  $LOCATION_ID  | grep assigned| awk '{ print $2 }')
    WORKER_NAMES=$(ibmcloud sat host ls --location $LOCATION_ID | grep assigned| awk '{ print $1 }')
    export WORKER_IDS
    export WORKER_NAMES
}

start_migration () {

    for workername in $WORKER_NAMES; do
         echo "Found the google worker with name $workername on the satellite location"
         echo "Retreving the GCE worker inofrmation from the google cloud"
	 get_gce_worker_info $workername 
         ibm_flavor=$(get_ibm_flavor $gce_worker_type)
         echo "IBM instance of flavor $ibm_flavor is being provisioned for the GCE worker $gce_worker_type"
         #provision_ibm_instance(ibm_flavor)
         echo "Provisoning the IBM virtual instance corresponding to GCE instance" 
         #attachibmworkernode
         #sleep 30
         #assignibmworkernode 
         sleep 30        
    done
}


if [ -z "$1" ]
then
   doaction=false
   echo "Please provide satellite location id usage : ./migrate_gce_ibmcloud.sh  sat-location-id"
   exit 1
fi
LOCATION_ID=$1
get_location_workers_v2 $LOCATION_ID
echo "Starting the infrastructure migraiton process"
sleep 30
start_migration

