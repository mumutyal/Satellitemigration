#!/bin/bash
export ATTACH_SCRIPT_LOCATION=/Users/murali/bootstrap/Hackthion_Code_22/code/host_attach.sh
satellite_cluster_host_assign() {
    retry_function_v2 get_host_list || return 1

    if [[ -n "$SINGLE_NODE" ]]; then
        set_host_os_label "1"
        handle_host_assignment "ibmcloud sat host assign --cluster ${SATELLITE_CLUSTER} --location ${LOCATION_ID} ${HOST_OS_LABEL}" "4" || return 1
    else
        set_host_os_label "1"
        handle_host_assignment "ibmcloud sat host assign --cluster ${SATELLITE_CLUSTER} --location ${LOCATION_ID} ${HOST_OS_LABEL}" "4" || return 1

        set_host_os_label "2"
        handle_host_assignment "ibmcloud sat host assign --cluster ${SATELLITE_CLUSTER} --location ${LOCATION_ID} ${HOST_OS_LABEL}" "5" || return 1
    fi
}

set_host_os_label() {
    count=$1

    if [[ -n "$RHEL7" ]]; then
        HOST_OS_LABEL=RHEL7
    elif [[ -n "$RHEL8" ]]; then
        HOST_OS_LABEL=RHEL8
    else
        HOST_OS_LABEL=$(jq '.[] | select(.state=="unassigned")' /tmp/host_list.json | jq -r ."labels.os" | awk "NR==$count")
    fi

    if [[ -n "$HOST_OS_LABEL" ]]; then
        HOST_OS_LABEL="--host-label os=$HOST_OS_LABEL"
    fi
}


order_softlayer_workers() {
            #shellcheck disable=SC2154
             "slcli -y vs create -H sat-e2e-${LOCATION_ID}-${i} -D cloud.ibm --image ${IMAGE_ID} -c ${flavor} -m 16384 --userfile ${ATTACH_SCRIPT_LOCATION} --datacenter ${DATA_CENTER} --vlan-public ${public_vlan} --vlan-private ${private_vlan}" || return 1

        export PRE_ATTACH_COMMANDS="sleep 300; subscription-manager refresh; subscription-manager repos --enable=*;"
        update_attach_script "${PRE_ATTACH_COMMANDS}"
        IMAGE_ID=${SL_RHEL7_IMAGE_ID}
}

assign_hosts_to_location() {
        ibmcloud sat host assign  --location ${LOCATION_ID} --zone ${ZONE}  || return 1
    done <<<"${WORKER_ZONES}"
}

get_host_list() {
    ibmcloud sat host ls --location "${LOCATION_ID}" --output json >/tmp/host_list.json
}
