ARG ALPINE_VERSION=latest
ARG NODE_VERSION=latest
ARG PYTHON_VERSION=latest
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS node
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

COPY --from=node /usr/local/ /usr/local/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

ARG PI_VERSION=latest
ARG DEV_USER=dev
ARG DEV_UID=1000
ARG DEV_GID=1000

RUN apk add --no-cache \
    nss_wrapper \
    bash \
    curl \
    ca-certificates \
    fd \
    git \
    libstdc++ \
    openssh-client \
    ripgrep \
    jq \
    build-base \
  && npm install --global --omit=dev "@earendil-works/pi-coding-agent@${PI_VERSION}" \
  && npm cache clean --force \
  && addgroup -g "${DEV_GID}" "${DEV_USER}" \
  && adduser -D -u "${DEV_UID}" -G "${DEV_USER}" -s /bin/bash "${DEV_USER}" \
  && mkdir -p "/home/${DEV_USER}/.vscode-server" \
  && chown "${DEV_USER}:${DEV_USER}" "/home/${DEV_USER}/.vscode-server"

USER ${DEV_USER}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["pi"]
