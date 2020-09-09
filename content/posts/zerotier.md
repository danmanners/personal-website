+++ 
draft = false
date = 2020-09-07T21:57:03-04:00
title = "ZeroTier makes Homelab VPN Easy"
+++

# ZeroTier makes Homelab VPN Easy

## Overview

If you're like me and you're running a homelab, you probably want a secure way to access your services remotely. Similarly, you've probably tried OpenVPN and needed to create your own certs. It works really well, but you've got to copy certificates and configurations from the server to each client system.

Let me introduce you to [ZeroTier](https://www.zerotier.com/). While ZeroTier behavies like a VPN at face value, it's so much more than that. It's really closer to a network switch for virtual VPN interfaces. For most folks, you'll probably only connect to one "switch" at a time. However, it's possible to be connected to several "switches" with multiple virtual interfaces. While I haven't had a use for it professionally, I could see it being an awesome way to do easy and quick multi-cloud routing.

## Important ZeroTier Terminology

Here's a quick overview of some of the important ZeroTier terminology: 

- The "Planet" is the controller.
- "Moons" are the networks.
- "Nodes" are client devices and can orbit (connect to) multiple moons.

## How am I using it

TL;DR - I created a "moon", joined a virtual machine in my homelab, added some static routes, and used IPtables on my VM to act as a router between other nodes and my home network.

### A deeper runthrough

First, you'll want to create an account on [my.zerotier.com](https://my.zerotier.com/). The account and up to 100 nodes is free, and if you want to connect more than that, you'll need to pay $49/month. For most people, I don't imagine this 'limitation' being an issue.

Once you've created the account, you'll need to create your network. Click the `Create a Network` button and...you're already most of the way done.

Really.

Click on the newly created network, copy the ID that it generates but do not close the web page. Go back to your Linux system. Go ahead and run this command to install ZeroTier on your system:

```bash
curl -s https://install.zerotier.com | sudo bash
```

Then, you'll want to join it to the network:

```bash
sudo zerotier-cli join $network_id_from_above
```

Once you've run the comand, go back to your web browser. Refresh the page, scroll down, and click the checkbox to accept the client that is attempting to join. Think of that checkbox as connecting the ethernet cable from the client to the switch/network/moon. If you want to add identifying information, now's a good time to do it.

Back on your Linux system, we'll need to run a few quick commands. We'll need to set `net.ipv4.net_foward` to 1 (and make it permanent), make sure that `iptables` is installed and operational, and create a couple of rules.

```bash
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
sudo vim /etc/sysctl.conf
# Uncomment 'net.ipv4.ip_forward=1'
ip a
# Copy the ethernet interface for the host
inteth="$ethernetInterface"
intzt="$zerotierInterface"
sudo iptables -A FORWARD -i $intzt -o $inteth -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $inteth -o $intzt -j ACCEPT
```

Once that's all done, you should be able to add another node to the moon and connect to things in your homelab.
