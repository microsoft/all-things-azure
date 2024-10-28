---
post_title: 'Multi-Cluster Layer 4 Load Balancing with Fleet Manager'
author1: dicasati
post_slug: multi-cluster
categories: azure
tags: Azure
summary: How to configure a multi-cluster layer 4 load balancer across multiple AKS clusters using Fleet Manager.
---

# Multi-Cluster Layer 4 Load Balancing with Fleet Manager

This guide demonstrates how to set up layer 4 load balancing across multiple AKS clusters using Azure Fleet Manager. We’ll create two AKS clusters in different regions (East US and West US), configure Virtual Network (VNet) peering between them, and deploy a demo application using 
Fleet Manager. The process covers AKS cluster setup, VNet peering, Fleet Manager configuration, and application deployment across regions.

### Why and When to Use Multi-Cluster Layer 4 Load Balancing for AKS

In distributed Kubernetes environments, handling north-south traffic (traffic that flows in and out of a data center or cloud region) across multiple AKS clusters is crucial for achieving high availability and optimized performance. Multi-cluster Layer 4 load balancing, managed through Azure Fleet Manager, is a powerful approach to address this need within a region. Here's why it's beneficial:

#### Key Benefits of North-South Multi-Cluster Layer 4 Load Balancing

1. **Cross-Cluster High Availability**  
   North-south Layer 4 load balancing ensures that traffic coming into an Azure region is distributed across multiple AKS clusters. This helps maintain uptime by automatically routing incoming traffic to available clusters if one becomes unavailable, ensuring reliable access for users.

2. **Optimized Regional Traffic Management**  
   Deploying clusters in different Azure regions and leveraging regional Layer 4 load balancing helps optimize how traffic is directed to those clusters, reducing latency for end-users. This is particularly important for applications with a high volume of north-south traffic, such as APIs or web applications.

3. **Scalable Traffic Handling**  
   Multi-cluster Layer 4 load balancing provides scalability by distributing incoming traffic evenly between AKS clusters in a region. This prevents any one cluster from being overwhelmed, which is critical for scaling applications efficiently during traffic spikes.

4. **Centralized Control with Fleet Manager**  
   Azure Fleet Manager offers centralized management for multiple AKS clusters, enabling a consistent and streamlined approach to north-south load balancing across clusters in the same region. This makes deploying and managing applications across clusters simpler and more cohesive.

#### Technical Overview

Multi-cluster Layer 4 load balancing through Azure Fleet Manager simplifies regional traffic handling for north-south traffic across AKS clusters:

1. **Deploy Clusters in Target Regions**  
   Start by creating AKS clusters in each target region (e.g., East US and West US) to distribute traffic regionally.

2. **Implement VNet Peering**  
   Use VNet peering for secure, low-latency communication between clusters in the same region or across regions. This enables efficient cross-cluster routing for north-south traffic.

3. **Register with Fleet Manager**  
   Use Azure Fleet Manager to register the clusters, providing a centralized point of control for deployment and configuration management.

4. **Set Up MultiClusterService (MCS)**  
   MCS handles Layer 4 traffic distribution, ensuring that north-south traffic is efficiently routed across clusters without requiring complex configurations at the application layer.

By leveraging Azure Fleet Manager for multi-cluster Layer 4 load balancing, teams can ensure robust and scalable traffic handling for north-south traffic within a region. This setup supports high availability, optimized latency, and simplified cluster management.

### Topology

```
+-----------------------+          +-----------------------+
|    AKS Cluster (East) |          |    AKS Cluster (West) |
|  Region: East US      |          |  Region: West US      |
|                       |          |                       |
| +-------------------+ |          | +-------------------+ |
| |   Application     | |          | |   Application     | |
| +-------------------+ |          | +-------------------+ |
|                       |          |                       |
+-----------------------+          +-----------------------+
          |                                      |
          +--------------------------------------+
                        VNet Peering

             +-----------------------------------+
             |    Fleet Manager (Hub Region)     |
             +-----------------------------------+
```

- [x] AKS Cluster (East): A Kubernetes cluster deployed in the East US region.
- [x] AKS Cluster (West): A Kubernetes cluster deployed in the West US region.
- [x] VNet Peering: Virtual Network peering between the AKS clusters to enable communication.
- [x] Fleet Manager: Azure Fleet Manager deployed in the hub region, managing the application across both AKS clusters.

### Create two AKS clusters

For this demo, we will create two AKS clusters in two regions: East and West.

#### Create the cluster in East US
  
