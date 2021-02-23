+++
title = "Why Kubernetes is a Hard Sell for Small Businesses"
date = 2020-02-20T21:14:14-04:00
draft = false
slug = "kubernetes-in-small-businesses"
tags = ['kubernetes','small-business','docker']
categories = ['Networking','Kubernetes','docker']
+++

While the title specifically says Kubernetes, you could replace it with `Service X`. The reason I'm going with Kubernetes here is because of a number of recent conversations I've had with people that made me feel like I should write _something_ about this.

# Explaining the Reality of a Small Business

If you've ever read posts on either [/r/sysadmin](https://www.reddit.com/r/sysadmin/), [/r/talesfromtechsupport](https://www.reddit.com/r/talesfromtechsupport/), or any other similar subreddit, you've likely seen when someone raises their hand to say something along the lines of "You should immediately bring `[issue]` to your `[security|compliance|SecOps]` team and lock `[person|team|customer]` out of your system!" The people who often suggest this operate in a different world than a lot of small businesses, and that's not a bad thing. Most professional large-scale organizations do have a security team, a compliance team, and/or SecOps teams, while most small businesses just don't. They simply have their "IT Person" or "tech team." Not glamorous names for sure, but that's just the reality.

Unless your company is an IT services company, your organization will not have the budget or resources to hire multiple people for multiple teams. You're going to have somewhere between one and three people, more commonly leaning towards the low to mid-end of that range. The concept of someone doing something dangerous, reckless, or simply stupid isn't going to result in some glorious firing and an amazing story to write about. It's going to result in one of the owners or a manager simply saying "Are you serious? Don't do that again, that's dumb." _At best_.

If you only have one to three IT people at an organization, the daily tasks and operataional workflows for those people are going to be either highly specialized or very general with limited specialization. There isn't going to be a lot of middleground there, and small businesses aren't going to have, what I have often heard referred to as, a "Bus Plan."

# The Bus Plan

If you don't know what that is, a bus plan effectively boils down to this statement:

> "What would we do if `Person` gets hit by a bus today and we lose all of the knowledge and history they had for our organization?"

Due to the common lack of a "Bus Plan," it is (or appears to be) incredibly dangerous for the organization to jump both feet first into complicated systems. Among the list of "traditional" complicated systems are:

* Active Directory (Or some form of SSO)
* Configuration Management
* Proper Backup and (tried and true) Restore
  * Hardware failure, Ransomware attack, etc.
* Active System Monitoring
* Centralized Anti-Virus software
* Asset Tracking
* Highly available services (of any flavor)

Then you get to "newer" complicated systems:

* Cloud-hosted Infrastructure
* Declarative vs Imperative Infrastructure
* Docker/Containerized Infrastructure
* Kubernetes
> and I'm sure there are tons more examples I cannot think of because I'm tired. I'll come back to this eventually...

From a management perspective of a small business, the "traditional" bits are already enough of a hard sell. Forget the fact they're basic IT needs: they all cost money and IT is a cost center not a profit center. Now add on top of that management knows that if you (`Person`) decided to quit tomorrow, they'd be pretty screwed because no one would know how to hand off your workload to a new employee. What incentive do they have to agree to implementing and integrating more complicated systems that are less understandable for a lay person, and simply will have a more complicated IT workflow?

# Why Kubernetes (and/or Docker), is great...

There are a ton of benefits to running Kubernetes for your applications. Your deployments end up boiling down to good bits of the code you would have written before followed by a handful of (essentialy) config files. These are really easy for teams of reasonably qualified people to read and understand, or if you don't know it, Google or search StackOverflow for what it is things are doing.

Both Docker and Kubernetes allow for developers to easily build, deploy, and manage custom tailored solutions. They're awesome and powerful tools. It makes it real easy to declaratively state in your codebase that you are going to do things an industry standard way. The main resources you need to properly utilize Docker and Kubernetes include training, wisdom, and the most valuable of commodities: time.

# ...and why Kubernetes (and/or Docker) sucks for (most) small businesses.

I am very fortunate to have an excellent relationship with both my boss and my CEO. When we were recently talking, the CEO made an amusing, but valid statement:
> You **do** know that if you were to just quit and leave tomorrow, I'm very sure I'd roll our entire network rack into the creek behind the office, right? Doesn't matter if it's functional or not, but even with the documentation you have it wouldn't matter. We'd probably need to start from scratch anyway.

While I'm aware that it was _mostly_ a joke, it brought up a good point: If management doesn't trust that they could hand off an entire project from one person to another, what good would it be implementing in the first place? Objectively speaking, based on my combination of specific historical knowledge of the organization, budget, overall industry experience, and (probably most importantly) out-of-industry experience, they would have an exceptionally hard time finding a replacement.

Simply put: from the management perspective, jumping into something like Kubernetes doesn't make sense even if it will save time and money while it's functional, because having it non-functional could be dangerous to daily operation and the optics of what the company does. There simply aren't enough people who know it, or there isn't enough budget to bring on more people who would understand it and could support it.

On top of all that, it's more than likely smaller businesses simply don’t need the complexity. They need a couple of Windows "servers" (or older desktops operating as servers) to run Quickbooks, Dropbox, and perhaps a CRM that's hosted by a company that they throw a couple bucks at per-user per-month.

If you’re an employee of a small organization, you’re likely not a developer yourself or on a team of experts; it's far more likely you're an individual attempting to perform maintenance and implement enhancements in real time, much like building a plane as it's flying. Most small organizations simply don't have the resources to maintain their IT environment and keep their systems and/or applications up-to-date.

When something becomes deprecated in containerized infrastructure, it's generally for good reason. So many small businesses lean so heavily on deprectated software or key features of software in unbelievably dangerous ways. While containerized environments may greatly assist in version control due to features like image tags, the same containerized environment could be broken by someone accidentally updating nodes past an approved point in time, where they would no longer run older manifest files correctly.

# Final Thoughts

This is mostly a rambling post based subjectively on my own experiences. That being said, conversations with other people in both small companies as well as large companies, it seems to be pretty on point.

[Do you think I'm wrong? Tell me, I'd love to know how](mailto:daniel.a.manners@gmail.com).

##### Footer

* Thanks to [Matt Miller](mailto:matt.miller@disruptive-sol.com) for some excellent points in the above ramblings.
* Thanks to Nina Faile for reviewing and re-phrasing much of the above text!