+++
title = "Security Onion on Proxmox"
date = 2019-05-14T20:34:28-04:00
draft = true
slug = ''
tags = ['proxmox','security onion','port mirroring']
categories = ['Networking','Security','IDS/IPS']
+++

# Why would you want to run Security Onion on Proxmox?

![Security Onion](/static/images/posts/proxmox-securityonion/SecurityOnionExample.png)

[Security Onion](https://securityonion.net) is an incredibly powerful toolset, and can do some very interesting things. Bro can be run on a mirrored port ingress and out of the box can break out your traffic metrics into a dockerized ELK stack. It's awesome.

# What does the full setup look like? 

- 1 VM running Security Onion
- 2+ NICs on the Hypervisor host
- Port Mirroring connected to a dedicated port on the Hypervisor
