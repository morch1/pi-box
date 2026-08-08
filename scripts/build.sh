#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

REGISTRY_URL=${REGISTRY_URL:-"gitea.home.morch.al"}
ALPINE_VERSION=${ALPINE_VERSION:-"3.24"}
NODE_VERSION=${NODE_VERSION:-"26.5.0"}
PYTHON_VERSION=${PYTHON_VERSION:-"3.14.6"}
PI_VERSION=${PI_VERSION:-"0.84.1"}

RELEASE=false
for arg in "$@"; do
  case $arg in
    --release)
      RELEASE=true
      ;;
  esac
done

VERSION=$(jq -r '.version' "$ROOT_DIR/devcontainers/pi-box/devcontainer-template.json")

echo "Building release version $VERSION"
docker build -t morchv/pi-box:"$VERSION" \
  --build-arg ALPINE_VERSION="$ALPINE_VERSION" \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  --build-arg PYTHON_VERSION="$PYTHON_VERSION" \
  --build-arg PI_VERSION="$PI_VERSION" \
  "$ROOT_DIR/pi-box"

docker tag morchv/pi-box:"$VERSION" morchv/pi-box:latest
docker tag morchv/pi-box:"$VERSION" "$REGISTRY_URL/morchv/pi-box:$VERSION"
docker tag morchv/pi-box:"$VERSION" "$REGISTRY_URL/morchv/pi-box:latest"

docker build -t morchv/pi-box-webui:"$VERSION" \
  --build-arg PI_BOX_VERSION="$VERSION" \
  "$ROOT_DIR/pi-box-webui"
docker tag morchv/pi-box-webui:"$VERSION" morchv/pi-box-webui:latest
docker tag morchv/pi-box-webui:"$VERSION" "$REGISTRY_URL/morchv/pi-box-webui:$VERSION"
docker tag morchv/pi-box-webui:"$VERSION" "$REGISTRY_URL/morchv/pi-box-webui:latest"

if [ "$RELEASE" = true ]; then
  echo "Pushing images to registry..."
  docker push "$REGISTRY_URL/morchv/pi-box:$VERSION"
  docker push "$REGISTRY_URL/morchv/pi-box:latest"

  echo "Publishing devcontainer templates to registry..."
  devcontainer templates publish -r "$REGISTRY_URL" -n morchv/devcontainers devcontainers
fi
