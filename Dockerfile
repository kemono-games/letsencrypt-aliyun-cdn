FROM node:20-alpine AS deps

ADD package.json yarn.lock .yarnrc.yml /srv/

RUN corepack enable
RUN apk update && apk add ca-certificates wget && \
    wget https://github.com/go-acme/lego/releases/download/v4.2.0/lego_v4.2.0_linux_amd64.tar.gz -O /tmp/lego.tar.gz -q && \
    mkdir /tmp/lego && \
    tar zvxf /tmp/lego.tar.gz -C /tmp/lego/ && \
    cp /tmp/lego/lego /srv/lego && \
    chmod +x /srv/lego && \
    cd /srv && \
    yarn workspaces focus --all --production

FROM node:20-alpine AS runner

ENV DOMAINS example.com
ENV EMAIL daxingplay@gmail.com
ENV DNS_TYPE  dnspod
ENV ALICLOUD_ACCESS_KEY foo
ENV ALICLOUD_SECRET_KEY bar
ENV ENDPOINT https://cdn.aliyuncs.com
ENV API_VERSION 2018-05-10

COPY docker/tasks/ /etc/periodic/
COPY . /srv/
COPY --from=deps /srv/node_modules /srv/node_modules
COPY --from=deps /srv/lego /srv/lego

RUN chmod -R +x /etc/periodic/ && \
    chmod +x /srv/docker/start.sh

ENTRYPOINT ["/srv/docker/start.sh"]