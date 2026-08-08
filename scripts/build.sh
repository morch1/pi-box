#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

REGISTRY_URL=${REGISTRY_URL:-"gitea.home.morch.al"}
ALPINE_VERSION=${ALPINE_VERSION:-"3.24"}
NODE_VERSION=${NODE_VERSION:-"26.5.0"}
PYTHON_VERSION=${PYTHON_VERSION:-"3.14.6"}
PI_VERSION=${PI_VERSION:-"0.84.1"}

RELEASE=false
REBUILD=false
for arg in "$@"; do
  case $arg in
    --release)
      RELEASE=true
      ;;
    --rebuild)
      REBUILD=true
      ;;
  esac
done

DOCKER_BUILD_ARGS=()
if [ "$REBUILD" = true ]; then
  DOCKER_BUILD_ARGS+=(--no-cache)
fi

VERSION=$(jq -r '.version' "$ROOT_DIR/devcontainers/pi-box/devcontainer-template.json")

echo "Building release version $VERSION"
docker build "${DOCKER_BUILD_ARGS[@]}" -t morchv/pi-box:"$VERSION" \
  --build-arg ALPINE_VERSION="$ALPINE_VERSION" \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  --build-arg PYTHON_VERSION="$PYTHON_VERSION" \
  --build-arg PI_VERSION="$PI_VERSION" \
  "$ROOT_DIR/pi-box"

docker tag morchv/pi-box:"$VERSION" morchv/pi-box:latest
docker tag morchv/pi-box:"$VERSION" "$REGISTRY_URL/morchv/pi-box:$VERSION"
docker tag morchv/pi-box:"$VERSION" "$REGISTRY_URL/morchv/pi-box:latest"

docker build "${DOCKER_BUILD_ARGS[@]}" -t morchv/pi-box-paseo:"$VERSION" \
  --build-arg PI_BOX_VERSION="$VERSION" \
  "$ROOT_DIR/pi-box-paseo"
docker tag morchv/pi-box-paseo:"$VERSION" morchv/pi-box-paseo:latest
docker tag morchv/pi-box-paseo:"$VERSION" "$REGISTRY_URL/morchv/pi-box-paseo:$VERSION"
docker tag morchv/pi-box-paseo:"$VERSION" "$REGISTRY_URL/morchv/pi-box-paseo:latest"

if [ "$RELEASE" = true ]; then
  echo "Pushing images to registry..."
  docker push "$REGISTRY_URL/morchv/pi-box:$VERSION"
  docker push "$REGISTRY_URL/morchv/pi-box:latest"

  docker push "$REGISTRY_URL/morchv/pi-box-paseo:$VERSION"
  docker push "$REGISTRY_URL/morchv/pi-box-paseo:latest"

  echo "Publishing devcontainer templates to registry..."
  devcontainer templates publish -r "$REGISTRY_URL" -n morchv/devcontainers devcontainers
fi
