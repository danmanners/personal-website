+++ 
draft = false
date = 2022-01-03T17:41:27-05:00
title = "Kube Endpoints and Reverse-Proxying Non-Kube Services"
slug = "2022-01-kubernetes-endpoint-proxies" 
tags = ['traefik','networking','kubernetes','k3s','homelab']
categories = ['Kubernetes','Networking','cloud','Proxy','ZeroTier']
+++

For a while now, I've been using my hybrid-cloud K3s nodes to reverse proxy into a few services that are **not** running in my Kubernetes cluster. Originally, I planned on proxying the traffic I wanted in NGINX at the edge, but then it would be nearly impossible to pass through to Traefik without a lot of manual work and effort. I ended up doing it in a reasonably hacky way ([See Here](https://github.com/danmanners/homelab-k3s-cluster/blob/9a2f70002ff4b11b5f4ac046851cd15367361344/manifests/workloads/traefik-reverseproxy/reverse-proxy.yaml), [here](https://github.com/danmanners/homelab-k3s-cluster/blob/9a2f70002ff4b11b5f4ac046851cd15367361344/manifests/workloads/traefik-reverseproxy/traefik-mods.yaml#L62), [and here](https://github.com/danmanners/homelab-k3s-cluster/blob/9a2f70002ff4b11b5f4ac046851cd15367361344/manifests/workloads/traefik-reverseproxy/wikijs.yaml#L40)), but decided against that from a maintenance standpoint. Everything I needed to learn to get it working I found on a blog post from [Eleven Labs](https://blog.eleven-labs.com/en/using-traefik-as-a-reverse-proxy/), and then further adapted it into Kubernetes.

Over the 2021-2022 holidays, I stumbled into a [very interesting StackOverflow post](https://stackoverflow.com/questions/57764237/kubernetes-ingress-to-external-service/57769127#57769127). TL;DR: They recommended creating an [Endpoint Object](https://kubernetes.io/docs/concepts/services-networking/service/) and just pointing the addresses to an external IP.

Well...that's kind of a neat idea. Let's see if we can't get it working!

## Migrating over wiki.danmanners.com

Okay, so if I wanted to update things from A to B, it should probably look something like this:

### Original Code

```toml
[http]
    [http.middlewares]
        [http.middlewares.http-https-redirectscheme.redirectScheme]
            scheme = "https"
            permanent = true
    [http.services]
    [http.services.wikijs]
        [http.services.wikijs.loadBalancer]
            [[http.services.wikijs.loadBalancer.servers]]
                url = "http://10.45.0.32:80/"
```

### New Code

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: wikijs
  namespace: kube-system
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  clusterIP: None
  type: ClusterIP
---
apiVersion: v1
kind: Endpoints
metadata:
  name: wikijs
  namespace: kube-system
subsets:
- addresses:
  - ip: 10.45.0.32
  ports:
  - name: http
    port: 80
    protocol: TCP
---
apiVersion: traefik.containo.us/v1alpha1
kind: TraefikService
metadata:
  name: wikijs
  namespace: kube-system
  labels:
    app.kubernetes.io/instance: traefik
spec:
  weighted:
    services:
      - name: wikijs
        passHostHeader: true
        port: 80
        scheme: http
```

> [The Traefik code can be viewed here](https://github.com/danmanners/homelab-k3s-cluster/blob/main/manifests/workloads/traefik-helm/wikijs.yaml)

## Does it work?

Short answer: Yes!

![WikiJS Screenshot](/static/images/posts/2022-01-kubernetes-endpoint-objects/wikijs.png)

Longer answer: It definitely works, and latency from my house, over the internet, and back seems to be pretty consistently under 12ms.

Are there other possible challenges or issues I'm not aware of today? Absolutely. Is there perhaps an even better way to do things? Very well may be! Does this work quite easily, _AND_ allow me to easily manage everything through GitOps? Yes, absolutely.

## Questions? Thoughts?

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or tell me to update it!
