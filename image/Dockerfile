ARG ALPINE_VERSION=3.24
ARG NODE_VERSION=26.5.0
ARG PYTHON_VERSION=3.14.6
ARG UV_VERSION=0.12.3
ARG PI_VERSION=0.84.1

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS node
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

COPY --from=node /usr/local/ /usr/local/
COPY --from=uv /uv /uvx /bin/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

ARG DEV_USER=dev
ARG DEV_UID=1000
ARG DEV_GID=1000

RUN addgroup -g "${DEV_GID}" "${DEV_USER}" \
  && adduser -D -u "${DEV_UID}" -G "${DEV_USER}" -s /bin/bash "${DEV_USER}" \
  && mkdir -p "/home/${DEV_USER}/.vscode-server" \
  && chown "${DEV_USER}:${DEV_USER}" "/home/${DEV_USER}/.vscode-server"

ARG PI_VERSION
RUN set -eux && \
  apk add --no-cache \
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
    vim \
  && npm install --global --omit=dev "@earendil-works/pi-coding-agent@${PI_VERSION}" \
  && npm cache clean --force

USER ${DEV_USER}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["pi"]
