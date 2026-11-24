#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script with sudo: sudo $0" >&2
  exit 1
fi

for tool in lb debootstrap xorriso; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "Missing required tool: ${tool}. Install live-build, debootstrap, and xorriso." >&2
    exit 1
  fi
done

mkdir -p "${BUILD_DIR}"
cd "${ROOT_DIR}"

# GitHub's contents API cannot preserve executable bits, so mark the hook executable here.
chmod 0755 config/hooks/normal/010-install-brave.hook.chroot

lb config \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer live \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components quiet splash username=apin" \
  --iso-application "ApinOS" \
  --iso-volume "APINOS"

lb build

shopt -s nullglob
images=("${ROOT_DIR}"/*.iso)
if (( ${#images[@]} == 0 )); then
  echo "Build finished but no ISO was found in ${ROOT_DIR}. Check live-build output." >&2
  exit 1
fi

for image in "${images[@]}"; do
  mv -- "${image}" "${BUILD_DIR}/apinos-amd64.iso"
done

echo "ApinOS ISO output: ${BUILD_DIR}/"
