#
# This script provides a set of commands to manage the deployment of resources in Azure and Kubernetes for the Refinitiv pattern on Azure.
# It requires Azure CLI, jq, and terraform to be installed. The available commands are:
# - install: creates all of the resources in Azure and in Kubernetes
# - demo: deploy the scripts for the demo
# - destroy: deletes all of the components in Azure plus any KUBECONFIG and Terraform files
# - show: shows information about the demo environment (e.g.: connection strings)
#
# Usage: ./run.sh [-x action]

#!/usr/bin/env bash
# shfmt -i 2 -ci -w
set -e

# Requirements:
# - Azure CLI
# - jq
# - terraform

source install-demo.sh

__usage="
Available Commands:
    [-x  action]        action to be executed.

    Possible verbs are:
        install         creates all of the resources in Azure and in Kubernetes
        demo            deploy the scripts for the demo
        destroy         deletes all of the components in Azure plus any KUBECONFIG and Terraform files
        show            shows information about the demo environment (e.g.: connection strings)
        start-adcirc    deployed ADCIRC+SWAN to the cluster
        stop-adcirc     deletes ADCIRC+SWAN from the cluster
"

usage() {
  echo "usage: ${0##*/} [options]"
  echo "${__usage/[[:space:]]/}"
  exit 1
}

checkDependencies() {
  # check if the dependencies are installed
  local _NEEDED="az jq terraform"
  local _DEP_FLAG="false"

  echo -e "Checking dependencies ...\n"
  for i in seq ${_NEEDED}; do
    if hash "$i" 2>/dev/null; then
      # do nothing
      :
    else
      echo -e "\t $_ not installed".
      _DEP_FLAG=true
    fi
  done

  if [[ "${_DEP_FLAG}" == "true" ]]; then
    echo -e "\nDependencies missing. Please fix that before proceeding"
    exit 1
  fi

  # we need to check for the demo depencies here before running TF
  local _AZURE_FEATURES="
    Microsoft.ContainerService/AKS-PrometheusAddonPreview 
    Microsoft.ContainerService/EnableWorkloadIdentityPreview
    Microsoft.ContainerService/EnableEncryptionAtHostPreview
    Microsoft.ContainerService/AKSInfinibandSupport
    Microsoft.Compute/EncryptionAtHost"

  for i in ${_AZURE_FEATURES}; do
    demo_providers $i
  done
}

start-adcirc() {
  kubectl apply -f manifests/hpc/queue.yaml
  kubectl apply -f manifests/hpc/
}

stop-adcirc() {
  kubectl delete -f manifests/hpc/adcirc-hpc.yaml
}

terraformDance() {
  # Assumes you're already logged into Azure
  terraform init
  terraform plan -out tfplan
  terraform apply -auto-approve tfplan
}

show() {
  terraform output -json | jq -r 'to_entries[] | [.key, .value.value]'
}

destroy() {
  # remove all of the infrastructured
  terraform destroy -auto-approve
  rm -rf \
    terraform.tfstate \
    terraform.tfstate.backup \
    tfplan \
    .terraform \
    .terraform.lock.hcl \
    config
}

run() {
  terraformDance
  do_demo_bootstrap
}

exec_case() {
  local _opt=$1

  case ${_opt} in
    install) checkDependencies && run ;;
    destroy) destroy ;;
    demo) do_demo_bootstrap ;;
    show) show ;;
    start-adcirc) start-adcirc ;;
    stop-adcirc) stop-adcirc ;;
    *) usage ;;
  esac
  unset _opt
}

while getopts "x:" opt; do
  case $opt in
    x)
      exec_flag=true
      EXEC_OPT="${OPTARG}"
      ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

if [ $OPTIND = 1 ]; then
  usage
  exit 0
fi

if [[ "${exec_flag}" == "true" ]]; then
  exec_case "${EXEC_OPT}"
fi

exit 0
