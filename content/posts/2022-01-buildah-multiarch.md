+++ 
draft = false
date = 2022-01-08T17:06:44-05:00
title = "Building Multi-Architecture Containers with Buildah"
slug = "2022-01-buildah-multi-arch"
tags = ['kubernetes','kube','arm64','arm','multi-architecture','buildah','containers','container','podman']
categories = ['Kubernetes','Containers','Multi-Architecture','Buildah','Podman']
+++

For a while now, I've been wanting to move away from [Docker](https://www.docker.com/) as a container runtime on my systems, where possible. All of my K3s hosts are utilizing [containerd](https://containerd.io/) as their runtime, and I've migrated my work and personal systems over to [podman](https://podman.io/). The one area I've been having issues with the entire [Containers stack](https://github.com/containers) is with multi-architecture container building and pushing to a container registry.

With Docker, it's very easy with `docker buildx` to build multi-architecture containers. Unfortunately, `podman`/`buildah` do not make it as easy, so here's what you'll want/need to do!

## Linux Requirements

Besides the obvious requirements of `podman` and `buildah`, you will require the `qemu-user-static` package on Debian/Ubuntu/RHEL, and `qemu-arch-extra` if you're running on Arch or Manjaro. Simply put, this will allow you to run interpreters that allow QEMU to virtualize non-native architectures, like `arm/v7` and `aarch64`/`arm64`.

### Debian/Ubuntu

```bash
sudo apt install -y podman buildah qemu-user-static
```

### RHEL Flavors

```bash
sudo yum install -y podman buildah qemu-user-static
```

### Arch/Manjaro

```bash
sudo pacman -Sy podman buildah qemu-arch-extra
```

## Building your multi-architecture containers

Building a single container for a different architecture than the hardware you're building it on isn't too hard, and there are a number of pretty good guides available. **HOWEVER**, there definitely seems to be a gap when you're talking about using `podman`/`buildah` and not `docker buildx` to build multi-architecture images.

With `docker buildx`, here's what a normal multi-architecture build command might look like:

```bash
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag ghcr.io/danmanners/isbonnierecording-backend \
    --push backend
```

Very clean, very easy to understand what's going on, and it'll build both images in parallel, which speeds up the time it takes to build your images. While it is not nearly as clean with `podman`/`buildah`, here's what you'll want/need to do.

```bash
# Set your manifest name
export MANIFEST_NAME="multiarch-test"

# Set the required variables
export BUILD_PATH="backend"
export REGISTRY="ghcr.io"
export USER="danmanners"
export IMAGE_NAME="isbonnierecording-backend"
export IMAGE_TAG="v0.1.1"

# Create a multi-architecture manifest
buildah manifest create ${MANIFEST_NAME}

# Build your amd64 architecture container
buildah bud \
    --tag "${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --manifest ${MANIFEST_NAME} \
    --arch amd64 \
    ${BUILD_PATH}

# Build your arm64 architecture container
buildah bud \
    --tag "${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --manifest ${MANIFEST_NAME} \
    --arch arm64 \
    ${BUILD_PATH}

# Push the full manifest, with both CPU Architectures
buildah manifest push --all \
    ${MANIFEST_NAME} \
    "docker://${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}"
```

The three (main) things that you should care about above are:

- `--manifest` / Manifest
    - The name of the manifest you'll be adding your container multi-architecture images to
- `--arch` / Architecture
    - The architecture of the container image you want to build
- The `docker://` in front of the image name
    - This is simply specifying that we want to push the manifest using the `docker` transport method.

> If you'd like to read more about the `docker://` transport method and alternatives, [check this page RedHat put together](https://www.redhat.com/sysadmin/7-transports-features).

If you're reasonably well-versed in building container images already, everything else should seem pretty normal to you.

At the end of all of this, your commands should look like this:

```bash
buildah manifest create isbonrecording-backend

buildah bud --tag "ghcr.io/danmanners/isbonrecording-backend:v0.1.1" \
    --manifest isbonrecording-backend \
    --arch amd64 backend

buildah bud --tag "ghcr.io/danmanners/isbonrecording-backend:v0.1.1" 
    --manifest isbonrecording-backend 
    --arch arm64 backend

buildah manifest push --all 
    isbonrecording-backend \
    "docker://ghcr.io/danmanners/isbonrecording-backend:v0.1.1"
```

For the example above, utilizing `ghcr.io` will also require logging into the GitHub Container Registry. I'd recommend creating and utilizing a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for access, and storing it at `~/.github/token` on your developer system, with `0400` permissions. Assuming you've done this, you can simply log in with podman by running:

```bash
# Set your GitHub Username, or just replace the variable below with it.
export YOUR_GITHUB_USERNAME="danmanners"

# cat the token, and then use it with the `--password-stdin` arg with `podman login`
cat ~/.github/token | podman login ghcr.io --username $YOUR_GITHUB_USERNAME --password-stdin
```

## Final Thoughts

`buildah` is significantly less streamlined compared to `docker buildx` for building and pushing multi-architecture container images, no doubt about it. It is, however, entirely functional and with a little bit of learning and understanding, is entirely as capable for both homelabbing and production use.

Happy cross-compiling!

# Questions? Thoughts?

Feel free to ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com). If something I wrote isn't clear, feel free to ask me a question or ask me to update it!
