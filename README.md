## Setup Kubernetes on Virtual Machine

### I. Tools/Software Requirements
To run the labs you will need to have pre-installed on your computer the latest version of the following softwares:

- [Vagrant](www.vagrantup.com) by Hashicorp
- [Virtualbox](virtualbox.org) by Oracle

### II. Ideal Config/Setup
|Role|IP|OS|RAM|CPU|
|---|---|---|---|---|
|Master|10.0.0.10|Ubuntu 18.04/20.04|2GB|2|
|Worker-0|10.0.0.21|Ubuntu 18.04/20.04|1GB|1|
|Worker-1|10.0.0.22|Ubuntu 18.04/20.04|1GB|1|

You can modify the configuration (e.g. number of worker nodes, cpu count, memory, etc.) in the Vagrantfile. You may also change the image used. Search available [Vagrant Boxes](https://app.vagrantup.com/boxes/search) here.

### III. Install v1.18 stable release: (kubeadm, kubelet, kubectl)
These will be installed automatically in the master and worler nodes. If you wish to change/update the version, you can modify it directly in the script.

1. Kubernetes-Docker Setup
```bash
    kubeadm v1.18.5-00 
    kubelet v1.18.5-00 
    kubectl v1.18.5-00
```

1. Kubernetes-Containerd Setup
```bash
    kubeadm v1.20.0-00 
    kubelet v1.20.0-00 
    kubectl v1.20.0-00
```
### IV. Setup

1. Install [Vagrant](www.vagrantup.com) and [Virtualbox](virtualbox.org).
2. Update variables/config in the Vagrantfile.

```vagrant
    VAGRANT_BOX_IMAGE = "ubuntu/bionic64"
    MASTER_COUNT = 1
    WORKER_COUNT = 1
    POD_CIDR = "172.0.0.0/16"
    API_ADV_ADDRESS = "10.0.0.10"
    CLUSTER_NAME = "mycluster"
```

3. Run the command below:

```bash
    vagrant up 
```

4. Check the status using:

```bash
    vagrant status
```

5. Once the status is running, you can login to the master node to check the cluster.

```bash
    vagrant ssh mycluster-master-0  # login to master node via ssh
    kubectl cluster-info            # check cluster info
    kubectl get nodes               # check if your worker nodes are connected to the cluster
```

6. All done! You can now deploy to your kubernetes cluster.

```bash
    kubectl create deploy nginx --image nginx
    kubectl expose deploy nginx --port 80 --type NodePort
    kubectl get pods
```

7. Check these references for more cli commands: 
    a. [Vagrant Commands](https://www.vagrantup.com/docs/cli) 
    b. [Kubernetes Commands](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).


### V. References
1. Kuberverse: [arturscheiner/kuberverse](https://github.com/arturscheiner/kuberverse)
1. Just Me and Open-Source: [justmeandopensource/kubernetes](https://github.com/justmeandopensource/kubernetes/blob/master/docs/install-cluster-ubuntu-20.md)
