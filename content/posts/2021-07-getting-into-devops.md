+++ 
draft = false
date = 2021-07-18T09:26:08-04:00
title = "Getting Into the DevOps Space"
slug = "2021-07-getting-into-devops" 
tags = ["devops","linux","scripting","career","thoughts"]
categories = ["devops","introduction","career"]
+++

## First Notes

I've seen a lot of posts recently with people asking how to get into the DevOps space and have been approached directly by several people looking for information. I figure the least I can do to give back to the community is offer advice from my perspective as someone _without_ a college degree, who jumped into the tech field almost immediately after high school. I've posted something similar to this on Reddit before, but I wanted to consolidate my thoughts into a single post.

## Making sure you want to actually get into DevOps

If you're thinking you want to get into DevOps, you first really need to ask yourself if you _enjoy_ doing Linux system administration and automating what you do. So much of how I view DevOps is Linux System Administration at scale mixed with both on-prem and cloud networking and service/application management, all topped with a hefty serving of troubleshooting and documenting what in the world is going on. If you don't like working with Linux, scripting, networking, or aren't generally comfortable or familiar with any of these things, you're probably going to have a bad time.

<center>
  <img src="/static/images/posts/2021-07-getting-into-devops/badtime.jpg" alt="Bad Time" style="margin: 20px 10px 10px 0px"/>
</center>

## Do I need a college degree

If you're looking to get into the DevOps field straight out of high school, you might be wondering if you _really_ need to go get an associates or bachelor's CompSci degree before diving into the job market.

Short answer: **No**.

Longer answer: While **you definitely do not need a college degree**, you should expect to grind for the two to four years you _would_ have been in school. Additionally, you should expect companies to not want to bring you on as a DevOps engineer right out the gate without being able to prove that you know what you are doing. Finally, you should consider that your pay may be tied to being young, not having a degree, and companies in general being kind of shitty to younger folks. More often then not, I will genuinely recommend looking at Helpdesk or SysAdmin jobs. Long term, I really believe it's almost all beneficial knowledge and experience. It can be a bit draining, but I can promise it helped get me to where I am today in my career.

## What has my career progression looked like

At a high level, my personal career progression has looked like this:

