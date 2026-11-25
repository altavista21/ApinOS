#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
LOG_FILE="${BUILD_DIR}/live-build.log"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

for tool in lb debootstrap xorriso dpkg awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "Missing required tool: ${tool}" >&2
    exit 1
  fi
done

mkdir -p "${BUILD_DIR}"
cd "${ROOT_DIR}"

# Keep a durable, timestamped log so a timed-out CI run can be diagnosed.
exec > >(tee -a "${LOG_FILE}") 2>&1
log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*"
}
on_error() {
  status=$?
  log "ERROR: command failed at line ${BASH_LINENO[0]} (exit ${status})."
  exit "${status}"
}
trap on_error ERR

log "Starting ApinOS ISO build."
log "Build directory: ${BUILD_DIR}"

# live-build's syslinux helper expects these files inside the target chroot.
ISOLINUX_BIN="$(dpkg -L isolinux | awk '/\/isolinux\.bin$/ { print; exit }')"
VESAMENU_C32="$(dpkg -L syslinux-common | awk '/\/vesamenu\.c32$/ { print; exit }')"
if [[ -z "${ISOLINUX_BIN}" || ! -s "${ISOLINUX_BIN}" ||
      -z "${VESAMENU_C32}" || ! -s "${VESAMENU_C32}" ]]; then
  echo "Required ISOLINUX boot files were not found." >&2
  dpkg -L isolinux syslinux-common | grep -E 'isolinux\.bin|vesamenu\.c32' || true
  exit 1
fi

ISOLINUX_STAGE="${ROOT_DIR}/config/includes.chroot/root/isolinux"
install -d -m 0755 "${ISOLINUX_STAGE}"
install -m 0644 "${ISOLINUX_BIN}" "${ISOLINUX_STAGE}/isolinux.bin"
install -m 0644 "${VESAMENU_C32}" "${ISOLINUX_STAGE}/vesamenu.c32"

# GitHub's contents API does not preserve executable bits.
find config/hooks/normal -maxdepth 1 -type f -name '*.hook.chroot' -exec chmod 0755 {} +

log "Stage 1/2: configure Debian Trixie live-build."
lb config \
  --mode debian \
  --ignore-system-defaults \
  --distribution trixie \
  --initsystem systemd \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer false \
  --security false \
  --archive-areas "main contrib non-free non-free-firmware" \
  --mirror-bootstrap https://deb.debian.org/debian \
  --mirror-chroot https://deb.debian.org/debian \
  --mirror-binary https://deb.debian.org/debian \
  --bootappend-live "boot=live components nocomponents=lightdm,sudo quiet splash console=tty0 console=ttyS0,115200 systemd.log_target=console systemd.show_status=1 username=apin" \
  --iso-application "ApinOS" \
  --iso-volume "APINOS"

log "Stage 2/2: run live-build exactly once. Detailed output follows."
lb build

log "live-build finished. Checking generated ISO."
shopt -s nullglob
images=("${ROOT_DIR}"/*.iso)
if (( ${#images[@]} == 0 )); then
  echo "Build completed but no ISO was found in ${ROOT_DIR}." >&2
  exit 1
fi

install -d "${BUILD_DIR}"
for image in "${images[@]}"; do
  mv -- "${image}" "${BUILD_DIR}/apinos-amd64.iso"
done

test -s "${BUILD_DIR}/apinos-amd64.iso"
log "ISO created successfully: ${BUILD_DIR}/apinos-amd64.iso"
log "ISO size: $(du -h "${BUILD_DIR}/apinos-amd64.iso" | awk '{print $1}')"
