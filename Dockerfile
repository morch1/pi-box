ARG ALPINE_VERSION=3.24
ARG NODE_VERSION=26.5.0
ARG PYTHON_VERSION=3.14.6
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS node
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

COPY --from=node /usr/local/ /usr/local/

ARG PI_VERSION=latest
ARG WORKSPACE=/workspace
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    fd \
    git \
    libstdc++ \
    openssh-client \
    ripgrep \
  && npm install --global --omit=dev "@earendil-works/pi-coding-agent@${PI_VERSION}" \
  && npm cache clean --force \
  && addgroup -g "${USER_GID}" "${USERNAME}" \
  && adduser -D -u "${USER_UID}" -G "${USERNAME}" -s /bin/bash "${USERNAME}" \
  && mkdir -p "/home/${USERNAME}/.pi/agent" "/home/${USERNAME}/.vscode-server" "${WORKSPACE}" \
  && chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}" "${WORKSPACE}"

USER "${USERNAME}"
WORKDIR "${WORKSPACE}"
CMD ["sleep", "infinity"]
