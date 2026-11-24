# ApinOS

ApinOS is an experimental Debian-based desktop Linux distribution. It uses Debian's Linux kernel and XFCE desktop, with Rust reserved for ApinOS-authored utilities and services.

## Project status

Early development. The repository contains a Debian Live Build configuration, an XFCE live session, a Brave Browser installation hook, and a small Rust system-information utility. The ISO has not yet been built or tested in a VM or on physical hardware.

## Desktop goals

- Debian 13 (Trixie), x86_64
- XFCE graphical desktop
- Brave Browser and XFCE Terminal as the primary user applications
- LightDM autologin for the live session user `apin`
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

The script configures and builds a hybrid live ISO. Brave is installed from its official APT repository during the chroot hook. The resulting ISO is expected under `build/` after a successful build. This configuration has not yet been validated by an actual ISO build.

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
