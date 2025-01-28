apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: azure-servicebus-auth
  namespace: default
spec:
  podIdentity:
    provider: azure-workload
    identityId: USER_ASSIGNED_CLIENT_ID
---
# dispatch
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: servicebus-dispatcher
  namespace: default
spec:
  jobTargetRef:
    parallelism: 1
    completions: 1
    backoffLimit: 4
    template:
      metadata:
        labels:
          azure.workload.identity/use: "true"
      spec:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
              - matchExpressions:
                - key: agentpool
                  operator: In
                  values:
                  - system
        serviceAccount: sa-keda-sb-kubectl
        containers:
        - name: servicebus-dispatcher
          image: ACR_NAME/misc/servicebus-dispatcher:1.0
          imagePullPolicy: Always
          command: ["python3", "/usr/src/app/servicebus_dispatcher.py"]          
          env:
          - name: SERVICE_BUS_FQDN
            value: 'SERVICEBUS_NAME.servicebus.windows.net'
          - name: SERVICE_BUS_QUEUE_DISPATCH
            value: "stormbreaker-dispatch"
          - name: SERVICE_BUS_QUEUE_RUNNING
            value: "stormbreaker-running"
          - name: AZURE_CLIENT_ID
            value: USER_ASSIGNED_CLIENT_ID
          volumeMounts:
          - name: input
            mountPath: "/mnt/input"
            readOnly: false
          - name: output
            mountPath: "/mnt/output"
            readOnly: false
        restartPolicy: Never
        volumes:
        - name: input
          persistentVolumeClaim:
            claimName: pvc-input
        - name: output
          persistentVolumeClaim:
              claimName: pvc-output
  pollingInterval: 10
  maxReplicaCount: 1
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 2
  triggers:
  - type: azure-servicebus  
    metadata:  
      queueName: stormbreaker-dispatch  # service bus queue
      queueLength: '1'
      namespace: SERVICEBUS_NAME  # service bus namespace
    authenticationRef:
      name: azure-servicebus-auth
---
# delete
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: servicebus-remover
  namespace: default
spec:
  jobTargetRef:
    parallelism: 1
    completions: 1
    backoffLimit: 4
    template:
      spec:
        affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: agentpool
                    operator: In
                    values:
                    - system
        serviceAccount: sa-keda-sb-kubectl
        containers:
        - name: servicebus-remover
          image: ACR_NAME/misc/servicebus-remover:1.0
          imagePullPolicy: Always
          command: ["python3", "/usr/src/app/servicebus_remover.py"]          
          env:
          - name: SERVICE_BUS_FQDN
            value: 'SERVICEBUS_NAME.windows.net'
          - name: SERVICE_BUS_QUEUE_DELETE
            value: "stormbreaker-delete"
          - name: SERVICE_BUS_QUEUE_RUNNING
            value: "stormbreaker-running"
          - name: AZURE_CLIENT_ID
            value: USER_ASSIGNED_CLIENT_ID
          volumeMounts:
          - name: input
            mountPath: "/mnt/input"
            readOnly: false
          - name: output
            mountPath: "/mnt/output"
            readOnly: false
        restartPolicy: Never
        volumes:
        - name: input
          persistentVolumeClaim:
            claimName: pvc-input
        - name: output
          persistentVolumeClaim:
              claimName: pvc-output
  pollingInterval: 10
  maxReplicaCount: 1
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 2
  triggers:
  - type: azure-servicebus  
    metadata:  
      queueName: delete # service bus queue
      queueLength: '1'
      namespace: SERVICEBUS_NAME # service bus namespace
    authenticationRef:
      name: azure-servicebus-auth
---
# servicebus-completed is triggered when a new blob is uploaded to the storage account
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: azure-blob-auth
  namespace: default
spec:
  podIdentity:
    provider: azure-workload
    identityId: AZURE_CLIENT_ID_VALUE
---
# completed
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: servicebus-completed
  namespace: default
spec:
  jobTargetRef:
    parallelism: 1
    completions: 1
    backoffLimit: 4
    template:
      metadata:
        labels:
          azure.workload.identity/use: "true"
      spec:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: agentpool
                      operator: In
                      values:
                        - system
        serviceAccount: sa-keda-sb-kubectl
        containers:
          - name: servicebus-completed
            image: ACR_NAME/misc/servicebus-complete:1.0
            imagePullPolicy: Always
            command: ["python3", "/usr/src/app/servicebus_complete.py"]
            env:
              - name: SERVICE_BUS_FQDN
                value: "SERVICEBUS_NAMEservicebus.windows.net"
              - name: SERVICE_BUS_QUEUE_RUNNING
                value: "stormbreaker-running"
              - name: AZURE_CLIENT_ID
                value: USER_ASSIGNED_CLIENT_ID
            volumeMounts:
              - name: output
                mountPath: "/mnt/output"
                readOnly: false
        restartPolicy: Never
        volumes:
          - name: output
            persistentVolumeClaim:
              claimName: pvc-output
  pollingInterval: 10
  maxReplicaCount: 1
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 2
  triggers:
    - type: azure-blob
      metadata:
        blobContainerName: output # blob container
        blobPrefix: run/completed # blob prefix
        blobCount: "1"
        accountName: STORAGE_ACCOUNT # storage account
      authenticationRef:
        name: azure-blob-auth