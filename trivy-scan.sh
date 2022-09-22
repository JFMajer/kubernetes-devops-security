#!/bin/bash

dockerImageName=$(aws 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v docker run --rm -v $HOME/Library/Caches:/root/.cache aquasec/trivy -q image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v docker run --rm -v $HOME/Library/Caches:/root/.cache aquasec/trivy -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

exit_code=$?
echo "Exit code: $exit_code"

if [[ "${exit_code}" == 1 ]]; then
    echo "Vulnerabilities found."
    exit 1;
else
    echo "No vurnelabilities found"
fi;