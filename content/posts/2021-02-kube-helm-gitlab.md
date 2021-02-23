+++ 
draft = false
date = 2021-02-22T22:15:34-05:00
title = "Gitlab on Kubernetes with Helm"
slug = "2021-02-22-kube-helm-gitlab" 
tags = ['networking','kubernetes','gitlab','longhorn','storage']
categories = ['Kubernetes','Helm','Gitlab','Longhorn']
+++

<center>
<img src="/static/images/posts/kube-helm-gitlab/00.png#center" width="100%">
</center>

Gitlab on Kubernetes is complicated as hell.

The total line count of the actual helm package is roughly ~50.1k lines, and the values file you should feed in and the prep before installing everything is incredibly complicated. Among the dozens and dozens of Helm charts I've ever deployed personally or professionally, this is up there in complexity.

Imagine my surprise when other than the official docs I didn't find much in the way of guides or recommendations if you're not running in an enterprise-grade on-prem or cloud environment. So, what I'll aim to do both in my [public repository](https://github.com/danmanners/RKE-Learning-2/tree/master/Gitlab) and here is to run through some of the complications I ran into very quickly as well as the solutions.

-----

## Problem 1 - Persistent Storage

In order for Gitlab to successfully deploy, you'll need persistent storage and the ability to generate `persistentvolumes` from `persitentvolumeclaims` resources.

If you're running in a homelab environment, this might be a challenge initially. Persistent storage on Kubernetes isn't nearly as easy as it should be, and there are an incredibly high number of things that can go wrong.

## Solution 1 - Longhorn or Rook-Ceph

While I've deployed both Rook-Ceph and Longhorn, my experience so far has been that Longhorn is the significantly more easily accessible persistent storage option. I'm actively working on a guide for getting it up and going in your RKE environment from virtual machine creation to having an operational RKE Cluster with Longhorn up and going, so keep an eye out if you're interested!

## Problem 2 - Using external certs, and not the bundled 'cert-manager'

While the Gitlab Helm comes packaged with `cert-manager`, which does work just fine, you may want to generate or serve your own certificates generated elsewhere. The docs are a bit confusing, and getting it all working was a pain in the butt.

## Solution 2 - Adding many additional lines to your 'values.yaml' file

