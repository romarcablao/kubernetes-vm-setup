#!/usr/bin/env bash

FLAG=$1

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Initialize Kubernetes and Containerd Repo"
echo " $FLAG"
echo "------------------------------------------------------------------------------"

### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common 

### Add Kubernetes GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

### Kubernetes Repo
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

### Enable and Load Kernel modules
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Add Kernel Settings
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

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
echo " $FLAG ->> Installing Containerd and Kubernetes"
echo " $FLAG"
echo "------------------------------------------------------------------------------"
apt-get update -qq >/dev/null 2>&1
apt-get install -qq -y containerd apt-transport-https >/dev/null 2>&1
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1

apt-get install -y kubeadm=1.20.0-00 kubelet=1.20.0-00 kubectl=1.20.0-00

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