+++ 
draft = true
date = 2021-07-03T23:01:50-04:00
title = "Multi-Cloud K3s, and also I got kicked off Google Cloud "
slug = "2021-07-multi-cloud-k3s" 
tags = ['networking','k3s','cloud','google-cloud','zerotier','terraform']
categories = ['Kubernetes','Cloud','Zerotier','Terraform']
+++

For a while now, I've wanted to figure out _something_ to do with multi-cloud networking and compute. Single cloud is pretty easy these days; if there's something you want to do, and it's single cloud, there's probably at least a handful of blog posts about it. Multi cloud is still a bit more esoteric and 'weird' at small scale.

## An Idea Appears - A High Level Overview

Since I finally have [Ting Fiber](https://ting.com/internet) installed at my house, and Spectrum managed to offer me a $25/month discount from what I had been paying to keep it for one more year, I decided it was time to move my website back to my house. However, I wanted to be smarter about it. I didn't want to expose **any** ports for my home to the open web, and I wanted to implement redundancy and resiliency more than one way.

Well, I've already built a proof-of-concept in the past using K3s in Digital Ocean, using the Public IP there to serve my website. That worked pretty well, but there were a lot of manual steps to get everything up and running. I was hoping that I could get nearly everything automated and repeatable, allowing other folks to use the same logic for their own systems.

## What applications and services will be leveraged?

## Deploying Multi-Cloud Infrastructure with Terraform

## Deploying K3s in Multi Cloud

## Troubleshooting Google Cloud Zerotier (ft. I got kicked off Google Cloud)


# Questions? Thoughts?

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or tell me to update it!
