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

# Ubuntu's live-build syslinux helper expects these bootloader assets under
# /root/isolinux, while Ubuntu packages them in separate system directories.
ISOLINUX_BIN="$(dpkg -L isolinux | awk '/\/isolinux\.bin$/ { print; exit }')"
VESAMENU_C32="$(dpkg -L syslinux-common | awk '/\/vesamenu\.c32$/ { print; exit }')"
if [[ -z "${ISOLINUX_BIN}" || ! -s "${ISOLINUX_BIN}" ||
      -z "${VESAMENU_C32}" || ! -s "${VESAMENU_C32}" ]]; then
  echo "Required ISOLINUX boot files were not found in installed packages." >&2
  dpkg -L isolinux syslinux-common | grep -E 'isolinux\.bin|vesamenu\.c32' || true
  exit 1
fi
install -d -m 0755 /root/isolinux
install -m 0644 "${ISOLINUX_BIN}" /root/isolinux/isolinux.bin
install -m 0644 "${VESAMENU_C32}" /root/isolinux/vesamenu.c32

# GitHub's contents API cannot preserve executable bits, so mark hooks executable here.
find config/hooks/normal -maxdepth 1 -type f -name '*.hook.chroot' -exec chmod 0755 {} +

# Ubuntu's packaged live-build may request Debian Contents indexes from the
# suite root. Debian publishes these indexes under each component (main/).
# Patch every live-build helper that constructs a suite-level Contents URL,
# including the binary Debian Installer helper.
for helper in /usr/lib/live/build/lb_*; do
  [[ -f "${helper}" ]] || continue
  sed -i \
    -e 's|/dists/${LB_PARENT_DISTRIBUTION}/Contents-|/dists/${LB_PARENT_DISTRIBUTION}/main/Contents-|g' \
    -e 's|/dists/${LB_DISTRIBUTION}/Contents-|/dists/${LB_DISTRIBUTION}/main/Contents-|g' \
    -e 's|/dists/${LB_DEBIAN_INSTALLER_DISTRIBUTION}/Contents-|/dists/${LB_DEBIAN_INSTALLER_DISTRIBUTION}/main/Contents-|g' \
    "${helper}"
done

if grep -R -Fq '/dists/${LB_PARENT_DISTRIBUTION}/Contents-' /usr/lib/live/build/lb_* ||
   grep -R -Fq '/dists/${LB_DISTRIBUTION}/Contents-' /usr/lib/live/build/lb_* ||
   grep -R -Fq '/dists/${LB_DEBIAN_INSTALLER_DISTRIBUTION}/Contents-' /usr/lib/live/build/lb_*; then
  echo "Could not correct all live-build Contents index paths." >&2
  exit 1
fi

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
