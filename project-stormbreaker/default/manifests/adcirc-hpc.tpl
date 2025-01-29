adcirc-hpc.tpl
root@podman-in-a-pod:/mnt/input/templates# cat adcirc-hpc.tpl 
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-adcirc-$JOB_NAME
data:
  entrypoint.sh: |-
    #!/usr/bin/bash -l
    mkdir -p /var/run/sshd; /usr/sbin/sshd
    TEST_DIR=/mnt/input/simulations/adcirc/$JOB_SIMULATION
    LD_LIBRARY_PATH="/home/stormbreaker/install/lib"
    WORKDIR=/mnt/scratchpad/$JOB_CUSTOMER/$JOB_SIMULATION/$JOB_NAME/
    SLOTS=$JOB_SLOTS # pe:4 * 16 (16 cores)
    NP=$JOB_NP       # SLOTS * Number of VMs
      
    mkdir -p $WORKDIR
    cd $WORKDIR
    cp -r $TEST_DIR/* $WORKDIR

    adcprep --np $(($NP-10)) --partmesh | tee adcprep.txt # for a better performance, redirect to a file instead of using tee
    adcprep --np $(($NP-10)) --prepall  | tee adcprep.txt
    mpiexec -x LD_LIBRARY_PATH --allow-run-as-root -np $NP -npernode $SLOTS --mca plm_rsh_args "-p 2222" --map-by core -hostfile /etc/volcano/mpiworker.host -x UCX_NET_DEVICES=mlx5_0:1 -mca ucx ^vader,tcp,openib,uct -x UCX_TLS=rc padcirc -W 10 | tee padcirc.log

    cp -r /mnt/scratchpad/$JOB_CUSTOMER/$JOB_SIMULATION/$JOB_NAME /mnt/output/run/$JOB_CUSTOMER/$JOB_SIMULATION/
    touch /mnt/output/run/completed/$JOB_NAME
    # MPI job exit status
    exit $?
---
# ADCIRC compiled with OpenMPI
# models are accessible on a NFS share
apiVersion: batch.volcano.sh/v1alpha1
kind: Job
metadata:
  name: job-$JOB_NAME
spec:
  minAvailable: 3
  schedulerName: volcano
  priorityClassName: high-priority
  plugins:
    ssh: []
    svc: []
    env: []
  queue: adcirc
  tasks:
    - replicas: 1
      name: mpimaster
      policies:
        - event: TaskCompleted
          action: CompleteJob
      template:
        spec:
          hostNetwork: true
          dnsPolicy: ClusterFirstWithHostNet
          affinity:
            podAffinity:  
              requiredDuringSchedulingIgnoredDuringExecution:  
              - labelSelector:  
                  matchExpressions:  
                  - key: role  
                    operator: In  
                    values:  
                    - nfs-server  
                topologyKey: "kubernetes.io/hostname"
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: agentpool
                    operator: In
                    values:
                    - adcirchpc
          initContainers:
            - command:
                - /bin/bash
                - -c
                - |
                  until [[ "$(kubectl get pod -l volcano.sh/job-name=job-$JOB_NAME,volcano.sh/task-spec=mpiworker -o json | jq '.items | length')" != 0 ]]; do
                    echo "Waiting for MPI worker pods..."
                    sleep 3
                  done
                  echo "Waiting for MPI worker pods to be ready..."
                  kubectl wait pod -l volcano.sh/job-name=job-$JOB_NAME,volcano.sh/task-spec=mpiworker --for=condition=Ready --timeout=600s
              image: mcr.microsoft.com/oss/kubernetes/kubectl:v1.26.3
              name: wait-for-workers
          serviceAccount: sa-mpi-worker-view
          containers:
            - name: mpimaster
              image: stormbreakeracrdc.azurecr.io/adcirc-hpc:55.02-rc-3.1
              env: 
              - name: LD_LIBRARY_PATH
                value: /home/stormbreaker/install/lib
              securityContext:
                capabilities:
                  add: ["IPC_LOCK"]
                privileged: true
              command: ["/bin/entrypoint.sh"]
              volumeMounts:
              - name: input
                mountPath: "/mnt/input"
                readOnly: false
              - name: output
                mountPath: "/mnt/output"
                readOnly: false
              - name: scratchpad
                mountPath: "/mnt/scratchpad"
              - name: adcirc-config
                mountPath: /bin/entrypoint.sh
                readOnly: true
                subPath: entrypoint.sh
              ports:
                - containerPort: 2223
                  name: mpijob-port
              workingDir: /root
              lifecycle: # copy all of the files from the scratchpad to Blob
                preStop:
                  exec:  
                    command: 
                    - "/bin/sh"
                    - "-c"
                    - |
                      cp -r /mnt/scratchpad/$JOB_CUSTOMER/$JOB_SIMULATION/$JOB_NAME /mnt/output/run/$JOB_CUSTOMER/$JOB_SIMULATION/  &&
                      touch /mnt/output/run/completed/$JOB_NAME
          volumes:
          - name: input
            persistentVolumeClaim:
              claimName: pvc-input
          - name: output
            persistentVolumeClaim:
              claimName: pvc-output
          - name: scratchpad
            persistentVolumeClaim:
              claimName: scratchpad
          - name: adcirc-config
            configMap:
              defaultMode: 0700
              name: cm-adcirc-$JOB_NAME 
          restartPolicy: Never
    - replicas: 3
      name: mpiworker
      template:
        spec:
          hostNetwork: true
          dnsPolicy: ClusterFirstWithHostNet
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: agentpool
                    operator: In
                    values:
                    - adcirchpc
          containers:
            - name: mpiworker
              image: stormbreakeracrdc.azurecr.io/adcirc-hpc:55.02-rc-3.1
              env: 
              - name: LD_LIBRARY_PATH
                value: /home/stormbreaker/install/lib
              securityContext:
                capabilities:
                  add: ["IPC_LOCK"]
                privileged: true
              resources:
                requests:
                  nvidia.com/mlnxnics: 1
                limits:
                  nvidia.com/mlnxnics: 1
              command:
              - /bin/sh
              - -c
              - |
                mkdir -p /var/run/sshd; /usr/sbin/sshd -D -p 2222;
              volumeMounts:
              - name: input
                mountPath: "/mnt/input"
                readOnly: false
              - name: output
                mountPath: "/mnt/output"
                readOnly: false
              - name: scratchpad
                mountPath: "/mnt/scratchpad"
              ports:
                - containerPort: 2222
                  name: mpijob-port
              workingDir: /root
          restartPolicy: OnFailure
          terminationGracePeriodSeconds: 0
          volumes:
          - name: input
            persistentVolumeClaim:
              claimName: pvc-input
          - name: output
            persistentVolumeClaim:
              claimName: pvc-output
          - name: scratchpad
            persistentVolumeClaim: 
              claimName: scratchpad