+++
draft = false
date = 2020-07-03T14:49:16-04:00
title = "Homelab Updates - Summer 2020"
slug = "homelab-update-summer-2020"
tags = ['homelab','proxmox','puppet','puppet-bolt','bolt','kubernetes','k8s']
categories = ['homelab','proxmox','puppet','bolt']
+++

# Homelab Updates - Summer 2020

In June of 2020, I decided to build a new homelab. The goals were simple: [open source all of the code](https://github.com/danmanners/homelab-deployment), [give back to the community](https://github.com/danmanners/proxmox_api), and make sure that as much as humanly possible was automated. Ultimately: Could I build a codebase which allowed someone who wasn't me to spin up a similar environment rapidly? Or, if my system burned to the ground, could I re-deploy everything within a reasonable timeframe with only the loss of persistent data?

## What happened to the old homelab environment

<center>
<img src="/static/images/posts/homelab-update-summer-2020/homelab-2018.jpg#center" width="60%">
</center>

Quick backstory: I sold my last full homelab around September 2019. There were several reason for that decision:

1. The cost of power and air conditioning began to outweigh the benefits of running it all, when I was simply not using it anywhere near its potential.
2. I was running the whole house network through it. Whenever something broke and I was not home, that meant my wife was without internet while running her business from home.
3. I no longer needed the lab environment I once did for personal learning, as the technology stack I was using on a daily basis was something I was familiar with and something that I could learn on during work hours.
4. I was not using it to learn anything new.

The combination of those reasons (and more) ultimately pushed me towards selling it and abandoning my previous homelab dreams. It was so much fun while it lasted, but it simply stopped making sense.

## Why the major change between the original homelab cluster and the new single-system setup?

There were a few major issues with the original homelab rack that I wanted to fix in version 2:

* It was physically enormous; an 18U 39"-deep rack takes up an extrodinary amount of floorspace.
* It generated a lot of heat; the combined 6 servers, storage array, switching, and dedicated router hardware simply used a lot of power and output tons of heat.
* It was expensive. Granted, I built it over about 3 years, it was between $5k-6k in hardware cost.
* It was unbelievably complicated. If it all burned down and I wanted to replace it, the time it would take to get everything back up would have been a few weekends worth of free time.

Those issues gave me three good goals for version 2:

* Shrink the footprint dramatically.
* Make it cool and quiet.
* Make it simple.

## What does the new homelab look like, and why now?

<center>
<img src="/static/images/posts/homelab-update-summer-2020/homelab-2020.jpg#center" width="70%">
</center>

I was able to re-purpose my Gaming PC and set it up as a [Proxmox 6.2](https://proxmox.com/en/) hypervisor. The hardware specs for the new homelab are:

```yaml
Motherboard: "Asus MAXIMUS VIII HERO"
Processor: "Intel i7-7700 (4c8t, 4.2GHz)"
RAM: "64GB (4x Corsair 16GB DDR4-2400), Non-ECC"
Storage:
    - Disk1: "256GB M.2 SSD Western Digital Blue"
      Alias: "hypervisor"
    - Disk2: "500GB M.2 SSD Crucial"
      Alias: "fivehundo"
    - Disk3: "1TB M.2 NVME Western Digital Blue"
      Alias: "nvmestor"
    - Disk4: "2TB SATA 7200rpm Seagate 3.5"
      Alias: "slowboat"
```

The reason I'm re-building the homelab anyway is becuase of my new role with Cisco as a DevOps Engineer. With all of the new tooling and logic that I'm working with at Cisco, I felt it was time again to build a homelab that would allow me to better learn and develop on the same or similar tooling as I work on with Cisco.

With that in mind, I have written my entire `homelab-deployment` project with [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt.html). While many people may have familiarity with Puppet, Bolt is more of an ad-hoc software piece and is effectively Puppets answer to Ansible. While I had built thousands of lines of Ansible in the past, I had not messed around with Puppet too much.

### Why Puppet Bolt?

Puppet Bolt is what I have been writing much of my Cisco code for, and in order to have a better understanding of it, I figured what better way than to deploy my entire homelab with it? One caveat that I found is that while learning Puppet/Puppet Bolt, much of the documentation is more reference material rather than examples. Because so much Puppet and Bolt code is normally incredibly environment specific, it doesn't appear that many people have released a lot of perfectly functional code as example code. Since I had such a frustrating time picking it up with the speed necessary to my job, I figured I would aim to 100% publicly release my source code for my entire Homelab.

## What can it do?

Currently, it runs the following applications:

- Traditional VM:
  - Router (NGINX/iptables/BIRD)
  - Gitlab: [https://gitlab.goodmannershosting.com]
  - Pi-Hole
  - NFS Server (For Kubernetes)
  - Kubernetes (1 Primary, 3 Nodes)
- Kubernetes Applications
  - Nexus OSS: [https://nexus.goodmannershosting.com]
  - Jenkins: [https://jenkins.goodmannershosting.com]
  - SonarQube: [https://sonarqube.goodmannershosting.com]
  - PostgreSQL

## How do you deploy it all?

I have most of a live document [up on the Github project for homelab-deployment](https://github.com/danmanners/homelab-deployment), but here's a TL;DR of that document:

01. Install the Hypervisor on your hardware.
02. Configure a GenericCloud VM Template (More on that below)
03. Install Puppet Bolt on your development machine.
04. Run the following Bolt Plans, in this order:
    01. `deploy_applications::qemu_guest_agent`
    02. `deploy_applications::docker_install`
    03. `deploy_router::router_config`
    04. `deploy_router::bird`
    05. `deploy_applications::pi_hole`
    06. `deploy_applications::gitlab_ce`
    07. `deploy_applications::gitlab_runner`
    08. `deploy_nfs::provision_disk`
    09. `deploy_nfs::setup`
    10. `deploy_nfs::add_dir newdir=nvemestor mount=jenkins`
    11. `deploy_nfs::add_dir newdir=nvemestor mount=nexus`
    12. `deploy_nfs::add_dir newdir=nvemestor mount=sonarqube`
    13. `deploy_nfs::add_dir newdir=nvemestor mount=postgres`
    14. `deploy_k8s::init_master`
    15. `deploy_k8s::init_workers`
    16. `deploy_router::google_dyndns`
    17. `deploy_router::nginx`
05. Once the Kubernetes Cluster is up and going, you can run the following `kubectl` commands to spin up all of the applications:
    01. `kubectl apply -f kubernetes/manifests/metallb/metallb-config.yaml`
    02. `kubectl apply -f kubernetes/manifests/postgres/postgres-secret.yaml`
    03. `kubectl apply -f kubernetes/manifests/postgres/postgres.yaml`
    04. `kubectl apply -f kubernetes/manifests/nexus.yaml`
    05. `kubectl apply -f kubernetes/manifests/jenkins-ce`
06. Go ahead and [configure Nexus OSS](https://nexus.goodmannershosting.com).
07. Create the Docker Registry, a user account, and an associated role.
08. Build, tag, login and push up the postgres management container to Nexus. This will also serve as validation testing.
    01. `docker build -t manage_psql Boltdir/site-modules/manage_psql/files/create`
    02. `docker tag manage_psql nexus.goodmannershosting.com:5001/repository/homelab/manage_psql`
    03. `docker login nexus.goodmannershosting.com:5001`
    04. `docker push nexus.goodmannershosting.com:5001/repository/homelab/manage_psql`
09. Once you have validated the authentication above, update the proper file ([k8s-nexus-auth.yaml](kubernetes/manifests/k8s-nexus-auth.yaml)), and push it to Kubernetes.
    01. `kubectl apply -f kubernetes/manifests/k8s-nexus-auth.yaml`
10. If everything else has succeeded, you will be able to also push up and successfully launch Sonarqube.
    01. `kubectl apply -f kubernetes/manifests/sonarqube/sonar-postgres-add.yaml`
    02. `kubectl apply -f kubernetes/manifests/sonarqube/sonarqube.yaml`

## Configuring Generic Cloud Images

Since there didn't appear to be anything like it, and I figured it'd be a good learning experience, I [built a puppet module to control Proxmox](https://github.com/danmanners/proxmox_api). While this is still very much a work-in-progress, it allows two major functions to be automated that can otherwise be pretty annoying:

1. Simply creates VM Templates based on Generic Cloud Images (tested with Ubuntu and CentOS)
2. Simply clone template VM's and assign the correct values for hardware specifications and network settings using Cloud-Init.

## What now?

There's still a lot to do, and I'm sure that good chunks of the above can be automated. The goals of this project are really to better understand and learn Puppet Bolt while also providing the community a better place to start learning.