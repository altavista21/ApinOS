# ApinOS

ApinOS is an experimental Debian-based desktop Linux distribution. It uses Debian's Linux kernel and XFCE desktop, with Rust reserved for ApinOS-authored utilities and services.

## Project status

Early development. The repository contains a Debian Live Build configuration, an XFCE live session, a Brave Browser installation hook, and a small Rust system-information utility. The ISO has not yet been built or tested in a VM or on physical hardware.

## Desktop goals

- Debian 13 (Trixie), x86_64
- XFCE graphical desktop
- Brave Browser and XFCE Terminal as the primary user applications
- LightDM login screen for the live session user `apin` (no automatic login)
- Debian-provided Linux kernel and hardware support
- Rust for ApinOS-authored system utilities

XFCE includes its necessary desktop components and settings tools; the goal is to keep the user-facing application set minimal.

## Build a live ISO

Build on a Debian 13 x86_64 host or VM. ISO creation requires root privileges, internet access, and sufficient disk space.

```sh
sudo apt update
sudo apt install -y live-build debootstrap xorriso squashfs-tools
sudo ./scripts/build-iso.sh
```

The script configures and builds a hybrid live ISO. The live session uses the username `apin` and Debian Live's default password `live`; change it immediately with `passwd` after logging in. Automatic LightDM login and the live-config sudo privilege setup are disabled. This is a live-session baseline, not a substitute for protecting a computer against someone with physical access or the ability to boot external media. Brave is installed from its official APT repository during the chroot hook. The resulting ISO is expected under `build/` after a successful build. This configuration has not yet been validated by an actual ISO build.

## Security and validation

- The live ISO build runs directly on the GitHub-hosted Ubuntu VM, not inside a restricted job container. The build explicitly selects Debian mode and Debian Trixie mirrors. A dedicated chroot hook applies updates from Debian's current `trixie-security` suite.
- A weekly scheduled build refreshes Debian package metadata and rebuilds the ISO every Sunday at 03:17 UTC. Manual rebuilds are also available through GitHub Actions. Dependabot checks GitHub Actions and Cargo dependencies weekly and opens update pull requests.
- Trivy scans the repository for vulnerable dependencies, misconfiguration, and exposed secrets, then scans the assembled Debian root filesystem for HIGH and CRITICAL vulnerabilities.
- ClamAV updates its official signatures and scans the unpacked live root filesystem before an ISO artifact can be published.
- A separate QEMU job boots the ISO and checks for the systemd graphical target or LightDM startup. A release is published only after that check succeeds.
- Security scans and the virtual boot test are automated gates, not a certification. Hardware compatibility, Secure Boot, installer behavior, network configuration, and manual desktop interaction still require separate testing.

## Build the Rust utility

Install Rust/Cargo, then run:

```sh
cargo build --release --manifest-path apps/apinos-info/Cargo.toml
cargo run --manifest-path apps/apinos-info/Cargo.toml
```

## Repository layout

- `config/`: Debian live-build packages, hooks, and live-session configuration
- `scripts/`: ISO build helper
- `apps/apinos-info/`: Rust system-information utility

## License

The repository is licensed under GPL-3.0-or-later. Individual bundled components retain their own licenses.
