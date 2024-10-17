# Use the latest Nginx image as a base
FROM nginx:1.27.0-alpine AS builder

ENV NGINX_VERSION=1.27.0
ENV CACHE_PURGE_VERSION=2.5.3

# Install dependencies required to build Nginx and the module
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    gettext \
    wget \
    git \
    curl \
    linux-headers

# Download Nginx source and ngx_cache_purge module
RUN wget "http://nginx.org/download/nginx-1.27.0.tar.gz" -O nginx.tar.gz && \
    wget "https://github.com/nginx-modules/ngx_cache_purge/archive/refs/tags/${CACHE_PURGE_VERSION}.tar.gz" -O ngx_cache_purge.tar.gz

# Build NGINX with the ngx_cache_purge module
RUN mkdir -p /usr/src && \
    tar -zxC /usr/src -f nginx.tar.gz && \
    tar -xzC /usr/src -f ngx_cache_purge.tar.gz && \
    cd /usr/src/nginx-1.27.0 && \
    CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p' | sed 's/--with-cc-opt=.*//') && \
    ./configure $CONFARGS --add-dynamic-module=/usr/src/ngx_cache_purge-${CACHE_PURGE_VERSION} --with-compat && \
    make modules

# Create a new image with the compiled module
FROM nginx:1.27.0-alpine

# Install gettext for envsubst
RUN apk add --no-cache gettext

# Copy the built module to the new image
COPY --from=builder /usr/src/nginx-1.27.0/objs/ngx_http_cache_purge_module.so /etc/nginx/modules/ngx_cache_purge_module.so

# Copy the NGINX config template
COPY cache.proxy.server.conf /etc/nginx/nginx.conf.template

# Expose port 80
EXPOSE 80

# Use envsubst to substitute environment variables in nginx.conf
CMD ["/bin/sh", "-c", "envsubst \\$S3_BUCKET_NAME < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"]