There were several lines that needed to be added specifically in order to get this all working. [I have it in my repo here](https://github.com/danmanners/RKE-Learning-2/blob/master/Gitlab/gitlab.yaml#L471), or you can check it out below:

```yaml
...
        # CUSTOM - Required for separately managed certmanager
        registry:
          ingress:
            tls:
              secretName: gitlab-registry-tls
        # CUSTOM - Required for separately managed certmanager
        minio:
          ingress:
            tls:
              secretName: gitlab-minio-tls
        # CUSTOM - Required for separately managed certmanager
        gitlab:
          gitlab-pages:
            ingress:
              tls:
                secretName: gitlab-pages-tls
          webservice:
            ingress:
              path: 
              tls:
                secretName: gitlab-webservice-tls
...
```

Each of those secrets should be in the `gitlab` namespace and exist as the type `kubernetes.io/tls` with `tls.crt` and `tls.key` key:values. If those are there, you should be good to go.

If you're having your existing cert-manager installation generate the certs, you can create them like this:

```yaml
---
### GitLab Registry
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: gitlab-registry-tls
  namespace: gitlab
spec:
  commonName: registry.<domain>
  secretName: gitlab-registry-tls
  dnsNames:
    - registry.<domain>
  issuerRef:
    name: acme-prod
    kind: ClusterIssuer
---
### GitLab Minio
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: gitlab-minio-tls
  namespace: gitlab
spec:
  commonName: minio.<domain>
  secretName: gitlab-minio-tls
  dnsNames:
    - minio.<domain>
  issuerRef:
    name: acme-prod
    kind: ClusterIssuer
---
### GitLab Pages Wildcard
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: gitlab-pages-tls
  namespace: gitlab
spec:
  commonName: "*.gitlab.<domain>"
  secretName: gitlab-pages-tls
  dnsNames:
    - "*.gitlab.<domain>"
  issuerRef:
    name: acme-prod
    kind: ClusterIssuer
---
### GitLab Webservice
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: gitlab-webservice-tls
  namespace: gitlab
spec:
  commonName: gitlab.<domain>
  secretName: gitlab-webservice-tls
  dnsNames:
    - gitlab.<domain>
  issuerRef:
    name: acme-prod
    kind: ClusterIssuer
```

## Problem 3 - Many missing secret and config volumes

After I launched the helm chart, I realized that none of the pods were actually mounting. When looking at pod errors, almost all of them were complaining about missing secret volumeMounts. It seemed weird to me that none of the secrets had been automatically created.

## Solution 3 - Creating all of the secrets and config files

[Had I seen or read this README doc first](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/642b773db8d63db80bd5c42f3555508a89e2fdd0/doc/installation/secrets.md), I would have known to create a ton of secrets. Unfortunately, I didn't see it and I spent a lot of time troubleshooting something that I just missed.

In any case, here are the commands you'll need to run:

```bash
# Create the Gitlab Shell Hostkeys
mkdir -p hostKeys
ssh-keygen -t rsa  -f hostKeys/ssh_host_rsa_key -N ""
ssh-keygen -t dsa  -f hostKeys/ssh_host_dsa_key -N ""
ssh-keygen -t ecdsa  -f hostKeys/ssh_host_ecdsa_key -N ""
ssh-keygen -t ed25519  -f hostKeys/ssh_host_ed25519_key -N ""

# Upload the files
kubectl -n gitlab create secret generic gitlab-gitlab-shell-host-keys \
    --from-file hostKeys

# Create the gitlab-issuser certs
mkdir -p certs
openssl req -new -newkey rsa:4096 -subj "/CN=gitlab-issuer" \
    -nodes -x509 -keyout certs/registry-certs.key \
    -out certs/registry-certs.crt

# Create the registry-secrets
kubectl -n gitlab create secret generic gitlab-registry-secret \
    --from-file=registry-auth.key=certs/registry-certs.key \
    --from-file=registry-auth.crt=certs/registry-certs.crt

# Load in the LetsEncrypt CA Files
curl -s https://letsencrypt.org/certs/isrgrootx1.pem https://letsencrypt.org/certs/lets-encrypt-r3.pem > certs/le-chain.pem
kubectl -n gitlab create secret generic gitlab-wildcard-tls-ca \
    --from-file=custom-ca-certificates=certs/le-chain.pem

# Initial Root Password
kubectl -n gitlab create secret generic gitlab-gitlab-initial-root-password \
    --from-literal=password=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 32)

# Redis Password
kubectl -n gitlab create secret generic gitlab-redis-secret \
    --from-literal=secret=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64)

# GitLab Shell Secret
kubectl -n gitlab create secret generic gitlab-gitlab-shell-secret \
    --from-literal=secret=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64)

# Gitaly Secret
kubectl -n gitlab create secret generic gitlab-gitaly-secret \
    --from-literal=token=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64)

# Praefect Secret
kubectl -n gitlab create secret generic gitlab-praefect-secret \
    --from-literal=token=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64)

# GitLab Rails
cat << EOF > secrets.yml
production:
  secret_key_base: $(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 128)
  otp_key_base: $(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 128)
  db_key_base: $(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 128)
  encrypted_settings_key_base: $(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 128)
  openid_connect_signing_key: |
$(openssl genrsa 2048 | awk '{print "    " $0}')
  ci_jwt_signing_key: |
$(openssl genrsa 2048 | awk '{print "    " $0}')
EOF

kubectl -n gitlab create secret generic gitlab-rails-secret \
    --from-file=secrets.yml

# GitLab Workhorse
kubectl -n gitlab create secret generic gitlab-gitlab-workhorse-secret \
    --from-literal=shared_secret=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 32 | base64)

# GitLab Runner
kubectl -n gitlab create secret generic gitlab-gitlab-runner-secret \
    --from-literal=runner-registration-token=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64) \
    --from-literal=runner-token="5oTLJS47SrUAuL5Lznc1DL0IwzcqbHLkq9PLwi0xdJ0PiVSjjq0M9js5tmMwOysn"

kubectl -n gitlab create secret generic gitlab-gitlab-runner-secret \
    --from-literal=runner-registration-token=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64) \
    --from-literal=runner-token="5oTLJS47SrUAuL5Lznc1DL0IwzcqbHLkq9PLwi0xdJ0PiVSjjq0M9js5tmMwOysn"

# GitLab Registry HTTP Secret
kubectl -n gitlab create secret generic gitlab-registry-httpsecret \
    --from-literal=secret=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64) 

# GitLab KAS Secret
kubectl -n gitlab create secret generic gitlab-gitlab-kas-secret \
    --from-literal=kas_shared_secret=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 32 | base64)

# Minio Secret
kubectl -n gitlab create secret generic gitlab-minio-secret \
    --from-literal=accesskey=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 20) \
    --from-literal=secretkey=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64)

# Postgres Password
kubectl -n gitlab create secret generic gitlab-postgresql-password \
    --from-literal=postgresql-password=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64) \
    --from-literal=postgresql-postgres-password=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64)

# GitLab Pages Secret
kubectl -n gitlab create secret generic gitlab-gitlab-pages-secret \
    --from-literal=shared_secret=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 32 | base64)

# Registry HTTP Secret
kubectl -n gitlab create secret generic gitlab-registry-httpsecret \
    --from-literal=secret=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64 | base64)

# Praefect DB Password
kubectl -n gitlab create secret generic gitlab-praefect-dbsecret \
    --from-literal=secret=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 64)
```

Once everything there is done, you should be good to go to kill the pods that aren't starting and let them pull all the new secrets and configs.

## Problem 4 - Don't want to use the bundled NGINX ingress controller

If you're anything like me, you're already running an ingress controller in your cluster. Personally I'm using [Traefik](https://traefik.io/), though you might be using [Ambassador](https://www.getambassador.io/) or [Kong](https://konghq.com/solutions/kubernetes-ingress/). If this is the case, you can create your own ingress resources like this:

```yaml
---
# Example for HTTPS Ingress
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: gitlab
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`gitlab.<domain>`) && PathPrefix(`/admin/sidekiq`)
      kind: Rule
      services:
        - name: gitlab-webservice-default
          port: 8080
    - match: Host(`gitlab.<domain>`)
      kind: Rule
      services:
        - name: gitlab-webservice-default
          port: 8181
  tls:
    secretName: gitlab-webservice-tls
---
# Example for TCP Router Ingress
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRouteTCP
metadata:
  name: gitlab-ssh
  namespace: gitlab
spec:
  entryPoints:
    - ssh
  routes:
    - match: HostSNI(`*`)
      kind: Rule
      services:
        - name: gitlab-gitlab-shell
          port: 22
```

However, even if you tell the chart to [disable the ingress](https://github.com/danmanners/RKE-Learning-2/blob/master/Gitlab/gitlab.yaml#L49), it still creates the resources.

<center>
<img src="/static/images/posts/kube-helm-gitlab/03.png#center">
</center>

## Solution 4 - Haven't found a solution yet

Sorry, haven't figured this one out yet. It doesn't _break_ anything per-se, but it's annoying that in ArgoCD the resources are just permanently in a `Progressing` state and are not valid.

<center>
<img src="/static/images/posts/kube-helm-gitlab/02.png#center">
</center>

Hopefully this is solvable and I'm just missing something obvious!

-----

# Questions? Thoughts?

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or tell me to update it!
