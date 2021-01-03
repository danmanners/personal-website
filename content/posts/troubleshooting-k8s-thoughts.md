+++ 
draft = false
date = 2021-01-01T22:50:00-05:00
title = "K8s Troubleshooting After Docker Hub Changes"
slug = "" 
tags = ['k8s','docker','kubernetes','homelab','docker_hub','troubleshooting']
categories = ['Kubernetes','Homelab','Docker']
+++

I'm not quite sure where to start with this one, so I'll just come out and say it: if you ever have had to shut down and turn your Kubernetes cluster back on, and you have services with persistent storage, _and_ if you find out that your credentials for at least one service have expired, you'll know how absolutely horrible it can be to get everything back up and running.

![Lots of Lens Errors](/static/images/posts/troubleshooting/lens-oh-no.png)

## What the hell is happening right now

Quick summary: It appears that between DNS issues and the new(ish) Docker Hub restrictions, my cluster simply "took a shit" when trying to come back up. After a couple days, I realized it simply wasn't going to recover by itself.

## Troubleshooting

Let's see what's going on with DNS if we try to pull the container manually...

```bash
ubuntu@dev-k8s-node7:~$ docker pull jenkins/jenkins:2.249.3-lts-centos7
Error response from daemon: Get https://registry-1.docker.io/v2/jenkins/jenkins/manifests/2.249.3-lts-centos7: Get https://auth.docker.io/token?scope=repository%3Ajenkins%2Fjenkins%3Apull&service=registry.docker.io: dial tcp: lookup auth.docker.io: No address associated with hostname
```

Huh. Well that obviously doesn't look good. Let's try running a `dig` and then pulling it, maybe it's not handling DNS correctly.

```bash
ubuntu@dev-k8s-node7:~$ dig registry-1.docker.io

# ; <<>> DiG 9.11.3-1ubuntu1.13-Ubuntu <<>> registry-1.docker.io
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56096
# ;; flags: qr rd ra; QUERY: 1, ANSWER: 8, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;registry-1.docker.io.          IN      A

;; ANSWER SECTION:
registry-1.docker.io.   36      IN      A       3.218.162.19
registry-1.docker.io.   36      IN      A       52.5.11.128
registry-1.docker.io.   36      IN      A       54.85.56.253
registry-1.docker.io.   36      IN      A       34.195.246.183
registry-1.docker.io.   36      IN      A       52.54.232.21
registry-1.docker.io.   36      IN      A       3.211.199.249
registry-1.docker.io.   36      IN      A       52.72.232.213
registry-1.docker.io.   36      IN      A       23.22.155.84

;; Query time: 0 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Sun Jan 03 03:57:32 UTC 2021
;; MSG SIZE  rcvd: 177

ubuntu@dev-k8s-node7:~$ docker pull jenkins/jenkins:2.249.3-lts-centos7
2.249.3-lts-centos7: Pulling from jenkins/jenkins
75f829a71a1c: Pull complete 
7f008391e12b: Pull complete 
952333a4dc8a: Pull complete 
a3d3c3d6cde0: Pull complete 
b0b580fbf61f: Pull complete 
c7c7dfdb2029: Pull complete 
8cc852592c2c: Pull complete 
2e50fe2f94e8: Pull complete 
25378c684e70: Pull complete 
3901eb041e7e: Pull complete 
40db237748bc: Pull complete 
34b4001e5ca1: Pull complete 
1514f58001fa: Pull complete 
98b89fc5a65a: Pull complete 
Digest: sha256:b123067a0d88a12eb54f4e1c70142ea9d5509bfcfc7c511454459ea33b89c03b
Status: Downloaded newer image for jenkins/jenkins:2.249.3-lts-centos7
docker.io/jenkins/jenkins:2.249.3-lts-centos7
```

Yup, that worked. `systemd-resolve` on Ubuntu 18.04 LTS is dogshit. Okay, well I know my core DNS server at home is fine, because if I run a dig on **ANY OTHER SYSTEM IN MY HOUSE** it's completely and totally fine. I guess besides that I don't have any strong opinions.

## The Fix (for DNS)

First, we need to fix the damn DNS service on all of our hosts.

```bash
$ for i in dev-k8s-node{1..9}; do ssh ubuntu@$i -t 'sudo systemctl disable systemd-resolved && sudo rm /etc/resolv.conf && sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'; done
```

Great, now it should all resolve in just a few moments--

![Lots of Lens Errors](/static/images/posts/troubleshooting/lens-more-errors.png)

Well shit. That's the Docker Hub limitation.

## More Troubleshooting

If we look at the log in that screenshot, we can see it reads:

`toomanyrequests: too many failed login attempts for username or IP address`

On my laptop, I can verify it's not an IP address issue by pulling an image you don't have locally. Easy way to check:

```bash
docker rmi hello-world && docker pull hello-world
```

If this works, it's not an IP address issue. We're simply hitting unauthenticated issues with Docker Hub.

Awesome...

## Additional Fixes

We'll need to load our Docker Hub credentials inside Kubernetes. You can run a single command to create the secret inside of your `default` namespace, like this:

```bash
$ kubectl create secret docker-registry regcred \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=danielmanners \
    --docker-password=DefinitelyNotMyRealPassword \
    --docker-email=not.a.real.email@provider.com
```

Alternatively, you can create it in several different namespaces, like this:

```bash
$ for namespace in kube-system metallb-system nda jenkins argocd; do \
    kubectl create -n $namespace secret docker-registry regcred \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=danielmanners \
    --docker-password=DefinitelyNotMyRealPassword \
    --docker-email=not.a.real.email@provider.com; done
```

Since we have applications in multiple namespaces, we'll want to do the second, even though this is a slight pain in the butt later if and when we need to rotate credentials.

Once that has completed, you'll want to add the following lines to each of the affected Deployments, StatefulSets, DaemonSets:

```yaml
spec:
    template:
        spec:
            imagePullSecrets:
            - name: regcred
```

As you go through and add this to each manifest, the cluster should start to recover little by little, until we're back up operational!

## Conclusions

Here are some things you may want to consider; I know I will in the future.

* Avoid shutting down your whole cluster in your homelab. Issues like these may not have reared their heads had I been able to reboot nodes one or two at a time. In this scenario, it couldn't be avoided. Big sad.

* Start getting used to using `imagePullSecrets` in your manifests. Better to have it and not need it than run into limitations with where the container hosting location.

* Have a plan to rotate your Docker Hub credentials. Needing to scramble and figure it out the moment you need it isn't great.

* Ensure that you have backup locations for your images. Right now, most everyone uses Docker Hub. With the restrictions on unauthenticated image pulls as of November 2020, it may be worth looking into either self-hosting a container registry or using something like [Amazon's ECR Public Gallery](https://gallery.ecr.aws/), [Google Cloud's google-containers](https://console.cloud.google.com/gcr/images/google-containers/GLOBAL?pli=1), or the [Red Hat Ecosystem Catalog](https://catalog.redhat.com/software/containers/explore), none of which (_currently_) impose artifical limitations on unauthenticated image pulls or the number of pulls per-hour as far as I know. 
