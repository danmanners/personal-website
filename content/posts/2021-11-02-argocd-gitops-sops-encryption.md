+++ 
draft = true
date = 2021-11-01T21:58:49-04:00
title = "ArgoCD & SOPS"
slug = "2021-11-argocd-gitops-sops-encryption" 
tags = ['gitops','kube','kubernetes','cloud']
categories = ['Kubernetes','GitOps','Encryption']
+++

Long story short: it's not trivial to get your own SOPS encrypted GitOps up and going with ArgoCD, but it's also not extraordinarily difficult. I'd like to share here some thoughts about it all, the challenges I faced, and ultimately how I got it all up and going with some links and resources on what you'll want to do to get it going for yourself.

## Kubernetes GitOps Tooling

When talking about infrastructure There are several ways to do GitOps with Kubernetes, but the big three tools are:

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [FluxCD](https://fluxcd.io)
- [Jenkins X](https://jenkins-x.io)

While they each have their own pros and cons, Today we'll be focusing primarily on ArgoCD.

## ArgoCD / GitOps - A Brief Overview



## Why unencrypted secrets are bad, and why you should avoid them

I mean, I shouldn't have to write this, but standard `base64` isn't encryption; it's an encoding. There's nothing 'secret' about a base64 encoded string. If you store your secrets as a base64 string, then you're asking for trouble. Then again, you need a way to ensure the state of your application, and if you _don't_ have your secrets in your GitOps repo, that means someone has to manually install or manage those secrets. It's a bad situation to be in. So...

## Introducing: Mozilla SOPS

Okay, so we agree that '_encoded_' secrets are bad, and that you can't put them in your code repository.

## Spoiler: You can't just use SOPS

As easy as it'd be to simply install Mozilla SOPS into the ArgoCD container, it 

## Appending to the ArgoCD Container Image

There are two ways to go about getting KSOPS integrated

## Challenges & Troubleshooting



## Resources & Links

- [ArgoCD Docs](https://argo-cd.readthedocs.io/en/stable/)
- [viaduct-ai/kustomize-sops](https://github.com/viaduct-ai/kustomize-sops#argo-cd-integration-)
- [Mozilla SOPS](https://github.com/mozilla/sops)
