ARG APLINE_VERSION=3.24
ARG DOCKER_VERSION=29.7.2
ARG NODE_VERSION=26.7.0
ARG UV_VERSION=0.12.3
ARG PI_VERSION=0.84.2

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM node:${NODE_VERSION}-alpine${APLINE_VERSION} AS node
FROM docker:${DOCKER_VERSION}-cli-alpine${APLINE_VERSION}

USER root

COPY --from=node /usr/local/ /usr/local/
COPY --from=uv /uv /uvx /bin/

COPY entrypoint.docker.sh /usr/local/bin/entrypoint.docker.sh
RUN chmod +x /usr/local/bin/entrypoint.docker.sh

RUN set -eux \
  && apk add --no-cache \
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
    wget \
    pipx

ARG PI_VERSION
RUN npm install --global "@earendil-works/pi-coding-agent@${PI_VERSION}" \
  && npm install --global @devcontainers/cli \
  && npm cache clean --force

RUN git clone https://github.com/morch1/dev-scripts.git /opt/dev-scripts \
  && chmod +x /opt/dev-scripts/scripts/* \
  && ln -s /opt/dev-scripts/scripts/* /usr/local/bin/

ENV USERNAME=pi
ENV UID=1000
ENV GID=1000
ENV TERM=xterm-256color
ENV HOME=/home/${USERNAME}
ENV UV_LINK_MODE=copy

RUN set -eux \
  && addgroup -g "${GID}" "${USERNAME}" \
  && adduser -D -u "${UID}" -G "${USERNAME}" -s /bin/bash "${USERNAME}" \
  && mkdir -p "${HOME}/.vscode-server" "/vscode" \
  && chown -R "${USERNAME}:${USERNAME}" "${HOME}" \
  && chown -R root:root /vscode \
  && getent group docker &>/dev/null && adduser "${USERNAME}" docker || true

CMD ["sleep", "infinity"]