1. [**Production Resource Group, LLC**](https://www.prg.com/en) - ~4.5y | Early 2010 - Mid 2014
    1. Helpdesk, Windows System Administrator
    2. Helpdesk, Windows/Linux System Administrator II, Network Engineer
2. [**TOURtech, LLC**](https://www.tourtech.com/) - ~2.3y | Mid 2014 - End 2016
    1. Network Engineer
    2. Senior Network Engineer / Manager of IT Services
3. [**BrainGu, LLC**](https://braingu.com/) - ~2.3y | Early 2017 - Early 2019
    1. Junior DevOps Engineer
    2. DevOps Engineer
4. [**TOURtech, LLC**](https://www.tourtech.com/) - 1y | Early 2019 - Mid 2020
    1. Senior Network Engineer / Senior Systems Engineer}
5. [**Cisco**](https://www.cisco.com/) - 1.5y | Mid 2020 - Current
    1. DevOps Engineer (contractor role)
    2. Senior Site Reliability Engineer (FTE)

As you can see, I only _technically_ got into what I would consider the DevOps space in early 2017, and as of writing it's Summer 2021. At my first company I learned how to manually perform tasks and document what I was doing. At my second company, I spent an extraordinary amount of time learning Linux, complex networking concepts, and most importantly: **how to troubleshoot efficiently**. Without the knowledge of how to troubleshoot efficiently, I would have spent so much more time spinning my wheels, and I would have accomplished and learned less once I was truly in a DevOps role.

## How to get into the DevOps space

What I tell nearly everyone who has asked: If you can jump into DevOps with a 'good' to 'excellent' background in SysAdmin and/or networking experience, I think you have an excellent chance to succeed. Many people will recommend throwing together some public facing GitHub repositories where you can show off what you're learning. If nothing else comes of it, you've learned something new and can refer back to it later! Personally I'd recommend 2-3 different projects over a few months, but just start somewhere!

## What you should have familiarity with in the DevOps space

Here are a few things I highly recommend being familiar with, even if you don't know _any_ of them perfectly.

(This list is in no particular order.)

* Layers 1,2,3,4,7 of the OSI model
* Various Linux Operating Systems ([Fedora](https://getfedora.org/)/[Red Hat Enterprise Linux](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux), [Ubuntu](https://ubuntu.com/), and [openSUSE](https://www.opensuse.org/))
* Linux command line tools and functions (`ls`, `xargs`, `df`, `jq`, `ps`, Brace Expansion, and so many more)
* `bash` Shell Scripting
* Git, [GitHub](https://github.com/), and perhaps [GOGS](https://gogs.io/) for self-hosted Git
* DNS is the bane of so many; knowing and learning tools like `dig`, `whois`, `nslookup` can save hours with troubleshooting
* On-Prem Physical Switching and Routing; it translates surprisingly well to cloud and software-defined networking knowledge and will simply make life easier
* [Ansible](https://www.ansible.com/) or [Puppet Bolt](https://puppet.com/docs/bolt/latest/bolt.html)
* [Docker](https://www.docker.com/) (or other Container Runtimes, like [podman](https://podman.io/))
* [LetsEncrypt](https://letsencrypt.org/) and general PKI/Certificate creation and management
* [cURL](https://curl.se/)
* Where to look for system and service logs on different OS 'flavors'
  * How to **read and understand** said logs!!

Additionally, I recommend learning the following things after you're comfortable with the things above:

* [Terraform](https://www.terraform.io/) (for cloud resource provisioning)
* [Kubernetes](https://kubernetes.io/) (Start with [`k3s`](https://k3s.io/) and work your way up towards [`rke`](https://github.com/rancher/rke) and [`kubeadm`](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/))

## Personal learning project recommendations

With any of the following personal project recommendations, I expect that you will be doing this work on either MacOS, WSL2 (Windows Subsystem for Linux), or inside of a Linux Virtual Machine. If you're doing it on a baremetal Linux Machine or Virtual Machine in a cloud, you might not be right audience for this blog post!

* Write a bash script to install Docker, Terraform, and Ansible (or Puppet Bolt) on your  development system
* Create a personal GitHub project to document all of the work you're doing
  * Make sure to add README files and document everything you're doing to show a potential future employer you can write documentation 🙂
* Docker
  * Write a simple dockerfile and host it with Docker Hub
  * Write a docker-compose file with multiple containers (NGINX and either a Python Flask app or a `hello-world` style application)
* Terraform
  * Automate deployment of cloud compute resources with Terraform. I recommend starting with Digital Ocean to understand fundamentals
* Ansible (or Puppet Bolt)
  * Provision your Terraform created virtual machine with a service like NGINX running a "hello-world" page

### Cloud Resources

While there are a large number of projects and things you could do to start out, I recommend spinning up compute in a cloud provider like Digital Ocean for $5/month. It's a really easy way to get your feet wet and really start figuring things out in a real working environment.

### DevOps and Task Automation Tooling

When talking about Ansible or Puppet Bolt with industry experts, Ansible generally seems like it should be the clear choice. However, many organizations I've spoken with are seriously looking at or considering Puppet Bolt _if_ they already have teams of people who know Puppet. Being able to re-use existing work is highly attractive to some teams, so consider that when you decide to learn one or the other. While both tools are absolutely different, both tools fundamentally achieve the same goal. If you learn one well, the other can be learned easily enough over time.

### Containerization

Docker and Kubernetes will almost definitely be a must, so getting your feet wet in that space is crucial. If you spin up two DigitalOcean droplets, you can install K3s on them and run them in a master/worker setup. Alternatively, DigitalOcean [offers their own managed Kubernetes service](https://www.digitalocean.com/products/kubernetes/). There's an overwhelming amount of tools and knowledge to consume regarding Kubernetes, and it can be completely daunting. Hell, [see how long this CNCF Cloud Native Interactive Landscape takes to load on your computer](https://landscape.cncf.io/); that's just **SOME** of the tools and vendors available in regards to Kubernetes!

**Start super simple**.

Figure out how to write a deployment file to launch pods. Write a service resource. Create an Ingress or IngressRoute resource to access your application from outside of the cluster. Look up (and download) tools like [Lens](https://k8slens.dev/) or [k9s](https://github.com/derailed/k9s) to help you more easily visualize what is going on with your Kubernetes cluster.

## Things to avoid when getting into the DevOps space

You may see plenty of online courses that market themselves as "Get DevOps certified in 8 weeks!" or something to that effect. While I have to believe that there are _some_ programs out there that may help you understand some concepts that you previously did not understand or grasp, the **vast** majority of them are simply crummy or scam money-grab operations. If you're paying more than $40-50 for a course online, really look into objective reviews to evaluate if it's going to be beneficial to you.

Everyone has different learning styles, but I will almost always recommend getting your hands dirty and just doing _something_ over a lecture style recorded meeting.

## How to stand out as a job applicant / candidate

I'm not going to sugar-coat it: getting your first tech job might suck. Over the past ~13 years, landing your first job has become more and more challenging. However, focusing on roles where you can really get some good experience and might have a high attrition rate can be good. Look for Helpdesk, System Administration, or Network Technician roles at small to mid-size companies (30-500 employees). While you might have a better chance getting a job at a large company, you are unlikely to learn much past whatever tools have been deemed essential for that role and at **that** company specifically. It can be surprisingly painful to learn that the specifics of what you've learned over however long you work somewhere simply won't translate.

The core reason I recommend smaller to mid-sized companies is that you are more likely to deal with a lot of different technologies and tasks, and there is a higher chance that the IT or Engineering departments will be smaller and less-structured. With departments and organizations at that level, there is a much better chance you will be able and allowed to branch out into different technologies that you simply wouldn't have the opportunity to with a larger organization.

It might not be glamorous, but getting your best foot in _any_ door and showing that you **want** to keep learning and constantly do better is always good.

## Final thoughts

The DevOps/DevSecOps space is very wide, and will not always be well defined. If there are specific or niche things you want to dive more deeply into and learn, you should do just that! It's an ever-evolving field of tools and vendors, and if you don't stay on top of things you'll probably feel out of date within a couple of years.

I personally love that feeling, and being in the DevOps space never leaves me feeling bored. I'm always learning something new, I'm almost always evaluating a new idea or deployment methodology, or I'm looking into how and why `Organization A` structured their code versus how `Organization B` structured something similar. Being able to design immutable infrastructure while deploying and maintaining it as ["cattle" rather than "pets"](https://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/) is incredible, and I really enjoy it!

If you want to read more, you can check out an earlier post of mine covering [things I wish I knew earlier](/posts/things-i-wish-i-knew-earlier/) in my career.

## Digital Ocean - Free $100 in account credit for 60 Days

If you don't have a Digital Ocean account already, [consider signing up with my referral link here](https://m.do.co/c/a286136cde19). It's a free $100 in credit your first 60 days, and once you've spent $25, I get $25 in credit. Little things like this help me pay for my Digital Ocean hosting costs at no additional cost to you. I'm not sponsored by them or anything, I just really appreciate them as an organization. Thank you so much!

<center>
  <a href="https://www.digitalocean.com/?refcode=a286136cde19&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge"><img src="https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg" alt="DigitalOcean Referral Badge"></a>
</center>

## Questions? Thoughts?

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or tell me to update it!
