#!/bin/bash

#For Running Script write bash <*.sh> <project name for promtail> <project name for loki> <apply or delete>
## exampl # bash loki_promtail.sh kube-system metrics apply

#######################################
############## Enviroment #############
#######################################
LIGHT_GREAN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

grafana_yaml="grafana_oauth.yaml"
loki_yaml="loki_deployment.yaml"
promtail_yaml="promtail_daemonset.yaml"

promtail_service_account="promtail-sa"
loki_service_account="promtail-sa"

# node_selector="openshift-demo257-node-0"

PROMTAIL_NAMESPACE="$1"
LOKI_NAMESPACE="$2"

#######################################
############## Function: ##############
####### Check for apply/delete ########
#######################################
check_args () {
case $4 in
  (apply|delete) ;; # OK
  (*) printf >&2 "Wrong arg.${2}${4}${3}. Allowed are ${1}apply${3} or ${1}delete${3} \n";
      printf >&2 "!!! \n";
      printf >&2 "syntax: bash <*.sh> <project name for promtail> <project name for loki> <apply or delete> \n";
      printf >&2 "## \n";
      printf >&2 "example: bash loki_promtail.sh kube-system openshift-metrics apply \n";exit 1;;
esac
}
#######################################
############## Function:  #############
### Function: Approve process Name ####
#######################################
approve_yes_no_other () {
while true; do
    printf "${1}Continue with names as above:${3}\n"
    printf "Promtail project name :${2}${4}${3}\n"
    printf "Loki project name :${2}${5}${3}\n"
    read -p "yes(Yn) to process with names as above / no(Nn) to stop process " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) printf "\n${2}Please answer yes or no ${3}\n";;
    esac
done
}

check_args ${LIGHT_GREAN} ${RED} ${NC} ${3}
approve_yes_no_other ${LIGHT_GREAN} ${RED} ${NC} ${PROMTAIL_NAMESPACE} ${LOKI_NAMESPACE}

if [ "$3" == "apply" ]
    then
        PROCESS=Implementation
        printf "${LIGHT_GREAN}${PROCESS} Grafana on cluster${NC}\n"
        oc process -f ${grafana_yaml} -p NAMESPACE=${LOKI_NAMESPACE} | oc $3 -f -
        oc rollout status deployment/grafana -n ${LOKI_NAMESPACE}
        printf "${LIGHT_GREAN}${PROCESS} Loki on cluster${NC}\n"
        oc process -f ${loki_yaml} -p LOKI_PROJECT_NAME=${LOKI_NAMESPACE} | oc $3 -f -
        oc rollout status deployment/loki -n ${LOKI_NAMESPACE}
        printf "${LIGHT_GREAN}${PROCESS} Promtail on cluster${NC}\n"
        oc process -f ${promtail_yaml} -p PROMTAIL_PROJECT_NAME=${PROMTAIL_NAMESPACE} -p LOKI_PROJECT_NAME=${LOKI_NAMESPACE} | oc $3 -f -
fi

if [ "$3" == "delete" ]
    then
        PROCESS=Removing
        printf "${LIGHT_GREAN}${PROCESS} Grafana on cluster${NC}\n"
        oc process -f ${grafana_yaml} -p NAMESPACE=${LOKI_NAMESPACE} | oc $3 -f -
        printf "${LIGHT_GREAN}${PROCESS} Loki on cluster${NC}\n"
        oc process -f ${loki_yaml} -p LOKI_PROJECT_NAME=${LOKI_NAMESPACE} | oc $3 -f -
        printf "${LIGHT_GREAN}${PROCESS} Promtail on cluster${NC}\n"
        oc process -f ${promtail_yaml} -p PROMTAIL_PROJECT_NAME=${PROMTAIL_NAMESPACE} -p LOKI_PROJECT_NAME=${LOKI_NAMESPACE} | oc $3 -f -

fi