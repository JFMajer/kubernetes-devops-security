#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v docker run --rm -v aquasec/trivy:0.32.0 -q image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v docker run --rm -v aquasec/trivy:0.32.0 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

exit_code=$?
echo "Exit code: $exit_code"

if [[ "${exit_code}" == 1 ]]; then
    echo "Vulnerabilities found."
    exit 1;
else
    echo "No vurnelabilities found"
fi;