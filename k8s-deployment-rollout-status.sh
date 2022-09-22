#!/bin/bash

sleep 15

if [[ $(kubectl -n default rollout status deploy ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; then
    echo "Deployment ${deploymentName has failed}"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;
else
    echo "Deployment ${deploymentName} went ok"
fi