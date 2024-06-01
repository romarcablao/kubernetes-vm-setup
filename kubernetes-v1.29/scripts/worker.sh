#!/usr/bin/env bash

FLAG=$1
NODE=$2
NODE_HOST_IP=$((20 + NODE))
POD_CIDR=$3
API_ADV_ADDRESS=$4
BASE_ADDRESS=$5
CLUSTER_NAME=$6

echo "------------------------------------------------------------------------------"
echo " $FLAG"
echo " $FLAG ->> Joining Kubernetes Cluster"
echo " $FLAG ->> Worker Node $NODE: $CLUSTER_NAME-worker-$NODE"
echo " $FLAG"
echo "------------------------------------------------------------------------------"

$(cat /vagrant/kubeadm-init.out | grep -A 2 "kubeadm join" | sed -e 's/^[ \t]*//' | tr '\n' ' ' | sed -e 's/ \\ / /g')
echo KUBELET_EXTRA_ARGS=--node-ip=$BASE_ADDRESS.$NODE_HOST_IP > /etc/default/kubelet