```bash
export LOCATION_EAST=eastus2
export RESOURCE_GROUP_EAST="rg-aks-$LOCATION_EAST"
export CLUSTER_NAME_EAST="aks-$LOCATION_EAST"
export AKS_EAST=${CLUSTER_NAME_EAST}

# Create a resource group for the cluster in East US
az group create \
  --name ${RESOURCE_GROUP_EAST} \
  --location ${LOCATION_EAST}

# Create an AKS cluster
az aks create \
  --resource-group ${RESOURCE_GROUP_EAST} \
  --name ${CLUSTER_NAME_EAST} \
  --network-plugin azure

# get the cluster credentials (East US)
az aks get-credentials \
  --resource-group ${RESOURCE_GROUP_EAST} \
  --name ${AKS_EAST} \
  --file east-aks
```
After the deployment, we need to save the cluster id. This information will be used later when we join the cluster to Fleet Manager as a member:

```bash
export AKS_EAST_ID=$(az aks show -n ${CLUSTER_NAME_EAST} -g ${RESOURCE_GROUP_EAST} -o tsv --query id)
```
Now repeat the same process for the cluster in West US:

```bash
export LOCATION_WEST=westus2
export RESOURCE_GROUP_WEST="rg-aks-$LOCATION_WEST"
export CLUSTER_NAME_WEST="aks-$LOCATION_WEST"
export AKS_WEST=${CLUSTER_NAME_WEST}

# Create a resource group for the cluster in West US
az group create \
  --name ${RESOURCE_GROUP_WEST} \
  --location ${LOCATION_WEST}

# Create an AKS cluster with Azure CNI
az aks create \
  --resource-group ${RESOURCE_GROUP_WEST} \
  --name ${CLUSTER_NAME_WEST} \
  --network-plugin azure

# get the cluster credentials (West US)
az aks get-credentials \
  --resource-group ${RESOURCE_GROUP_WEST} \
  --name ${AKS_WEST} \
  --file west-aks

# cluster ID
export AKS_WEST_ID=$(az aks show -n ${CLUSTER_NAME_WEST} -g ${RESOURCE_GROUP_WEST} -o tsv --query id)
```

#### Create the VNets and peer them

Create the VNet for East US:

```bash
# Create VNet for East US and peer with West US
create_vnet_and_subnet "$RESOURCE_GROUP_EAST" "$CIDR_EAST" "aks-vnet-east" "$SUBNET_NAME_EAST" "10.1.0.0/24"
SUBNET_ID_EAST=$(get_subnet_id "$RESOURCE_GROUP_EAST" "aks-vnet-east" "$SUBNET_NAME_EAST")
```

Create the VNet for West US:

```bash
# Create VNet for West US and peer with East US
create_vnet_and_subnet "$RESOURCE_GROUP_WEST" "$CIDR_WEST" "aks-vnet-west" "$SUBNET_NAME_WEST" "10.2.0.0/24"
SUBNET_ID_WEST=$(get_subnet_id "$RESOURCE_GROUP_WEST" "aks-vnet-west" "$SUBNET_NAME_WEST")
```

Peer the VNets between East and West US:

```bash
# Peer VNets between East and West
peer_vnets "aks-vnet-east" "aks-vnet-west" "$RESOURCE_GROUP_EAST" "aks-vnet-east" "$VNET_ID_WEST" \
"$RESOURCE_GROUP_WEST" "aks-vnet-west" "$VNET_ID_EAST"
```

#### Create a Fleet Manager and add members to it

Add the fleet extension to Azure CLI

```bash
az extension add --name fleet
```

Create the Fleet Manager resource

```bash
# setup varibles for Fleet Manager
export FLEET_RESOURCE_GROUP_NAME=rg-fleet
export FLEET=gbb-fleet
export FLEET_LOCATION=westus

# create the resource group
az group create \
  --name ${FLEET_RESOURCE_GROUP_NAME} \
  --location ${FLEET_LOCATION}

# create fleet resource
az fleet create \
  --resource-group ${FLEET_RESOURCE_GROUP_NAME} \
  --name ${FLEET} \
  --location ${FLEET_LOCATION} \
  --enable-hub
```

Retrieve the Cluster IDs for East and West clusters:

```bash
# Retrieve Cluster IDs (East and West)
export AKS_EAST_ID=$(az aks show --resource-group ${RESOURCE_GROUP_EAST} --name ${CLUSTER_NAME_EAST} --query "id" -o tsv)
export AKS_WEST_ID=$(az aks show --resource-group ${RESOURCE_GROUP_WEST} --name ${CLUSTER_NAME_WEST} --query "id" -o tsv)
```

Now join both clusters to the Fleet:

