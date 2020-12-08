#!/usr/bin/env bash

FLAG=$1

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Adding Kubernetes and Docker-CE Repo"
echo " $FLAG"
echo "------------------------------------------------------------------------------"

### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common 

### Add Kubernetes GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

### Kubernetes Repo
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

### Add Docker apt repository.
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Updating Repositories"
echo " $FLAG"
echo "------------------------------------------------------------------------------"
apt-get update

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Installing Misc/Recommended Packages"
echo " $FLAG"
echo "------------------------------------------------------------------------------"
apt-get install -y avahi-daemon libnss-mdns traceroute htop httpie bash-completion 

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Installing Docker and Kubernetes"
echo " $FLAG"
echo "------------------------------------------------------------------------------"
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00

# Setup Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker
systemctl daemon-reload
systemctl restart docker