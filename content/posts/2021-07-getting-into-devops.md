+++ 
draft = true
date = 2021-07-18T09:26:08-04:00
title = "Getting Into the DevOps Space"
slug = "2021-07-getting-into-devops" 
tags = ["devops","linux","scripting","career","thoughts"]
categories = ["devops","introduction","career"]
+++

I've both seen a lot of posts recently of folks asking how to get into DevOps/DevSecOps and been reached out to directly by several people looking to get into the space. I figure the least I can do to give back is some advice from my perspective as someone _without_ a college degree, who jumped into the tech field almost immediately after high school. I've posted something similar to this on Reddit before, but I wanted to consolidate my thoughts into a single post.

## Making sure you want to actually get into DevOps

If you're thinking you want to get into DevOps, you first really need to ask yourself if you _enjoy_ doing Linux system administration. So much of how I view DevOps is Linux System Administration at scale mixed with both on-prem and cloud networking and service/application management, all topped with a hefty serving of troubleshooting and documenting what in the world is going on in your head. If you don't like working with Linux, scripting, networking, or aren't generally comfortable or familiar with any of those three things, you're probably going to have a bad time.

<center>
  <img src="/static/images/posts/2021-07-getting-into-devops/badtime.jpg" alt="Bad Time" style="margin: 20px 10px 10px 0px"/>
</center>

## Do I need a college degree

If you're looking to get into the DevOps/DevSecOps field straight out of high/secondary school, you might be wondering if you _really_ need to go get an associates or bachelor's CompSci degree before diving into the job market.

Short answer: **no**.

Longer answer: While you **definitely** do not need a college degree, you should expect to grind for two to four years career wise, and you should expect to take a hit on salary while still pushing for good wages. Whether that's fair or not is a **completely** separate topic, but my two cents is that you are unlikely to make the amount of money you believe you're worth. There's a reasonably large number of people wanting to be DevOps engineers, and it sure looks like a race to the bottom in many situations.

## What has my career progression looked like

At a high level, my personal career progression has looked like this:

1. **Production Resource Group, LLC** - ~4.5y | Early 2010 - Mid 2014
    1. Windows System Administrator
    2. Windows / Linux System Administrator II, Network Engineer
2. **TOURtech, LLC** - ~2.3y | Mid 2014 - End 2016
    1. Network Engineer
    2. Senior Network Engineer / Manager of IT Services
3. **BrainGu, LLC** - ~2.3y | Early 2017 - Early 2019
    1. Junior DevOps Engineer
    2. DevOps Engineer
4. **TOURtech, LLC** - 1y | Early 2019 - Mid 2020 
    1. Senior Network Engineer / Senior Systems Engineer}
5. **Cisco** - 1.5y | Mid 2020 - Current
    1. DevOps Engineer (contractor role)
    2. Senior DevOps Engineer (FTE)

As you can see, I only really _technically_ got into what I would consider the DevOps space in early 2017. However, at my second company I spent an extraordinary amount of time familiarizing myself with Linux, complex networking concepts, and most importantly: **how to troubleshoot efficiently**. Without the knowledge of how to troubleshoot efficiently, I would have spent so much more time spinning my wheels and accomplishing and learning less.

## How to get into the DevOps space

What I tell nearly everyone who has asked: If you can jump into DevOps with a 'good' to 'excellent' background in SysAdmin and/or networking experience, I think you have an excellent chance to succeed. As many people will say: throw together some public facing GitHub repos where you can show off what you're learning. If nothing else, you've learned something new! Personally I'd recommend 2-3 different projects over a few months, but just start somewhere!

## What you should have familiarity with in the DevOps space

Here are a few things I highly recommend being familiar with, even if you don't know _any_ of them perfectly. This list is in no particular order.

* Various Linux Systems (Ubuntu Server, Fedora/CentOS/RHEL)
* `bash` Shell Scripting
* Git, GitHub, and perhaps GOGS for self-hosted Git.
* Ansible or Puppet Bolt
* Docker (or other Container Runtimes)

Additionally, I recommend learning the following things:

* Terraform
* Kubernetes (`kubeadm`, `rke`, `rke2`, or `k3s`)
* Layers 1,2,3,4,7 of the OSI model

## Personal learning project recommendations

With any of the starting personal project recommendations, I 100% expect that anyone should be doing this work on either MacOS, WSL2 (Windows Subsystem for Linux), or inside of a Linux Virtual Machine.

* Write a bash script to install Docker, Terraform, and Ansible (or Puppet Bolt) on your  development system
* Create a personal GitHub project to document all of the work you're doing
  * Make sure to add README files and document everything you're doing to show a potential future employer you can write documentation 🙂
* Docker
  * Write a simple dockerfile and host it with Docker Hub
  * Write a docker-compose file with multiple containers (NGINX and either a Python Flask app or a `hello-world` style application)
* Terraform
  * Automate deployment of cloud compute resources with Terraform. I recommend starting with Digital Ocean to understand fundamentals
* Ansible (or Puppet Bolt)
  * Provision a service like NGINX with a "hello-world" page

### Cloud Resources

While there are a large number of projects and things you could do to start out, I recommend spinning up compute in a cloud provider like Digital Ocean for $5/month. It's a really easy way to get your feet wet and really start figuring things out in a real working environment.

### DevOps and Task Automation Tooling

When talking about Ansible or Puppet Bolt, Ansible seems like it should be the clear choice, but many organizations I've talked to are seriously looking at Puppet Bolt _if_ they already have teams of people who know Puppet. Being able to re-use existing work is very attractive to some teams/organizations, so consider that when you're learning one or the other. While both tools are absolutely different, both tools fundamentally achieve the same goal. If you learn one well, the other can be learned easily enough over time.

### Containerization

Docker/Kubernetes will almost definitely be a must, so getting your feet wet in that space is crucial. If you spin up two $5/month DigitalOcean droplets, you can install K3s on them and run them in a master/worker setup. There's a TON out there to understand about Kubernetes, and it is overwhelming as all hell. Start super simple. Figure out how to create a service, a deployment, and look up (and download) tools like Lens or k9s to help you visualize what in the world is going on with a Kubernetes cluster.

## Things to avoid when getting into the DevOps space

You may see plenty of online courses that market themselves as "Get DevOps certified in 8 weeks!" or something similar. While I have to believe that there are _some_ programs out there that may help you understand some concepts that you previously did not understand or grasp, the **vast** majority of them are simply crummy or scam money-grab operations. If you're paying more than $40-50 for a course online, really look into objective reviews to evaluate if it's going to be beneficial to you.

Everyone has different learning styles, but I will almost always recommend getting your hands dirty and just doing _something_ over a lecture style recorded meeting.

## Final thoughts

The DevOps/DevSecOps space is very wide, and will not always be well defined. If there are specific things you want to dive deeply into and work on, you **should** do just that! It seems to evolve every 4-6 months towards the next tool, and if you don't stay on top of things you'll feel out of date within a couple of years to some degree. I personally love being in the DevOps space because I **never** feel board. I'm always learning something new, I'm almost always evaluating a new idea or method of deployment methodology or looking into how `Organization A` structured their code versus how `Organization B` structured similar code. Being able to quickly, easily and immutably design and deploy infrastructure and maintain it as "cattle" rather than "pets" is incredible, and I really enjoy it.

## Questions? Thoughts?

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or tell me to update it!
