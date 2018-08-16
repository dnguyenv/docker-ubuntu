#!/bin/bash

set +e
: '
Hello world!
'

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

# Remove any old Docker setup
apt-get remove docker docker-engine docker.io -y

# Common Update
apt-get update -y

# Install the repository
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Add Docker GPG Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88
apt-key fingerprint 0EBFCD88

# Set up the stable repository
add-apt-repository \
   "deb [arch=ppc64el] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Common Update
apt-get update -y

# Install Docker
apt-get install docker-ce -y

# Run Hello World
docker run hello-world

# Enable Docker service
systemctl enable docker

# Enabling Docker Remote API on Ubuntu 16.04
sed -i -- 's/ExecStart=\/usr\/bin\/dockerd -H fd:\/\//ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ -H tcp:\/\/0.0.0.0:4243/g' /lib/systemd/system/docker.service
systemctl daemon-reload
service docker restart
curl http://localhost:4243/version