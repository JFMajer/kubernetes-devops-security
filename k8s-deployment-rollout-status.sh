#!/bin/bash

sleep 60

echo ${deploymentName}

var=$(kubectl get pods)
echo $var

if [[ $(kubectl -n default rollout status deployment ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; then
    echo "Deployment ${deploymentName} has failed"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;
else
    echo "Deployment ${deploymentName} went ok"
fi