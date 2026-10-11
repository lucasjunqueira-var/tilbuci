#!/usr/bin/env bash
#
# Build the TilBuci all-in-one image for multiple architectures.
#
# Usage:
#   ./build.sh                       # build locally (single platform -> --load)
#   PUSH=true ./build.sh             # build amd64+arm64 and push to a registry
#
# Configuration (environment variables):
#   IMAGE      image name, e.g. ghcr.io/<owner>/tilbuci or <user>/tilbuci  (default: tilbuci)
#   TAG        version tag, e.g. 25.0                                       (default: from ./VERSION)
#   LATEST     moving tag                                                   (default: latest)
#   PLATFORMS  target platforms                                             (default: linux/amd64,linux/arm64)
#   PUSH       true to push to a registry                                   (default: false)
#   BUILDER    buildx builder name                                          (default: tilbuci-builder)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMAGE="${IMAGE:-tilbuci}"
if [ -z "${TAG:-}" ]; then
    if [ -f "${SCRIPT_DIR}/VERSION" ]; then
        TAG="$(tr -d '[:space:]' < "${SCRIPT_DIR}/VERSION")"
    else
        TAG="25.0"
    fi
fi
LATEST="${LATEST:-latest}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
PUSH="${PUSH:-false}"
BUILDER="${BUILDER:-tilbuci-builder}"

echo "Building ${IMAGE}:${TAG} and ${IMAGE}:${LATEST}"
echo "Platforms: ${PLATFORMS}    Push: ${PUSH}"

# Ensure a buildx builder with multi-platform support exists.
if ! docker buildx inspect "${BUILDER}" >/dev/null 2>&1; then
    docker buildx create --name "${BUILDER}" --use >/dev/null
else
    docker buildx use "${BUILDER}" >/dev/null
fi
docker buildx inspect --bootstrap >/dev/null

OUTPUT_ARGS=()
if [ "${PUSH}" = "true" ]; then
    OUTPUT_ARGS+=(--push)
else
    case "${PLATFORMS}" in
        *,*)
            echo "NOTE: a multi-platform build without PUSH=true cannot be loaded into the local Docker; it will only build."
            ;;
        *)
            OUTPUT_ARGS+=(--load)
            ;;
    esac
fi

docker buildx build \
    --platform "${PLATFORMS}" \
    --build-arg "TILBUCI_VERSION=${TAG}" \
    -t "${IMAGE}:${TAG}" \
    -t "${IMAGE}:${LATEST}" \
    "${OUTPUT_ARGS[@]}" \
    "${SCRIPT_DIR}"

echo "Done: ${IMAGE}:${TAG} and ${IMAGE}:${LATEST}"
