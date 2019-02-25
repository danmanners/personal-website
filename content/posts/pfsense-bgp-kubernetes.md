+++ 
draft = false
date = 2019-02-24T12:01:45-05:00
title = "pfSense, BGP, and MetalLB with Kubernetes"
slug = "" 
tags = ['bgp','pfsense','metallb','kubernetes']
categories = ["Networking","pfSense"]
+++

# Why (pfSense + BGP) + (Kubernetes + MetalLB)?

When you launch services in Kubernetes, you need a way to access them from outside the cluster. In a baremetal environment, <a href="https://metallb.universe.tf/">MetalLB</a> is essentially _the_ way to go if you need more than basic HTTP/HTTPS access. If you want to create externally accessible IP's outside of the subnet where the worker nodes exist, you'll need MetalLB's BGP functionality. 

# What does the full setup look like?

- 1 pfSense Router
- 3 Kubernetes Worker Nodes

# Other notes before jumping in

__Make sure that the ASN you use is inside the private range__. You can read  <a href="https://tools.ietf.org/html/rfc6996">RFC 6996</a> here. The key takeaway being you should only use ASN's in the contiguous range of 64512 to 65534, totalling 1023 available internal ASN's.

# Configuring pfSense OpenBGPD

The only pfSense requirements I'm aware of are:
1. OpenBGPD Package from `System > Package Manager` installed and configured.
2. A virtual IP Alias we'll use as the BGP listener
3. A network interface with the IP/Subnet range you're going to deploy services to.

Make sure you __DO NOT__ have the Quagga_OSPF or FRR packages installed. They directly conflict with one another. pfSense either won't let you or it'll break BGP entirely. Just don't do it.

For the OpenBGPD config, there are a couple of notes. While it has a nice UI to configure everything, don't use it. There are several open issues as of writing. Even though it is strictly advised against, do your setup in the `Raw config` tab in the OpenBGPD settings. It should look something like this:

```
# This file was created by the package manager. Do not edit!

AS 64512
fib-update yes
listen on 10.1.10.2
router-id 10.1.10.2
network 10.25.0.0/22

neighbor 10.1.10.51 { 
	remote-as 64513
    announce all
	descr "k8s-one" 
}

neighbor 10.1.10.52 { 
	remote-as 64513
    announce all
	descr "k8s-two" 
}

neighbor 10.1.10.53 { 
	remote-as 64513
    announce all
	descr "k8s-three" 
}
```

Breaking down the config, here's what it all means:

- `AS 64512` - This must be a private Autonomous System Number.
- `flb-update yes` - Forwarding Information Base, defaults to yes. Leave it.
- `listen on 10.1.10.2` - This is the address that OpenBGPD should listen to BGP requests on. I highly recommend setting this to the same as the `router-id` IP address.
- `router-id 10.1.10.2` - This should match the listen address above.
- `network 10.25.0.0/22` - This should be set to the range you'll be deploying services to.

The neighbor block should exist once for each worker node.

- `neighbor $(kubernetes_worker_node_ip)` - The neighbor IP address should be set for each of the kubernetes worker nodes.
- `remote-as 64513` - This is the private ASN that the workers will communicate as. For simplicity sake, let's 
- `announce all` - We need our nodes to be able to announce to the router their service IP addresses.
- `descr "value"` - Just a description field. Human readable easiness. 

Great! Let's continue.

# MetalLB Config Setup

For the MetalLB config, you'll need to launch it per the MetalLB installation guide.

For the configMap in Kubernetes, you'll want to build it similar to this.

```yaml
peers:
- peer-address: 10.1.10.2
  peer-asn: 64512
  my-asn: 64513
address-pools:
- name: default
  protocol: bgp 
  addresses:
  - 10.25.0.10-10.25.3.250
```

- The `peer-address` must match the above `router-id` from the OpenBGPD config.
- The `peer-asn` must match the value listed above `AS 64512`.
- `my-asn` must match the value you've set for the `remote-as` in the OpenBGPD config.

For this configMap, we're only going to create the `default` address pool. Build your `address-pools` section of the configMap but replac ethe addresses range with your appropriate range.

# Great, now what?

Now that we've got OpenBGPD on pfSense and configured, MetalLB on Kubernetes and the configMap placed in correctly, we're ready to launch a service using the load balancer!

# Running the first service

Let's create a manifest with a basic NGINX instance as well as a service that will serve the NGINX deployment!

We can run the following command to deploy everything:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-nginx
spec:
  selector:
    matchLabels:
      run: test-nginx
  replicas: 3
  template:
    metadata:
      labels:
        run: test-nginx
    spec:
      containers:
      - name: test-nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: test-nginx
  labels:
    run: test-nginx
spec:
  type: LoadBalancer
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: test-nginx
```

After a few moments, you can run this command to get the IP address:
```bash
➜ kubectl describe service test-nginx | grep "LoadBalancer Ingress"
LoadBalancer Ingress:     10.25.0.11
```

Great! The service looks like it's up! Let's see what navigating to the address yields.

![NGINX Test](/static/images/posts/pfsense-bgp-kubernetes.png)

# Congratulations! 

You now have pfSense running OpenBGPD, connected to your Kubernetes cluster using MetalLB to serve an IP address that's connected to a service linked to a deployment which communicates to a pod to serve you a connection!

If that isn't a mouthful I don't know what is.