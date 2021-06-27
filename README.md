# danmanners-dot-com - Personal Website

This repo is used to store all of the code for my personal website. I build it using a GitHub action which builds it with Docker buildx for several different CPU architectures and pushes the completed container to Docker Hub.

## Building

The container can be built by running `docker build .` simply.

If you want to build and push it up to Docker Hub, run these commands:

```shell
docker build -t danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD)
docker push danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD)
```

If you want to run the build for multiple CPU architectures, you can use [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/). That build command will look like this:

```shell
docker buildx build --no-cache \
    --platform linux/amd64,linux/arm64 \
    -t danielmanners/danmanners-dot-com:$(git rev-parse --short HEAD) \
    --push .
```

## Links

- Theme: [luizdepra/hugo-coder](https://github.com/luizdepra/hugo-coder)
