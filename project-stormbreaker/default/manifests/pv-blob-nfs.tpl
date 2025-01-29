apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: blob.csi.azure.com
  name: pv-blob
spec:
  capacity:
    storage: 1Pi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain  # If set as "Delete" container would be removed after pvc deletion
  storageClassName: azureblob-nfs-premium
  mountOptions:
    - nconnect=4
  csi:
    driver: blob.csi.azure.com
    # make sure volumeid is unique for every identical storage blob container in the cluster
    # character `#` and `/` are reserved for internal use and cannot be used in volumehandle
    volumeHandle: account-name_container-name
    volumeAttributes:
      resourceGroup: RESOURCE_GROUP_NAME
      storageAccount: STORAGE_ACCOUNT
      containerName: CONTAINER_NAME
      protocol: nfs
