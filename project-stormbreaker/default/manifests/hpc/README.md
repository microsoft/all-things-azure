Enable the Infiniband feature flag:

```bash
az feature register --name AKSInfinibandSupport --namespace Microsoft.ContainerService
```

### Building a Docker image
OpenMPI and ADCIRC+SWAN need to be compiled on the specific hardware family it will be executed on, otherwise it will fail with a SIGILL (Illegal Instruction) error. In order to compile them for the HBv3 series, one approach is to use a priviledge container and `podman`. Here is an exmaple:

```bash
# create a priviledge pod
cat <<EOF | kubectl apply -f -
kind: Pod
apiVersion: v1
metadata:
  name: adcirc-debug
spec:
  containers:
    - image: ubuntu:latest
      name: adcirc-debug
      securityContext:
        privileged: true
      command:
      - /bin/sh
      - -c
      - |
        apt update ; apt install -y infiniband-diags vim podman; sleep 3600;
EOF

# exec into the container
kubectl exec -it  podman

# modify the registy.conf
sed -i 's/# unqualified-search-registries = \["example.com"\]/unqualified-search-registries = \["docker.io"\]/' /etc/containers/registries.conf  

# build the container
podman build --format docker -t stormbreakeracrdc.azurecr.io/adcird-tests:55.dev.openmpi-beta-3 .

# login to ACR and push the container to the registry
podman login ${YOUR_AZURE_CONTAINER_REGISTRIY} -u ${ACR_USER}
podman push stormbreakeracrdc.azurecr.io/adcird-tests:55.dev.openmpi-beta-3
```

