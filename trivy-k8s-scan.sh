#!/bin/bash

echo $imageName

trivy image --severity HIGH --exit-code 0  $imageName
trivy image --severity CRITICAL --exit-code 1 $imageName
trivy image $imageName


exit_code=$?
echo "Exit code: $exit_code"

if [[ "${exit_code}" == 1 ]]; then
    echo "Vulnerabilities found."
    exit 1;
else
    echo "No vurnelabilities found"
fi;