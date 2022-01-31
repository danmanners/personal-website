+++ 
draft = false
date = 2022-01-27T18:03:54-05:00
title = "The TuringPi v2 - A New Generation of Power-Efficient Cluster Computing"
slug = "2022-01-turingpi-v2"
tags = ['turingpi','raspberrypi','on-prem','cloud','compute','turingpi']
categories = ['Kubernetes','Raspberry Pi','Turing Pi','Networking']
+++

<meta property="og:title" content="The TuringPi v2 - A New Generation of Power-Efficient Cluster Computing" />
<meta property="og:type" content="website" />
<meta property="og:image" content="/static/images/posts/turingpi2/02-turingpi2.jpg" />
<meta property="og:url" content="https://www.danmanners.com/posts/2022-01-turingpi-v2/" />

I'm unfortunately not the first person to come out with a review of the [Turing Pi 2](https://turingpi.com/); not even the second or third! [Jeff Geerling](https://www.youtube.com/c/JeffGeerling), [Techno Tim](https://www.youtube.com/channel/UCOk-gHyjcWZNj3Br4oxwh0A), and [LearnLinuxTV](https://www.youtube.com/channel/UCxQKHvKbmSzGMvUrVtJYnUA) on YouTube have all gotten their hands on the board as well, and they've done individually fantastic dives into the hardware, what it can do, and even offered some comparisons with other hardware in Jeff's video ([16:40](https://youtu.be/IUPYpZBfsMU?t=1000)).

So while I want to touch on the hardware, I don't want to dive into everything that the other reviewers have already covered. I'd like to help you understand, from my perspective, _why_ the Turing Pi 2 might be one of the most exciting pieces of technology in the past few years, and why it might be my favorite piece of technology in 2022.

<center>
    <img src="static/images/posts/turingpi2/02-turingpi2.jpg" width="70%" alt="Turing Pi 2" style="margin: 20px 0px; border-radius: 20px;">
</center>

## What is the Turing Pi 2?

