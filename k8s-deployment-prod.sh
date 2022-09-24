#!/bin/bash

sed -i "s|{{image}}|${imageName}|g" k8s_deployment_service.yaml
kubectl -n prod get deployment ${deploymentName} > /dev/null

kubectl -n prod apply -f k8s_deployment_service.yaml --record