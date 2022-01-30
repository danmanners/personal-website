# danmanners-dot-com - Personal Website

This repo is used to store all of the code for my personal website. I build it using a GitHub action which builds it with Docker buildx for several different CPU architectures and pushes the completed container to Docker Hub.

## Container Building

While unused today as the website has been migrated to [AWS S3](https://aws.amazon.com/s3/), I'll leave the container building instructions here for posterity's sake.

-----

If you want to build and push it up to Docker Hub, run these commands:

```bash
docker build -t danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD)
docker push danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD)
```

If you want to run the build for multiple CPU architectures, you can use [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/). That build command will look like this:

```bash
docker buildx build --no-cache \
    --platform linux/amd64,linux/arm64 \
    -t danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD) \
    --push .
```

Alternatively, you can use `buildah` to build the multi-architecture containers.

```bash
# Create a multi-architecture manifest
buildah manifest create danmanners-dot-com

# Build your amd64 architecture container
buildah bud \
    --tag "docker.io/danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD)" \
    --manifest danmanners-dot-com \
    --arch amd64 .

# Build your arm64 architecture container
buildah bud \
    --tag "docker.io/danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD)" \
    --manifest danmanners-dot-com \
    --arch arm64 .

# Push the full manifest, with both CPU Architectures
buildah manifest push --all \
    danmanners-dot-com \
    "docker://docker.io/danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD)"
```

## Sources

- Theme: [luizdepra/hugo-coder](https://github.com/luizdepra/hugo-coder)
