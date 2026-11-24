# ApinOS

ApinOS is an experimental Debian-based desktop Linux distribution. The project starts with a reproducible live-image configuration and Rust-powered system utilities; it does not replace the Linux kernel.

## Project status

Early development. The repository contains the initial live-build configuration and a small Rust system-information utility. No bootable ISO has been built or hardware-tested yet.

## Target

- x86_64 desktop computers
- Debian 13 (Trixie) base
- XFCE desktop
- Linux kernel supplied by Debian
- Rust for ApinOS-authored utilities and services

## Build a live ISO

Build on a Debian 13 x86_64 host or VM. Building an ISO requires root privileges and a working network connection.

```sh
sudo apt update
sudo apt install -y live-build debootstrap xorriso squashfs-tools
sudo ./scripts/build-iso.sh
```

The generated image is expected under `build/` when the live-build process completes successfully. This has not yet been validated in CI or on physical hardware.

## Build the Rust utility

Install Rust/Cargo, then run:

```sh
cargo build --release --manifest-path apps/apinos-info/Cargo.toml
cargo run --manifest-path apps/apinos-info/Cargo.toml
```

## Repository layout

- `config/`: Debian live-build package selection
- `scripts/`: image build helper
- `apps/apinos-info/`: Rust system-information utility

## License

The repository is licensed under GPL-3.0-or-later. Individual bundled components retain their own licenses.
