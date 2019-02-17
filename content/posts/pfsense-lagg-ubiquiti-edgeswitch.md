---
title: "pfSense Lagg Ubiquiti Edgeswitch"
date: 2019-02-10T22:55:30-05:00
draft: false
---

# pfSense LAGG and the Ubiquiti EdgeSwitch

Many folks in both the homelab community and SMB's run <a href="https://pfsense.com">pfSense</a>. It's a FreeBSD based firewall/router/VPN OS that can be run on lots of hardware and almost any hypervisor. It's common that if you're using pfSense you'd be running a switch on your network. It's not uncommon to say that if you're using pfSense, you'd possibly be using a managed switch.

If you're running into a situation where you sometimes need more than 1 Gbps on your LAN, but have no interest or easy availablity to run 10Gbps networking, you've probably looked into Link Aggregation or LACP as an option if you've got ports to spare on your managed switch.

Fun fact about LACP/LAGG/IEEE 802.1AX-2008 (formerly IEEE 802.3ad) though: almost everything has a different implementation of the same protocol. Fun.

So what does a poor implemntation of LACP look like? From a functionality standpoint, it might look like it works on one side (Ubiquiti EdgeSwitch 24) and that there is no connection on the other side (pfSense Router).

After a few hours of searching forums and Reddit, I came to the answer that the EdgeSwitch doesn't have an "active" mode, just passive. FreeBSD on the other hand, by default only tries to negotiate with "active" LACP/LAGG ports. So due to the poor implementation of the 802.3ad protocol, it had to be "resolved" with pfSense by adding the System Tunable `net.link.lagg.lacp.default_strict_mode` key and setting the value to 0.

Make sure you understand your needs ahead of time and buy the right hardware for you.

For anyone skimming, TL;DR is that Ubiquiti EdgeSwitch firmware has a crappy implementation of the 802.3ad LACP/LAGG protocol and that makes pfSense LAGG sad.
