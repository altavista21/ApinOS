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

# GitHub's contents API cannot preserve executable bits, so mark hooks executable here.
find config/hooks/normal -maxdepth 1 -type f -name '*.hook.chroot' -exec chmod 0755 {} +

# Ubuntu's packaged live-build may request Debian Contents indexes from the
# suite root. Debian publishes these indexes under each component (main/).
KERNEL_HELPER=/usr/lib/live/build/lb_chroot_linux-image
if [[ ! -f "${KERNEL_HELPER}" ]]; then
  echo "Missing live-build kernel helper: ${KERNEL_HELPER}" >&2
  exit 1
fi

sed -i \
  -e 's|/dists/${LB_PARENT_DISTRIBUTION}/Contents-|/dists/${LB_PARENT_DISTRIBUTION}/main/Contents-|g' \
  -e 's|/dists/${LB_DISTRIBUTION}/Contents-|/dists/${LB_DISTRIBUTION}/main/Contents-|g' \
  "${KERNEL_HELPER}"

if grep -Fq '/dists/${LB_PARENT_DISTRIBUTION}/Contents-' "${KERNEL_HELPER}" ||
   grep -Fq '/dists/${LB_DISTRIBUTION}/Contents-' "${KERNEL_HELPER}"; then
  echo "Could not correct the live-build kernel Contents index path." >&2
  exit 1
fi

lb config \
  --mode debian \
  --ignore-system-defaults \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer live \
  --security false \
  --archive-areas "main contrib non-free non-free-firmware" \
  --mirror-bootstrap https://deb.debian.org/debian \
  --mirror-chroot https://deb.debian.org/debian \
  --mirror-binary https://deb.debian.org/debian \
  --bootappend-live "boot=live components nocomponents=lightdm,sudo quiet splash console=tty0 console=ttyS0,115200 systemd.log_target=console systemd.show_status=1 username=apin" \
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