The Turing Pi 2 is a Mini-ITX system board which allows up to **four** compute modules to be connected. Today, the [Raspberry Pi Compute Module 4](https://www.raspberrypi.com/products/compute-module-4/) and three [NVIDIA Jetson CoM (Computer-on-Module) units](https://www.nvidia.com/en-us/autonomous-machines/jetson-store/) can be connected to the board. In the future, other compute modules may be compatible, but that future isn't quite today. The board has several features that are tied to all of the nodes (RTC, Ethernet), while other connectors and components are tied to specific node slots.

> To utilize the board to it's fullest potential, you will want to fully populate all four node slots!

| Slot 1                                     | Slot 2    | Slot 3                  | Slot 4                                                                 |
|:-------------------------------------------|:----------|:------------------------|:-----------------------------------------------------------------------|
| mini-PCIe</br>SIM-card slot<br>GPIO 40-pin<br>HDMI | mini-PCIe | 2x SATA III</br>(6Gbps) | 4x USB 3.0 Ports</br>- 2x on Rear IO</br>- 2x on Front-Panel Connector |

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

The Turing Pi 2 matters because it's the first _tangible proof_ that ARM64 is not just for Apple or the enterprise (see: [AWS Graviton](https://aws.amazon.com/ec2/graviton/)); ARM64 ISA's have a real place in the homelab outside of individual Raspberry Pi nodes, and a real place in small and large businesses looking for small form factor (SFF) clustering (see: [Chick-Fil-A Edge Computing](https://medium.com/@cfatechblog/bare-metal-k8s-clustering-at-chick-fil-a-scale-7b0607bd3541)). I can absolutely see the Turing Pi 2 being fantastic for various segments of the Live Events and Entertainment industries, temporary Covid-19 testing sites in need of local compute, portable technical labs, or for rapidly deploying highly available and resilient systems in many small businesses. Being able to deploy a cluster of two or three of these boards in a significantly smaller footprint than nearly anything else on the market today with minimal cabling and no moving parts is an extraordinarily exciting concept.

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

I've gone through and evaluated an [NGFF (mini-PCIe) to NVMe Adapter with a Samsung 980 NVMe SSD](https://pipci.jeffgeerling.com/cards_m2/sintech-mpcie-m2-adapter.html), and while performance is not what I would normally expect from a Samsung 980 NVMe drive, I don't believe it to be a limitation with the Turing Pi at this point; it's plenty fast enough to act as persistent storage for building `arm64` containers natively! In conjunction with [Tekton CI/CD](https://tekton.dev/) or [buildah](https://buildah.io/) and an NGFF to NVMe adapter for an NVMe SSD, you can even run multi-architecture builds natively on `arm64` and `amd64` nodes respectively and push the final manifest up to a given container registry by leveraging `nodeSelectors` in your build pipeline. While that is not in and of itself a feature of the Turing Pi 2, I've never had an easier time provisioning and managing a multi-node K3s cluster with ARM64 nodes. The single ethernet and power cable make it quite fast to get all four nodes online.

## What's next?

While the baseboard firmware today has room for improvement, I trust that the Turing Pi software development team will continue to improve upon it. I think that the Turing Pi 2 hardware in its current state is very close to perfect, and I absolutely believe that this _will_ be a wonderful product by the time it lands in the hands of enthusiasts, fans, and Kickstarter backers.

The Turing Pi 2 team will be launching their Kickstarter in the near future, and I cannot wait to purchase a second unit. While I truly believe that the Turing Pi 1 was more of a niche product, pending the availability of Raspberry Pi Compute Module 4 units during the [global everything shortage](https://www.raspberrypi.com/news/supply-chain-shortages-and-our-first-ever-price-increase/), I think that the Turing Pi 2 could be an absolute home-run of a product for tech enthusiasts, anyone learning about Kubernetes, anyone with an interest in ARM64-based systems, and anyone wanting a low-power and efficient learning environment. Once this becomes available, I'm unsure there's going to be much else I'll be able to recommend that can offer so much bang-for-your-buck.

As far as pricing goes, that is yet to be determined as of the writing of this blog post. However, we have some known information and can make some reasonably safe assumptions:

- The Turing Pi 2 board will likely be priced between $180-330 USD
- Each compute module adapter board will run between $10-$15 apiece
- [MSRP of Raspberry Pi Compute Module 4 (8GB Memory 32GB eMMC, no Wi-Fi/Bluetooth): $90 USD](https://www.pishop.us/product/raspberry-pi-compute-module-4-8gb-32gb-cm4008032/)
- [MSRP of Raspberry Pi Compute Module 4 (4GB Memory 32GB eMMC, no Wi-Fi/Bluetooth): $65](https://www.pishop.us/product/raspberry-pi-compute-module-4-4gb-32gb-cm4004032/)
- [Mini-ITX chassis: ~$35-50 USD](https://www.amazon.com/gp/product/B07GZGXW6K)
- [A Pico-ITX power supply: ~$25 USD](https://www.amazon.com/gp/product/B08F57GKCL)
- [Power brick for the Pico-ITX PSU: $15-30 USD](https://www.amazon.com/gp/product/B07MXXXBV8)

All in, that'll put an estimated low price for a fully built system around $550 USD, and at a high estimate around $850 USD. While that may seem like a lot of money for a cluster of Raspberry Pi (or NVIDIA Jetson) nodes, once you start comparing it to building a cluster of other systems and boards you'll find yourself in the same price-range. The biggest challenge that any consumer is going to have these days is going to be actually _finding_ the Raspberry Pi 4 Compute Modules at MSRP. With the global technology market being where it is today and scalping/price gouging being as bad as it is, I'd highly recommend buying Compute Modules whenever and wherever you see them available if they're MSRP or close to it.

## Final Notes & Disclosures

Turing Pi **did not** financially compensate me for this post; this is 100% because I love this board and what I think it means for the future of low-power cluster computing. They did however send both the pre-production board shown at no cost to me as well as a NVIDIA Jetson Nano for evaluation.

If you're looking to join the Official Turing Pi Discord Server, want to find Turing Pi on Twitter or visit their website, click on the logos below!

<center>
    <a href="https://discord.com/invite/uNbysyc"><img src="static/images/posts/turingpi2/Discord-Logo-Color.png" width="10%" style="margin: 20px 20px;"></a>
    <a href="https://twitter.com/turingpi/"><img src="static/images/posts/turingpi2/2021-Twitter-logo-blue.png" width="10%" style="margin: 40px 20px;"></a>
    <a href="https://turingpi.com/"><img src="static/images/posts/turingpi2/logo-white.svg" width="10%" style="margin: 30px 20px; background-color: #3a3a3a; border-radius: 20px"></a>
</center>

If something I wrote isn't clear, feel free to ask me a question or ask me to update it! You can ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com), or tweet me [@damnanners](https://twitter.com/DamNanners).