```bash
# join the East US cluster
az fleet member create \
  --resource-group ${FLEET_RESOURCE_GROUP_NAME} \
  --fleet-name ${FLEET} \
  --name ${AKS_EAST} \
  --member-cluster-id ${AKS_EAST_ID}

# join the West US cluster
az fleet member create \
  --resource-group ${FLEET_RESOURCE_GROUP_NAME} \
  --fleet-name ${FLEET} \
  --name ${AKS_WEST} \
  --member-cluster-id ${AKS_WEST_ID}
```

#### Deploy the AKS store application

For this next step, we will deploy the AKS Store demo application to both clusters, 
East and West, using Fleet. Fleet Manager will work as a centralized hub, sending the
configuration and deployment files to its member clusters.

Deploy the application:

```bash
# create the namespace for the application
KUBECONFIG=fleet kubectl create ns aks-store-demo

# deploy the application on both clusters thru Fleet
KUBECONFIG=fleet kubectl apply -n aks-store-demo -f  https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/main/aks-store-ingress-quickstart.yaml
KUBECONFIG=fleet kubectl apply -n aks-store-demo -f aks-store-serviceexport.yaml
```

**Create the ClusterResourcePlacement (CRP)**:

```bash
cat <<EOF > cluster-resource-placement.yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: aks-store-demo
spec:
  resourceSelectors:
    - group: ""
      version: v1
      kind: Namespace
      name: aks-store-demo
  policy:
    affinity:
      clusterAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          clusterSelectorTerms:
            - labelSelector:
                matchExpressions:
                  - key: fleet.azure.com/location
                    operator: In
                    values:
                      - eastus2
                      - westus2
EOF

kubectl apply -f cluster-resource-placement.yaml
```

**Create and deploy MultiClusterService (MCS)**:

```bash
cat <<EOF > aks-store-mcs.yaml
apiVersion: networking.fleet.azure.com/v1alpha1
kind: MultiClusterService
metadata:
  name: store-front
  namespace: aks-store-demo
spec:
  serviceImport:
    name: store-front
EOF

# Deploy the MultiClusterService resource
KUBECONFIG=east-aks kubectl apply -f aks-store-mcs.yaml
```
#### Testing the Application

Once the MultiClusterService (MCS) has been successfully deployed across the AKS clusters, you can test the application to ensure it's working properly. Follow these steps to verify the setup:

**Get the external IP address of the service**:

After deploying the MultiClusterService, you need to retrieve the external IP address to access the service. Run the following command to get the external IP for both clusters:

```bash
KUBECONFIG=east-aks kubectl get services -n aks-store-demo
KUBECONFIG=west-aks kubectl get services -n aks-store-demo
```
Look for the external IP under the EXTERNAL-IP column for the store-front service.

**Access the application**:

Once you have the external IP addresses from both clusters, open a browser or use curl to access the application using the IP addresses:

```bash
curl http://<external-ip>
```

Replace <external-ip> with the actual external IP you retrieved from the previous step. The application should be accessible through either of the IPs.

Validate cross-region load balancing:

Since the `MultiClusterService` has been deployed across multiple regions, traffic can be balanced between the AKS clusters. You can simulate 
traffic from different regions using tools like curl, Postman, or load-testing utilities to confirm that the service is responding from both regions.

**Verify service status**:

You can check the status of the deployed services and pods on both clusters to ensure everything is running correctly:

```bash
KUBECONFIG=east-aks kubectl get pods -n aks-store-demo
KUBECONFIG=west-aks kubectl get pods -n aks-store-demo
```
Ensure that all services and pods show a Running status, indicating that the application is running across both clusters.

#### Remove the setup
To remove this setup, you can run the following set of commands:

```bash
# East cluster
az group delete --name ${RESOURCE_GROUP_EAST} --yes --no-wait

# West cluster
az group delete --name ${RESOURCE_GROUP_WEST} --yes --no-wait

# Fleet Hub
az group delete --name ${FLEET_RESOURCE_GROUP_NAME} --yes --no-wait
```

### Conclusion
In this guide, we successfully set up a multi-cluster layer 4 load balancer across 
AKS clusters using Azure Fleet Manager. By configuring AKS clusters in different regions, 
establishing VNet peering, and utilizing Fleet Manager, we enabled centralized management 
and deployment of services across clusters. This approach ensures improved availability and 
scalability for applications deployed across multiple regions.

For the full deployment script used in this tutorial, you can access 
the App Innovation GBB GitHub repository: [Pattern - Multi-Cluster Layer 4 Load Balancer with Azure Fleet Manager](https://github.com/appdevgbb/pattern-fleet-manager/tree/main).