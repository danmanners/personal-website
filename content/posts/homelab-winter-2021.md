+++ 
draft = false
date = 2021-02-20T16:30:00-05:00
title = "Homelab Updates - Winter 2021"
slug = "homelab-update-winter-2021" 
tags = ['turingpi','homelab','qnap','virtualization','mikrotik','poe','san','ubiquiti','ubnt']
categories = ['Homelab']
+++

# Homelab Updates - Winter 2021

Since my last homelab post, I've added _quite_ a few components back into the lab mix.

<center>
<img src="/static/images/posts/homelab-update-winter-2021/homelab-diagram.png#center" width="100%">
</center>

## Lab Hardware

The diagram's a lot, so here's a high-level hardware breakdown:

```yaml
---
switches:
  - name: "Core Lab Switch"
    part_id: "Ubiquiti EdgeSwitch 24 Lite"
    ports:
      1gbps: 24
      1gbps_sfp: 2
      10gbps_sfp: 0
  - name: "Lab PoE Switch"
    part_id: "Ubiquiti EdgeSwitch 8 150W"
    ports:
      1gbps: 8
      1gbps_sfp: 2
  - name: "SAN Network Switch"
    part_id: "Mikrotik CRS305-1G-4S+IN"
    ports:
      1gbps_copper: 1
      1gbps: 4
---
hypervisors:
  - name: "Proxmox"
    proc: "Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz"
    memory: "64GB"
  - name: "Proxmox2"
    proc: "AMD Ryzen 5 3400G with Radeon Vega Graphics"
    memory: "32GB"
  - name: "Proxmox3"
    proc: "Intel(R) Celeron(R) J4105 CPU @ 1.50GHz"
    memory: "16GB"
---
arm_clusterboards:
  - name: "Turing Pi v1 - 1"
    nodes: 7
  - name: "Turing Pi v1 - 2"
    nodes: 3
---
storage:
  - model: "QNAP TS-332X"
    disks:
      - type: "Seagate 4TB"
        count: 3
      - type: "Crucial 500GB M.2"
        count: 3
```

There's a lot of new hardware here compared to the one Hypervisor with local storage I was running during summer 2020.

## What am I doing with it all

With the standard virtualization, I've been primarily using it to run various Kubernetes clusters. Between clusters launched with `kubeadm`, `rke`, and `k3s`, it's been an excellent learning lab environment. Additionally, I'm hosting virtual machines for a Zerotier router, Unifi Controller, and PiHole.

The [QNAP TS-332X](https://www.qnap.com/en-us/product/ts-332x) has proven itself as a surprisingly great little NAS, and the SFP+ connectivity with two of the big hypervisors has been fantastic. I can max out network speeds at nearly 4Gbps, or just about 500MBps read/write on the SSDs, or about 2Gbps read/write on the spinning drives at nearly 250MBps. Initially, I was incredibly skeptical of how its performance might look with a smaller ARM processor, but I've been quite impressed with the [Anapura Labs Alpine AL324](https://en.wikipedia.org/wiki/Annapurna_Labs#AL324) processor in it. 

With the Turing Pi cluster boards, I'm actually hosting [this website](https://danmanners.com) on [k3s](https://k3s.io/). It's been an absolutely awesome little board. I was happy enough with it to buy a second on when they announced the second batch, and I'm actively working on ways to use it with k3s in more edge-compute scenarios. Honestly, it's one of the more impressive boards I've seen in a long time, and I'm excited to pick up the [next version](https://turingpi.com/v2/) when it's available.

## What else is different?

- I've physically re-arranged everything in my office to live on a racking system rather than in a proper server rack.
- I added a second [UPS](https://www.amazon.com/gp/product/B000FBK3QK) and a [CyberPower ATS PDU](https://www.amazon.com/gp/product/B00NEHUX08). Absolutely fantastic decision.
- Moving from a single node to a cluster of nodes for virtualization made me remember how nice is is to be able to keep uptime.
- Most of my recent Kubernetes deployments have been with `rke` rather than `kubeadm`, and it's dramatically changed how quickly major cluster changes can be made.

## What's next?

I'm hoping to have some time in the near future to put together some articles on some of the newer platforms I've been playing with; [Rancher `rke`](https://rancher.com/docs/rke/latest/en/), [Terraform](https://www.terraform.io/), and [Longhorn](https://longhorn.io/) are on the short list.
