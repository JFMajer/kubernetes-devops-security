#!/bin/bash

sed -i "s|{{image}}|${imageName}|g" k8s_deployment_service.yaml
kubectl -n default get deployment ${deploymentName} > /dev/null

kubectl -n default apply -f k8s_deployment_service.yaml