+++ 
draft = false
date = 2022-08-29T17:42:50-04:00
title = "Tekton and Building Multi-Architecture Containers on Native Hardware"
slug = "2022-08-tekton-cicd-multiarch-builds" 
tags = ['tekton','kubernetes','cicd','ci','cd','automation','containers','buildah','skopeo']
categories = ['Kubernetes','Containers']
+++

## Overview

My initial goal was not to "build a container with multi-architecture support." My goal was to build a container with multiple architectures **on native hardware**. There are [a number](https://hub.tekton.dev/tekton/task/buildah) of [examples you can find online](https://vikaspogu.dev/posts/tekton-multiarch-buildx/) with either Buildah or Docker-in-Docker you can build multi-arch containers, but they all depend on QEMU architecture emulation.

That is not in and of itself a _bad thing_, but it's also not always an option for any number of reasons. Similarly, performance on QEMU-based architecture virtualization is, simply put, poor. Building individual containers on the appropriate and dedicated native hardware will _almost_ always be a better experience, _and_ I wanted to see if I could do it simultaneously.

Herein lies the problem: How in the **_hell_** do you build multi-architecture containers on _multiple dedicated nodes simultaneously_, and where do you _start_ with a challenge like that??

## Software, Links, and the Kitchen Sink

Before we dive into things, I want to drop links to everything we'll be talking about. If you're not familiar with the majority of these tools, this might be a difficult read.

- [Tekton](https://tekton.dev/) - Cloud Native CI/CD
- [Buildah](https://buildah.io/) - Tool which builds [OCI-compliant images](https://opencontainers.org/)
- [Skopeo](https://github.com/containers/skopeo) - CLI tool which performs various operations on container images and image repositories

## Where to Start

First, we want to define our end goals and understand the design challenges at hand.

While the process may not be simple, our goals are.

- Want to build multi-architecture container manifests on dedicated hardware
  - `arm64` on Raspberry Pi / AWS Graviton
  - `amd64` on Intel or AMD based hardware
- Need to push a single manifest to ensure that a single `$image:$tag` will work for both `amd64` and `arm64` hardware.
  - If a single manifest is not pushed, you can't "fix it" after the push up to the container registry.
- Need to ensure that there's network-accessible storage for sharing binaries/container blobs
  - `emptyDir` volumes won't work when we're talking about running tasks on _multiple_ Kubernetes nodes.

That all seems do-able, _or so I thought_.

## General Approach

My initial logic on what the workflow was going to look like was similar to this:

<center>
  <img
  src="/static/images/posts/2022-08-tekton/TektonWorkFlowStarting.png"
  width="70%" alt="Tekton - Initial Workflow Idea" style="margin: 0px 30px">
</center>

In human readable terms, we need to:

1. Clone our target git repository
2. Create our `buildah` manifest file
3. Simultaneously, build our `arm64` container on local Raspberry Pi hardware, and our `amd64` container on Intel/AMD hardware.
4. Once _all_ container builds have succeeded, add all container images to the manifest
5. Push up our single manifest to our container registry

This genuinely seems like it'll be easy enough...right?

## Problem #1 - Persistent Volumes with Buildah

With Tekton, instead of "volumes" at the task level, you have what are called "workspaces." These **can** be persistent volumes, but they can also be configMaps, secrets, or a few other things. In our case, we're using on-demand created PVC's. However, when we run the `buildah` command and try to use the build directory on either NFS or Rook-Ceph, we see the output look something like this:

```bash
[1/2] STEP 1/7: FROM docker.io/library/node:16-alpine AS build
Trying to pull docker.io/library/node:16-alpine...
Getting image source signatures
Copying blob sha256:bc5d1f30ff35820a8309dab94ab1217b88767dcaba316cca98e870a714949147
Copying blob sha256:c93f3de25c33c85b37a128ed6f5def4e6e6942da5c7555d8226016911ae6445b
Copying blob sha256:213ec9aee27d8be045c6a92b7eac22c9a64b44558193775a1a7f626352392b49
Copying blob sha256:015fad1872e163f80d6826bce31432abd8365d6d22f611198d0f679cbded70a4
Copying blob sha256:c93f3de25c33c85b37a128ed6f5def4e6e6942da5c7555d8226016911ae6445b
Copying blob sha256:bc5d1f30ff35820a8309dab94ab1217b88767dcaba316cca98e870a714949147
Copying blob sha256:015fad1872e163f80d6826bce31432abd8365d6d22f611198d0f679cbded70a4
Copying blob sha256:213ec9aee27d8be045c6a92b7eac22c9a64b44558193775a1a7f626352392b49
Copying config sha256:b1ca7421d2e7d436770d67014df781f5d19587a4842e0db5b5d846cb46e113b2
Writing manifest to image destination
Storing signatures
[1/2] STEP 2/7: WORKDIR /opt/node_app
[1/2] STEP 3/7: COPY package.json yarn.lock ./
[1/2] STEP 4/7: RUN yarn --ignore-optional
/bin/sh: yarn: Not supported
subprocess exited with status 127
subprocess exited with status 127
error building at STEP "RUN yarn --ignore-optional": exit status 127
[2/2] STEP 1/3: FROM docker.io/nginxinc/nginx-unprivileged:1.23.1
Trying to pull docker.io/nginxinc/nginx-unprivileged:1.23.1...

Step failed
```

Digging into the logs, we can find this:

```bash
time="2022-08-15T03:02:17Z" level=error msg="'overlay' is not supported over nfs at \"/workspace/containers/storage/overlay\""
kernel does not support overlay fs: 'overlay' is not supported over nfs at "/workspace/containers/storage/overlay": backing file system is unsupported for this graph driver
time="2022-08-15T03:02:17Z" level=warning msg="failed to shutdown storage: \"kernel does not support overlay fs: 'overlay' is not supported over nfs at \\\"/workspace/containers/storage/overlay\\\": backing file system is unsupported for this graph driver\""
```

Well...can't use the `overlay` storage driver over either NFS or Rook-Ceph volumes. That complicates things.

## Problem #2 - Copying Container Binaries Fails...Gloriously

Okay, well if we can't use NFS or Rook-Ceph for underlying shared storage to build the containers on, _maybe_ we can build the container and then copy the files to our shared persistent storage?

Buildah, by default, uses `/var/lib/containers/storage` as the location it stores container builds. So, we can try copying all of the files in that directory to our `${persistentVolume}/storage` location and see if we can reference the image.

When we run `buildah images` after building the container on the ephemeral container volume, we see that this example image comes out to **~1.16 GB**.

```bash
[root@buildah-troubleshooter /]# buildah images
REPOSITORY                    TAG       IMAGE ID        CREATED         SIZE
ghcr.io/danmanners/memegen    0.12.0    3bacefa76535    29 hours ago    1.16 GB
```

However, after trying to copy the files over to our persistent share, if we run the same command with the root of the storage volume, we see that the image is only **110 bytes**, which is obviously not correct.

I tried several things, checked damn near every directory on the filesystem to see if there was something I was missing to no avail.

## Solution: Utilizing Skopeo to its Fullest

Eventually, I realized I may be able to utilize Skopeo to create a tarballed `oci-archive` file and write it to our shared persistent storage volume. This looks something like this:

```bash
# Build Container
buildah bud ...

# After the image has been built, use Skopeo to create the `oci-archive`
skopeo copy \
  containers-storage:ghcr.io/danmanners/memegen:0.12.0 \
  oci-archive:${WORKSPACE_PATH}/oci-archives/container-${ARCH}.tar \
  --dest-compress
```

This seemed to work! Then, on the other side we can create our final manifest, _decompress_ each of our architecture `oci-archive` tarballs, then add them to the newly created manifest, and push it all up as one. The logic here looks something similar to this:

```bash
# Create our new manifest
buildah manifest create containers

# Loop through all of the files in our OCI-Archive Directory
for ociContainer in $(find ${WORKSPACE_PATH}/oci-archives/ -type f -printf "%f\n"); do

  # Define the filename with .tar.gz
  export containerName="`echo ${ociContainer} | sed 's/\.tar\.gz//g'`"

  # Untar the archive
  skopeo copy \
    oci-archive:${WORKSPACE_PATH}/oci-archives/${ociContainer} \
    containers-storage:$containerName

  # Add the newly untarred container to our manifest
  buildah manifest add containers $containerName
done

# Finally, push the manifest up to our container registry
buildah manifest push \
  docker://ghcr.io/danmanners/memegen:v0.12.0 --all
```

## CI/CD Workflow at the end of this

Our final workflow was a little different than our initially described, but not radically so!

<center>
  <img
  src="/static/images/posts/2022-08-tekton/TektonWorkFlowFinal.png"
  width="70%" alt="Tekton - Initial Workflow Idea" style="margin: 0px 30px">
</center>

Instead of 5 steps, we were able to combine it down to 3 "beefier" steps:

1. Clone our target git repository
2. Simultaneously, build our `arm64` container on local Raspberry Pi hardware, and our `amd64` container on Intel/AMD hardware, and use `skopeo` to create an archive on the shared volume
3. Create the manifest, Decompress all container archives, add them to the manifest, push it up to our container registry

## Final Thoughts

This sucked to get working, and the practicality is limited at best. However, this goes to show how absolutely flexible that Tekton can be. Out of all of the "Cloud Native" CI/CD platforms and toolings I've played with in any capacity, Tekton is the _only_ tool that seems to do things well, and consistently so. The flexibility of the tool and the ability to create new tasks that fit your exact use case is incredible, and I am thrilled to see that it's matured the way it has.

## Resources / References

- [GitHub - Tekton Memegen Pipeline](https://github.com/danmanners/homelab-kube-cluster/blob/c0aa16bce56e9f4e82917b2834a264c3d9781e38/manifests/tekton/pipe/memegen.yaml)
- [GitHub - danmanners/tekton-tasks](https://github.com/danmanners/tekton-tasks)

-----

If something I wrote isn't clear, feel free to ask me a question or ask me to update it! You can ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com), or tweet me [@damnanners](https://twitter.com/DamNanners).
