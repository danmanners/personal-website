+++
title = "Part 1: K3s, Zerotier, DigitalOcean, and more...Oh my!"
date = 2020-10-11T10:56:31-04:00
draft = false
slug = "k3s-digitalocean-zerotier-and-more"
tags = ['kubernetes','k3s','zerotier','digitalocean','homelab','gitops','GitHub','GitHub_actions','letsencrypt','turingpi']
categories = ['Networking','Kubernetes','Zerotier','GitOps','DigitalOcean']
+++

For a while, I've wanted to figure out some ways to bridge the gap with homelabbing and professional cloud environments. Generally it's expensive, complicated, or both to get it all working. What I'm hoping to help folks understand is that you can do it well, cheap, and keep it all maintained and up to date with modern practices like GitOps.

![Lens](/static/images/posts/k3s-do-zerotier-gitops/lens.png)

I am hopeful that I can build this as a living document, with more updates and content to be added as time progresses.

There's so much to cover here, so let's start with a brief overview of ALL of the different components in play here:


### Software

* [K3s](https://k3s.io/) - Lightweight Kubernetes, by [Rancher](https://rancher.com/)
* [Lens](https://k8slens.dev/) - The Kubernetes IDE for DevOps
* [Traefik](https://traefik.io/) - Cloud-Native Networking Stack
* [FluxCD](https://fluxcd.io/) - The GitOps operator for Kubernetes
* [GitHub](https://GitHub.com/) (specifically [GitHub Actions](https://GitHub.com/features/actions))
* [Docker BuildX](https://GitHub.com/docker/buildx) - Docker CLI plugin for extended build capabilities with BuildKit
* [Docker Hub](https://hub.docker.com/) - Docker's Container Repository
* [HypriotOS](https://blog.hypriot.com/downloads/) - container OS that takes you from Zero to Docker within 5 Minutes
* [Zerotier](https://www.zerotier.com/) - Virtual Ethernet switch for planet Earth
* [Ansible](https://www.ansible.com/) - Agentless IT Automation
* A domain name you own and can host with DigitalOcean

### Hardware (Physical & Virtual)

* [Turing Pi](https://turingpi.com/) - Raspberry Pi Compute Cluster Board
* [Raspberry Pi Compute Module 3+](https://www.raspberrypi.org/products/compute-module-3-plus/)
* [DigitalOcean](https://www.digitalocean.com/) - IMO, the homelab-friendly Cloud Provider

## What's the end goal here and _why_ would I even do this?

TL;DR - We'll have a combined architecture cluster (`arm/linux/7` and `amd64`) of k3s nodes that will host a website and will update itself according to the repos for your website and infrastructure.

We're going to be spinning up a cluster of Raspberry Pi's (`arm/linux/7` architecture), a single $5 Ubuntu VM (`amd64`architecture) in Digital Ocean, and a $10 Load Balancer<sup>1</sup>. The remote host in DO will dial home with ZeroTier, and we'll get a pipeline functional where your Kubernetes Manifests will be automatically applied to the cluster using (primarily) FluxCD.

-----

## Assumptions

This entire document is assuming that you are already familiar with the following things:

* DigitalOcean's Web Management UI
* Linux BASH/ZSH shell (Debian/Raspbian based distros preferred)
* Basic networking
  * Physical and Virtual Ethernet Interfaces
  * IP Addressing
  * Subnetting
* An existing system to flash your Raspberry Pi Compute Nodes
  * [BalenaEtcher](https://www.balena.io/etcher/) is the absolute correct tool to use for flashing your Pi nodes with the OS of your choosing.
* How to purchase a domain name and migrate it to DigitalOcean, [or follow this guide on how to do so](https://www.digitalocean.com/community/questions/how-to-transfer-domain-name-to-digitalocean).
* Basic knowledge of setting up a Github Account and creating repositories

-----

## Requirements

### Homelab

For hardware in my homelab, here's what I would recommend for Hardware and Networking:

1. One [Turing Pi](https://turingpi.com/)
    * Four (or more) [CM3+/8GB](https://www.digikey.com/en/products/detail/raspberry-pi/CM3-8GB/9866294) units;
    * My storage needs are limited, so the 8GB units are fine for me. [Jeff Gerrling did a fantastic YouTube video](https://youtu.be/IoMxpndlDWI?t=406) on how much faster eMMC storage is over MicroSD storage. I'd recommend going the eMMC route.
2. Zerotier Router VM (or an additional Pi that will not be on your K8s Cluster)
    * 2 vCPU
    * 4 GB Memory
    * 10GB Disk
3. Static Route on primary home/homelab router
    * Gateway should be set to `eth0` IP address on Zerotier Router VM
    * Destination Address should match the subnet of the configured Zerotier network

### DigitalOcean

For objects in DigitalOcean, I recommend creating the following:

1. One Basic $5/mo Droplet. This should be more than enough compute for what we're doing.
2. One Load Balancer
    * Ensure this is created in the same datacenter region, otherwise you **will not** be able to reference your Droplet.

## What's coming up

In part 2, I'll be covering:

* Building the Pi Cluster
  * Prepping the Pi's with HypriotOS
* Spinning up the Digital Ocean Droplet
* ZeroTier
  * Creating the ZeroTier Network
  * Associating the DO Node
  * Creating a ZeroTier 'Router' in the Homelab
  * Validating Network Connectivity between local Pi's and the DO Node

## References

<sup>1</sup> You don't _need_ the Load Balancer, but it'll ensure that if you want to add additional nodes in the cloud you can add them significantly more seamlessly.

## Helpful Links

* [K3s Homelab Repo for Flux](https://github.com/danmanners/homelab-k3s-cluster)
* [Personal Website Repo (with GitHub Actions)](https://github.com/danmanners/personal-website)
* [Docker Hub Account hosting container image](https://hub.docker.com/u/danielmanners)

# Questions? Thoughts?

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com"). If something I wrote isn't clear, feel free to ask me a question or tell me to update it!
