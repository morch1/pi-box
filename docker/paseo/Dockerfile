ARG PASEO_VERSION=0.3.1
ARG DOCKER_VERSION=29.7.2
ARG UV_VERSION=0.12.3
ARG PI_VERSION=0.84.2

FROM docker:${DOCKER_VERSION}-cli AS docker
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM ghcr.io/getpaseo/paseo:${PASEO_VERSION}

USER root

COPY --from=docker /usr/local/bin/docker /usr/local/bin/
COPY --from=uv /uv /uvx /bin/

RUN set -eux \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
      build-essential \
      fd-find \
      jq \
      pipx \
      ripgrep \
      vim \
      wget \
  && rm -rf /var/lib/apt/lists/*

ARG PI_VERSION
RUN npm install --global --omit=dev \
    @earendil-works/pi-coding-agent@${PI_VERSION} \
    @devcontainers/cli \
  && npm cache clean --force

RUN git clone https://github.com/morch1/dev-scripts.git /opt/dev-scripts \
  && chmod +x /opt/dev-scripts/scripts/* \
  && ln -s /opt/dev-scripts/scripts/* /usr/local/bin/
