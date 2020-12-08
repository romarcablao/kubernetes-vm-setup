#!/usr/bin/env bash

FLAG=$1
NODE=$2
POD_CIDR=$3
API_ADV_ADDRESS=$4
BASE_ADDRESS=$5
CLUSTER_NAME=$6

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Initializing Kubernetes Cluster"
echo " $FLAG ->> Master Node $NODE: $CLUSTER_NAME-master-$NODE"
echo " $FLAG"
echo "------------------------------------------------------------------------------"
kubeadm init --pod-network-cidr $POD_CIDR --apiserver-advertise-address $API_ADV_ADDRESS --ignore-preflight-errors=all | tee /vagrant/kubeadm-init.out

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Configuring Kubernetes Cluster Environment"
echo " $FLAG"
echo "------------------------------------------------------------------------------"
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Configuring Kubernetes Cluster Calico Networking"
echo " $FLAG ->> Downloading Calico YAML File"
echo " $FLAG"
echo "------------------------------------------------------------------------------"
wget -q https://docs.projectcalico.org/v3.14/manifests/calico.yaml -O /tmp/calico-default.yaml
sed "s+192.168.0.0/16+$POD_CIDR+g" /tmp/calico-default.yaml > /tmp/calico-defined.yaml

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Applying Calico YAML File"
echo " $FLAG"
echo "------------------------------------------------------------------------------"
kubectl apply -f /tmp/calico-defined.yaml
rm /tmp/calico-default.yaml /tmp/calico-defined.yaml
echo KUBELET_EXTRA_ARGS=--node-ip=$BASE_ADDRESS.1$NODE > /etc/default/kubelet