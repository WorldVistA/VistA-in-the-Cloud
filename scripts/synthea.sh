#!/bin/bash

# Until Synthea is public you will need to extract the manager zip to ./manager and service zip to ./service
# If you want to test locally add true as your second argument

ip=$1
local=$2
if [[ -z $local ]]; then
    local=false
fi

if [[ -z $ip ]]; then
    echo "You need to supply and IP (or localhost) as the first argument"
    exit 1
fi

# Uncomment and replace the git url's once Synthea is public
# git clone <service git url> service
# git clone <manager git url> manager

if [[ ! -d ./manager ]]; then
    echo "Synthea Manager not found, please extract or git clone into ./manager"
    exit 1
fi

if [[ ! -d ./service ]]; then
    echo "Synthea Service not found, please extract or git clone into ./service"
    exit 1
fi

if [[ !$local ]]; then
    mkdir -p /opt/synthea/dhp-synthea-service
    mkdir -p /opt/synthea/manager
    mkdir -p /opt/synthea/output/fhir
fi

cp -r ./service/ /opt/synthea/dhp-synthea-service/
cp -r ./manager/ /opt/synthea/manager/
cp -r ./manager/ /opt/synthea/manager/static

cp ./docker/service/Dockerfile /opt/synthea/
pushd /opt/synthea/dhp-synthea-service
perl -pi -e "s/https:\/\/vista-synthetic-data-dev1.openplatform.healthcare\/addpatient/http:\/\/$ip:9080\/addpatient/" ./src/main/resources/application-dev.properties
perl -pi -e "s/https:\/\/synthea-manager-dev1.openplatform.healthcare,http:\/\/localhost:8080/http:\/\/$ip:8020/" ./src/main/resources/application-dev.properties
popd
pushd /opt/synthea
docker build -t synthea-service-builder .
docker run -v $(pwd)/dhp-synthea-service:/opt/synthea/dhp-synthea-service --name synthea-service-builder synthea-service-builder
docker rm synthea-service-builder && docker rmi synthea-service-builder && docker rmi openjdk:8-jdk
popd
pushd /opt/synthea/dhp-synthea-service
./deploy.sh dev
popd
cp ./docker/manager/Dockerfile /opt/synthea/
pushd /opt/synthea/manager
chmod +x build.sh compile.sh create-container.sh deploy.sh docker-env.sh
perl -pi -e "s/https:\/\/synthea-service-dev1.openplatform.healthcare\//http:\/\/$ip:8021\//" ./config/devdeploy.env.js
popd
pushd /opt/synthea
docker build -t synthea-manager-builder .
docker run -v $(pwd)/manager:/opt/synthea/manager --name synthea-manager-builder synthea-manager-builder
docker rm synthea-manager-builder && docker rmi synthea-manager-builder && docker rmi node:6.14
popd
pushd /opt/synthea/manager
./deploy.sh devdeploy
popd