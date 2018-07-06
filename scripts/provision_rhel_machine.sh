#!/bin/bash

set -x

yum install -y yum-utils device-mapper-persistent-data lvm2 git
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
mkdir -p /mnt/resource/docker /etc/docker
echo '{"data-root": "/mnt/resource/docker"}' > /etc/docker/daemon.json
systemctl start docker
cd /mnt/resource
docker pull osehra/osehravista
docker run -p 9430:9430 -p 8001:8001 -p9080:9080 -p2222:22 -p57772:57772 -p 61012:61012 -d -P --sysctl kernel.msgmax=1048700 --sysctl kernel.msgmnb=65536000 --name=cache osehra/osehravista