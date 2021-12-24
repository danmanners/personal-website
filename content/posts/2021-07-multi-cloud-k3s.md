+++ 
draft = false
date = 2021-12-22T23:01:50-04:00
title = "Multi-Cloud K3s, and also I got (temporarily) kicked off Google Cloud "
slug = "2021-12-multi-cloud-k3s-and-booted-from-gcloud" 
tags = ['networking','k3s','cloud','google-cloud','ZeroTier','terraform','traefik']
categories = ['Kubernetes','Cloud','ZeroTier','Terraform','Terragrunt','Traefik']
+++

For a while now, I've wanted to figure out _something_ to do with multi-cloud networking and compute. Single cloud is pretty easy these days; if there's something you want to do, and it's single cloud, there's probably at least a handful of blog posts about it. Multi cloud is still a bit more esoteric and 'weird' at both the small and large scale, and there just aren't as many resources available.

## An Idea Appears - A High Level Overview

Since I finally have [Ting Fiber](https://ting.com/internet) installed at my house, and Spectrum managed to offer me a $25/month discount from what I had been paying to keep it for one more year, I decided it was time to move my website back to my house. However, I wanted to be smarter about it. I didn't want to expose **any** ports for my home to the open web, and I wanted to implement redundancy and resiliency more than one way.

Well, I've already built a proof-of-concept in the past using K3s in Digital Ocean, using the Public IP there to serve my website. That worked pretty well, but there were a lot of manual steps to get everything up and running. I was hoping that I could get nearly everything automated and repeatable, allowing other folks to use the same logic for their own systems.

## What are all the technologies that will be leveraged?

While there are almost definitely better ways to do this, here's what I ended up going with:

- Terraform/Terragrunt
- Two (or more) Cloud Providers
  - When originally written, AWS and Google Cloud
- Cloud Provider Security Group to only allow `TCP/22`, `TCP/80`, and `TCP/443` for SSH, HTTP and HTTPS respectively.
- K3s Lightweight Kubernetes
- ZeroTier
- Traefik v2+ running in Kubernetes (k3s)
- NGINX acting as a Layer-4 Reverse Proxy for TCP (and UDP if necessary) on each cloud VM host
  - Listening/Proxying TCP/80 and TCP/443 to the appropriate Traefik ports

## Deploying Multi-Cloud Infrastructure with Terraform

This part was actually among the easiest, relatively speaking. Because I'm hosting these nodes directly on the internet, I didn't have to worry about some of the more potentially complex networking. I just needed a public-facing networking, internet gateways, and the ability to map public IPs to my VM hosts. My personal requirement was that I wanted to be able to launch everything in the cloud with a single command, `terragrunt apply`. This means that **both** all of my cloud providers needed to be put together. You can see [all of the code for my multi-cloud Terraform here](https://github.com/danmanners/homelab-k3s-terraform)!

> **NOTE**: You may notice that Google Cloud isn't in the codebase...keep reading for why that is.

## Deploying K3s in Multi Cloud

At a high level, the steps for getting everything working looked like this:

1. Provision the on-prem database and control plane nodes
2. Provision the on-prem ZeroTier router host
    - Ensure all of the routing rules exist (and function!) both in ZeroTier and with my on-prem router
3. Run the Terraform IaC provisioning code to spin up cloud hosts
4. Join each cloud host to ZeroTier (and approve them in the console)
5. Install the K3s Binary
6. Install the systemd service file
7. Ensure connectivity back to my homelab
8. Enable and start the service

While there were a couple of challenges, I was eventually able to get everything working. I can boil things down to some modifications to my `k3s-node` service file, which I'll run you through after the parts of the file that matter.


### `k3s-node.service` systemd service file

```cfg
# /etc/systemd/system/k3s-node.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
# We do not want to start k3s until ZeroTier is started and running
After=network-online.target ZeroTier-one.service

[Service]
Type=notify
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay

# This ensures that the Ubuntu DNS service uses the zerotier interface
# to route to the homelab DNS for relevant traffic.
ExecStartPre=/usr/bin/systemd-resolve -i ztyou2j6dw --set-dns=10.45.0.1

ExecStart=/usr/local/bin/k3s agent
KillMode=process
Delegate=yes
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s

[Install]
# We do not want to start k3s until ZeroTier is started and running
Requires=ZeroTier-one.service
WantedBy=multi-user.target
```

The three sections we care about are:

```cfg
# Line 1
[Unit]
After=network-online.target ZeroTier-one.service

# Line 2
[Service]
ExecStartPre=/usr/bin/systemd-resolve -i ztyou2j6dw --set-dns=10.45.0.1

# Line 3
[Install]
Requires=ZeroTier-one.service
```

For line 1, we want to ensure that the `k3s-node` service only starts **after** `ZeroTier-one`.

For line 2, we want to ensure that prior to starting the service, we update `systemd-resolve`, Ubuntu's built in DNS service, to route DNS requests to `10.45.0.1` (my homelab's DNS server) over the ZeroTier network interface.

Line 3 is similar to line 1. We want to ensure that the K3s service **REQUIRES** that ZeroTier is running.

## Troubleshooting Google Cloud ZeroTier

Right off the bat, in Google Cloud specifically I had an issue where when K3s started, after about 90 seconds the host would lock up, become completely unresponsive, and then require a hard restart. I troubleshot it for a couple days, but it looked like some incredibly strange and esoteric software bug. I left it for a couple days, as I was working on my dayjob, and I was surprised by an email about a day later...

## I Got Kicked off of Google Cloud for "cryptomining" (LOL)

<center>
<img src="/static/images/posts/2021-12-multi-cloud-k3s/cryptomining-lol.png#center" width="60%">
</center>

TL;DR: Google sent me an email warning me that because I was cryptomining on my account (which...no) I was having my resources suspended.

<center>
<img src="/static/images/posts/2021-12-multi-cloud-k3s/account-suspended.png#center" width="60%">
</center>


After a back and forth with Google over about 24 hours, my account was unlocked. According to Google Support, the syscalls from my host to the CPU were indicitive of cryptomining on my host, which they [**absolutely do not permit**](https://support.google.com/cloud/answer/7002354?hl=en#zippy=%2Cwhy-was-my-project-flagged-for-cryptocurrency-mining), and on a phone call made a comment along the lines of "they're always striving to improve their system monitoring and weed out false negatives." Fair enough, I guess; but here I am **very definitely not cryptomining** and I've been locked out of my account for trying to run K3s with Zerotier. Not great.

They did accept my explanation, and unlocked my account, but it definitely meant I needed to figure out what the hell was going on.

### Creating the `/var/lib/zerotier-one/local.conf` file

After finding a GitHub issue regarding [packet flooding and high CPU usage](https://github.com/zerotier/ZeroTierOne/issues/779), this is what was necessary to stop the "cryptomining" on my Ubuntu cloud hosts in Google Cloud:

```json
{
  "settings": {
    "interfacePrefixBlacklist": [ "flannel", "cni" ]
  }
}
```

Without that, Zerotier would hit an odd issue where it would "loop" traffic from the K3s flannel CNI into the Zerotier network, and because everything is encrypted, it _looks_ like the host is cryptomining. [You can read more about it on the GitHub Issue linked here](https://github.com/zerotier/ZeroTierOne/issues/1423).

## Where things ultimately landed

So I was able to fix the ZeroTier/Ubuntu loopback issue with Google Cloud, but I was not sold on the idea that I wouldn't get my resources shut down hard again. I reluctantly decided to steer clear of Google Cloud for the time being, and focus on Azure and AWS as my two cloud providers.

On the bright side, I'm up and operational today in a multi-cloud environment! You can verify this locally by running either `dig` or `nslookup`:

```bash
➜  dig +noall +answer danmanners.com
danmanners.com.		289	IN	A	40.76.165.69
danmanners.com.		289	IN	A	54.158.27.71

➜  nslookup danmanners.com 8.8.8.8
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
Name:	danmanners.com
Address: 40.76.165.69
Name:	danmanners.com
Address: 54.158.27.71
```

So, while you're reading this, you're _either_ hitting my AWS or Azure host, with the load split via DNS and whomever responds first!

# Questions? Thoughts?

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or ask me to update it!
