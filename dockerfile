ARG HUGODIR="/opt/danmanners-dot-com"

# Set up Hugo in Alpine to build the source
FROM alpine:3.14 as hugo_build
ARG HUGODIR
RUN apk add hugo --no-cache \
    && mkdir -p ${HUGODIR}

COPY content ${HUGODIR}/content
COPY resources ${HUGODIR}/resources
COPY static ${HUGODIR}/static
COPY themes ${HUGODIR}/themes
COPY archetypes ${HUGODIR}/archetypes
COPY config.toml ${HUGODIR}/config.toml

WORKDIR ${HUGODIR}
RUN hugo --minify

# Set up NGINX to serve the built Hugo compiled code
FROM nginx:1.21.5-alpine as nginx
ARG HUGODIR
LABEL MAINTAINER="Dan Manners (daniel.a.manners@gmail.com)"
COPY --from=hugo_build ${HUGODIR}/public /usr/share/nginx/html
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
