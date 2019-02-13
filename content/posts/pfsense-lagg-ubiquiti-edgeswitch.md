---
title: "pfSense Lagg Ubiquiti Edgeswitch"
date: 2019-02-10T22:55:30-05:00
draft: true
---

# pfSense LAGG and the Ubiquiti EdgeSwitch

TL;DR: FreeBSD & pfSense don't play well with switches with poor implementations of the 802.3ad protocol for LACP.




Many folks in both the homelab community and SMB's run <a href="https://pfsense.com">pfSense</a>. It's a FreeBSD based firewall/router/VPN OS that can be run on lots of hardware and hypervisors. It's not uncommon that , and that can be "resolved" with pfSense by adding the System Tunable `net.link.lagg.lacp.default_strict_mode` and setting it to 0.

