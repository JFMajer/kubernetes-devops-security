#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

trivy image --severity HIGH --exit-code 0  $dockerImageName
trivy image --severity CRITICAL --exit-code 1 $dockerImageName
trivy image $dockerImageName


exit_code=$?
echo "Exit code: $exit_code"

if [[ "${exit_code}" == 1 ]]; then
    echo "Vulnerabilities found."
    exit 1;
else
    echo "No vurnelabilities found"
fi;