# Alpine 3.22 + Nginx + [nginx-mod-http-auth-jwt][nginx-mod-http-auth-jwt]

The image is intended to serve built (static) js applications with reverse proxy + jwt authorization

## Entrypoint

Executes all the files in `/docker-entrypoint.d`

### 10-envsubst-on-templates

As in the [official nginx docker image][official-docker-image] by default, this function reads template files in `/etc/nginx/templates/*.template` and outputs the result of executing envsubst to `/etc/nginx/http.d`.

## nginx-mod-http-auth-jwt ([docs](https://github.com/kjdev/nginx-auth-jwt))

the plugin allows restrciting locations with OAuth2 with support for jwks

e.g.
```
proxy_cache_path /var/cache/nginx levels=1 keys_zone=foo:10m;

server {
    listen       ${NGINX_PORT};
    server_name  ${SERVER_NAME} www.${SERVER_NAME};

    location / {
        root   /var/www/application;
        try_files $uri /index.html;
    }

    location /api/service1 {
        auth_jwt                             "closed site";
        auth_jwt_key_request                 /jwks_uri;
        proxy_pass                           http://${SERVICE1_HOST};
        proxy_set_header Authorization       ${SERVICE1_AUTH};
        proxy_set_header Host                $http_host;
        proxy_set_header X-Real-IP           $remote_addr;
        proxy_set_header X-Forwarded-For     $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto   $scheme;
        proxy_read_timeout                   ${SERVICE1_TIMEOUT};
    }

    location = /jwks_uri {
        internal;
        proxy_cache foo;
        proxy_pass  ${JWKS_URI};
    }
}
```

[nginx-mod-http-auth-jwt]: https://pkgs.alpinelinux.org/package/edge/main/x86/nginx-mod-http-auth-jwt

[official-docker-image]: https://hub.docker.com/_/nginx