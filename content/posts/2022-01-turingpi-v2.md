+++ 
draft = false
date = 2022-01-27T18:03:54-05:00
title = "The TuringPi v2 - A New Generation of Power-Efficient Cluster Computing"
slug = "2022-01-turingpi-v2"
tags = ['turingpi','raspberrypi','on-prem','cloud','compute','turingpi']
categories = ['Kubernetes','Raspberry Pi','Turing Pi','Networking']
+++

## Turing Pi 2

I'm unfortunately not the first person to come out with a review of the [Turing Pi 2](https://turingpi.com/); not even the second or third! [Jeff Geerling](https://www.youtube.com/c/JeffGeerling), [Techno Tim](https://www.youtube.com/channel/UCOk-gHyjcWZNj3Br4oxwh0A), and [LearnLinuxTV](https://www.youtube.com/channel/UCxQKHvKbmSzGMvUrVtJYnUA) on YouTube have all gotten their hands on the board as well, and they've done individually fantastic dives into the hardware, what it can do (and what it can't), and even some comparisons with other hardware in Jeff's video ([16:40](https://youtu.be/IUPYpZBfsMU?t=1000)).

So while I want to touch on the hardware, I don't want to dive into everything that the other reviewers have already covered. I'd like to help you understand, from my perspective, _why_ the Turing Pi 2 might be one of the most exciting pieces of technology in the past few years, and why it might be my favorite piece of technology in 2022.

<center>
    <img src="static/images/posts/turingpi2/02-turingpi2.jpg" width="70%" alt="Turing Pi 2" style="margin: 20px 0px; border-radius: 20px;">
</center>

## What is the Turing Pi 2?

The Turing Pi 2 is a Mini-ITX system board which allows up to **four** compute modules to be connected. Today, the [Raspberry Pi Compute Module 4](https://www.raspberrypi.com/products/compute-module-4/) and three [NVIDIA Jetson CoM (Computer-on-Module) units](https://www.nvidia.com/en-us/autonomous-machines/jetson-store/) can be connected to the board. In the future, other compute modules may be compatible, but that future isn't quite today. The board has several items that are tied to all nodes (RTC, Ethernet), and other connectors and components which are tied to specific node slots.

> To utilize the board to it's fullest potential, you will want to fully populate all four node slots!

| Slot 1                                     | Slot 2    | Slot 3                  | Slot 4                                                                 |
|:-------------------------------------------|:----------|:------------------------|:-----------------------------------------------------------------------|
| mini-PCIe</br>SIM-card slot<br>GPIO 40-pin | mini-PCIe | 2x SATA III</br>(6Gbps) | 4x USB 3.0 Ports</br>- 2x on Rear IO</br>- 2x on Front-Panel Connector |

<center>
    <img src="static/images/posts/turingpi2/03-turingpi2-ports.png" alt="Turing Pi 2" style="margin: 20px 0px">
</center>

The Turing Pi 2 has dual-Gigabit Ethernet NICs, and a Realtek switch chip which supports Layer 2+ capabilities<sup>1</sup> as well as LACP<sup>2</sup>. With gigabit speeds on the NIC as well as to each compute module, each node will be able to utilize full gigabit speed, which is a major improvement from the Turing Pi 1 and the Compute Module 3/3+, which was limited to 10/100Mbps full-duplex network speeds.

The board has an IP-enabled baseboard management controller<sup>3</sup>, similar to any enterprise-grade out-of-band management software. This will allow users to manage the network settings, manage power per-node, access serial connections, and flash nodes.

> <sup>1/2</sup>: While the pre-production unit does not have this functionality enabled, it is actively being worked on and will hopefully ship with that functionality enabled.
>
> <sup>3</sup>: The baseboard management controller is still a Work-in-Progress on the pre-production unit, but is actively in development and should ship with the functionality and features listed above.

## Why does the Turing Pi 2 matter?

While the Turing Pi 1 could run seven Raspberry Pi Compute Module 3+ units compared to the Turing Pi 2's four nodes, the limitation of 1 GiB of memory and the slightly slower CPU felt like more of a proof-of-concept compared to a real product. That's not a knock against the Turing Pi 1 either; it's absolutely a knock against the Compute Module 3+ and the limited memory and compute per-SOC module.

The Turing Pi 2 is perhaps the first compute module cluster board that can support truly powerful compute nodes. With a minimal power draw (under 60W under load) and small physical footprint, you can fit a total of 16 CPU Cores and 32 GiB of memory into a Mini-ITX form factor system. For the first time, you can _truly_ build a cluster-in-a-box with nothing more than an ethernet cable and a single power cord. Additionally, as `arm64`/`aarch64` continues to push it's way into mainstream systems, this cluster board makes it easy to add into any new or existing environment.

As someone [who absolutely believes in the future of the ARM64 ISA](https://jumpcloud.com/blog/why-should-you-use-arm64), this cluster board checks nearly every box I've wanted for _years_. Even Apple is migrating to their custom M1 architecture, which is based on the ARM instruction set architecture (ISA)! With Raspberry Pi CM4 units and this board in conjunction with existing Intel or AMD-based systems (`amd64` architecture), you can easily _natively_ build multi-architecture containers, or run just about anything you could ever want between the two sets of systems.

## So...why should I care?

The Turing Pi 2 matters because it's the first _tangible proof_ that ARM64 is not just for Apple or the enterprise (see: [AWS Graviton](https://aws.amazon.com/ec2/graviton/)); ARM64 ISA's have a real place in the homelab outside of individual Raspberry Pi nodes, and a real place in small and large businesses looking for easy clustering (see: [Chick-Fil-A Edge Computing](https://medium.com/@cfatechblog/bare-metal-k8s-clustering-at-chick-fil-a-scale-7b0607bd3541)).

Another major benefit of the Turing Pi 2 is that it is absolutely built for hybrid-cloud workloads right out of the box! I've been hosting services on the Turing Pi 2 from my homelab with [Rancher K3s](https://k3s.io/) quite successfully for several weeks as of writing this. Some of the services that have been running are:

- [Excalidraw](https://github.com/excalidraw/excalidraw)
- [Tekton CI/CD](https://tekton.dev/)
- [Cert-Manager](https://cert-manager.io/docs/)
- [Grafana](https://grafana.com/)
- [Node-Feature-Discover](https://github.com/kubernetes-sigs/node-feature-discovery)
- [Open Policy Agent](https://www.openpolicyagent.org/)
- [GitHub Action Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners)
- [Rancher System Upgrade Controller](https://github.com/rancher/system-upgrade-controller)

Internally, my network is _reasonably_ normal. However, I host several of these services directly on the internet. At a high level, this is what my external network setup looks like:

<center>
    <img src="static/images/posts/turingpi2/04-turingpi2.png" alt="Turing Pi 2" style="margin: 10px 0px">
</center>

While the networking looks a little odd (and is worthy of another discussion entirely), here's what matters:

```bash
➜  time curl https://whiteboard.danmanners.com -sI
HTTP/2 200
accept-ranges: bytes
content-type: text/html
date: Fri, 28 Jan 2022 04:26:17 GMT
etag: "61da4226-1d7b"
last-modified: Sun, 09 Jan 2022 02:02:14 GMT
server: nginx/1.21.5
content-length: 7547

curl https://whiteboard.danmanners.com -sI 0.02s user 0.02s system 10% cpu 0.304 total
```

The Turing Pi 2 nodes are the _only_ nodes in my homelab running the Excalidraw (`whiteboard.danmanners.com`) software, and over the internet the latency is as low as around 20ms. That's _kind of awesome_. Even with a reasonably complex network architecture and many hops, there does not appear to be any noticeable latency when accessing the services hosted on the Turing Pi 2 compute nodes. The nodes are snappy, responsive, and meet my needs perfectly.

<center>
    <img src="static/images/posts/turingpi2/05-turingpi2.jpg" width="70%" alt="Turing Pi 2" style="margin: 20px 0px; border-radius: 20px;">
</center>

I've even gone through and evaluated an [NGFF (mini-PCIe) to NVMe Adapter with a Samsung 980 NVMe SSD](https://pipci.jeffgeerling.com/cards_m2/sintech-mpcie-m2-adapter.html), and while performance is not spectacular, it's not bad at all! More than fast enough to act as temporary storage while building `arm64` containers before shuffling them off to remote container registries!

## What's next?

The Turing Pi 2 team will be launching their Kickstarter in the near future, and I cannot wait to purchase a second unit. While I truly believe that the Turing Pi 1 was more of a niche product, pending the availability of Raspberry Pi Compute Module 4 units during the [global everything shortage](https://www.raspberrypi.com/news/supply-chain-shortages-and-our-first-ever-price-increase/), I think that the Turing Pi 2 could be an absolute home-run of a product for tech enthusiasts, anyone learning about Kubernetes, anyone with an interest in ARM64-based systems, and anyone wanting a low-power and efficient learning environment. Once this becomes available, I'm unsure there's going to be much else I'll be able to recommend that can offer so much bang-for-your-buck.

## Final Notes & Disclosures

Turing Pi **did not** financially compensate me for this post; this is 100% because I love this board and what I think it means for the future of low-power cluster computing. They did however send the pre-production board shown at no cost to me.

If you're looking to join the Official Turing Pi Discord Server, click the Discord Logo below!

<center><a href="https://discord.com/invite/uNbysyc">
    <img src="static/images/posts/turingpi2/Discord-Logo-Color.png" width="10%">
</a></center>

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or ask me to update it!
