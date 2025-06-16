ARG ALPINE_VER="3.22"

FROM alpine:${ALPINE_VER}

ARG NGINX_VER="1.28"

ARG REPOSITORY
ARG BUILD_TIME

LABEL base-maintainer="stefan@teneff.com"
LABEL base-repository=$REPOSITORY
LABEL base-build-time=$BUILD_TIME

USER root

RUN apk update && apk add --no-cache \
        envsubst \
        nginx=~$NGINX_VER \
        nginx-mod-http-auth-jwt=~$NGINX_VER \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /var/cache/nginx/ \
    && mkdir -p /var/run/nginx/ \
    && mkdir -p /var/lib/nginx/ \
    && mkdir -p /docker-entrypoint.d/ \
    #   Set nginx folder permissions
    && chown -R daemon:root /var/run/nginx/ \
    && chown -R daemon:root /var/cache/nginx \
    && chmod -R g+w /var/cache/nginx \
    && chmod -R g+w /etc/nginx/http.d \
    && chown -R daemon:root /var/lib/nginx/ \
    && chown -R daemon:root /etc/nginx/http.d \
    && chown -R daemon:root /docker-entrypoint.d/ \
    #   Remove user directive
    && sed '/^user.*/d' -i /etc/nginx/nginx.conf \
    #   Change pid location
    && sed -i 's,\(/var/run/\),\1nginx/,' /etc/nginx/nginx.conf \
    #   include modules
    && sed -i 's,\(pid.*\),\1\ninclude modules/*.conf;\n,' /etc/nginx/nginx.conf \
    #   Set listen port to 8080
    && sed 's,\(listen\s*\)80,\18080,g' -i /etc/nginx/http.d/default.conf \
    #   Redirect nginx logs to sdtout and stderr
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY docker-entrypoint.sh /
COPY 10-envsubst-on-templates.sh /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]

USER nginx

EXPOSE 8080/tcp

# Run nginx interactively
CMD ["nginx", "-g", "daemon off;"]
