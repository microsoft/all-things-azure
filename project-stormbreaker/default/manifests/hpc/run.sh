#! /bin/bash

# Apply required manifests
kubectl get namespace nvidia-operator 2>/dev/null || kubectl create namespace nvidia-operator

# Install node feature discovery
helm upgrade -i --wait \
  -n nvidia-operator node-feature-discovery node-feature-discovery \
  --repo https://kubernetes-sigs.github.io/node-feature-discovery/charts \
  --set-json master.nodeSelector='{"kubernetes.azure.com/mode": "system"}' \
  --set-json worker.nodeSelector='{"kubernetes.azure.com/agentpool": "adcirchpc"}' \
  --set-json worker.config.sources.pci.deviceClassWhitelist='["02","03","0200","0207"]' \
  --set-json worker.config.sources.pci.deviceLabelFields='["vendor"]'

# Install the network-operator
helm upgrade -i --wait \
  -n nvidia-operator network-operator network-operator \
  --repo https://helm.ngc.nvidia.com/nvidia \
  --set deployCR=true \
  --set nfd.enabled=false \
  --set ofedDriver.deploy=true \
  --set secondaryNetwork.deploy=false \
  --set rdmaSharedDevicePlugin.deploy=true \
  --set sriovDevicePlugin.deploy=true \
  --set-json sriovDevicePlugin.resources='[{"name":"mlnxnics","linkTypes": ["infiniband"], "vendors":["15b3"]}]'
# Note: use --set ofedDriver.version="<MOFED VERSION>"
#       to install a specific MOFED version
#