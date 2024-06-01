#!/usr/bin/env bash

FLAG=$1
KUBERNETES_VERSION="1.30.1-*"

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Initialize Kubernetes and Containerd Repo"
echo " $FLAG"
echo "------------------------------------------------------------------------------"

### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y gnupg2 apt-transport-https ca-certificates curl software-properties-common

### Kubernetes Repo
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

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

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Apply sysctl params without reboot
sudo sysctl --system

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
apt-get install -y containerd
apt-get install -y kubeadm="$KUBERNETES_VERSION" kubelet="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION"
sudo apt-mark hold kubelet kubeadm kubectl

mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

systemctl restart containerd 
systemctl enable containerd
