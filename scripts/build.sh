#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_NAME=${IMAGE_NAME:-"morchv/pi-box"}
IMAGE_VERSION=${IMAGE_VERSION:-$(jq -r '.version' "$ROOT_DIR/devcontainers/pi-box/devcontainer-template.json")}

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

echo "Building release version $IMAGE_VERSION"
docker build "${DOCKER_BUILD_ARGS[@]}" -t "$IMAGE_NAME:$IMAGE_VERSION" \
  --build-arg ALPINE_VERSION="$ALPINE_VERSION" \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  --build-arg PYTHON_VERSION="$PYTHON_VERSION" \
  --build-arg PI_VERSION="$PI_VERSION" \
  "$ROOT_DIR/image"

docker tag "$IMAGE_NAME:$IMAGE_VERSION" "$IMAGE_NAME:latest"
docker tag "$IMAGE_NAME:$IMAGE_VERSION" "$REGISTRY_URL/$IMAGE_NAME:$IMAGE_VERSION"
docker tag "$IMAGE_NAME:$IMAGE_VERSION" "$REGISTRY_URL/$IMAGE_NAME:latest"

if [ "$RELEASE" = true ]; then
  echo "Pushing images to registry..."
  docker push "$REGISTRY_URL/$IMAGE_NAME:$IMAGE_VERSION"
  docker push "$REGISTRY_URL/$IMAGE_NAME:latest"

  echo "Publishing devcontainer templates to registry..."
  devcontainer templates publish -r "$REGISTRY_URL" -n morchv/devcontainers devcontainers
fi
