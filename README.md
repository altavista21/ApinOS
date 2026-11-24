# ApinOS

ApinOS is an experimental, Debian-based Linux desktop operating system designed to provide a simple and familiar graphical environment. It is built on Debian 13 (Trixie), uses the XFCE desktop, and keeps its default application set intentionally small.

The main desktop experience centers on the XFCE Terminal and Brave Browser. ApinOS also includes useful command-line tools for system monitoring and everyday administration.

> **Project status:** ApinOS is under active development. The live-build configuration is maintained in this repository, but installation instructions and hardware compatibility must be considered preliminary until a release ISO has passed the project's virtual-machine and physical-hardware tests. Do not use an unverified build on a computer containing important data.

## What Is Included

- **Base system:** Debian 13 (Trixie), 64-bit (AMD64)
- **Desktop:** XFCE
- **Display manager:** LightDM
- **Web browser:** Brave Browser
- **Terminal:** XFCE Terminal
- **Network:** NetworkManager
- **Command-line tools:** Git, curl, btop, and neowofetch
- **System utilities:** A small ApinOS system-information utility written in Rust
- **Kernel and firmware:** Debian-provided Linux kernel and selected firmware packages

XFCE includes the desktop components and settings tools needed for a usable graphical session. ApinOS aims to avoid unnecessary preinstalled applications while allowing users to add the software they need.

## Installation

### 1. Get an ApinOS ISO

Download an ISO from the project's GitHub Releases page when a tested release is available:

[ApinOS Releases](https://github.com/altavista21/ApinOS/releases)

A successful automated build is not, by itself, a stable release or a guarantee of compatibility with every computer. Check the release notes and checksum before using an ISO. If no tested ISO is published, the project is not ready for a normal installation yet.

### 2. Create a bootable USB drive

You will need:

- A USB flash drive (8 GB or larger recommended)
- A separate computer that can write an ISO image to the USB drive
- A backup of any files on the USB drive, because creating bootable media erases its contents

Use a trusted image-writing tool such as [Rufus](https://rufus.ie/) on Windows or [balenaEtcher](https://etcher.balena.io/) on Windows, macOS, or Linux.

1. Connect the USB flash drive.
2. Open the image-writing tool.
3. Select the ApinOS ISO.
4. Select the correct USB drive.
5. Start writing and wait for the process to finish.

Double-check the selected drive before writing. Choosing the wrong drive can erase your data.

### 3. Boot from the USB drive

1. Insert the bootable USB drive into the target computer.
2. Restart the computer.
3. Open its one-time boot menu or firmware setup screen. The key varies by manufacturer and is often F12, F9, F8, Esc, or Del.
4. Select the USB drive.
5. Choose the available ApinOS live or installer option.

You may need to change the firmware boot order. Secure Boot compatibility has not yet been confirmed, so a test machine may require Secure Boot to be disabled. Change firmware security settings only if you understand the implications.

### 4. Try the live environment or install ApinOS

If the ISO provides a live desktop option, start it first to check whether the display, keyboard, touchpad, storage, and network work correctly.

If the ISO provides a Debian installer option, follow the installer's instructions. Review the disk and partition selections carefully before confirming any changes. Installing an operating system can erase existing data.

After installation, remove the USB drive and restart the computer.

**Important:** The installer flow, partitioning behavior, bootloader setup, and post-install login have not been confirmed until a release ISO completes end-to-end installation testing. Treat these steps as a guide to the intended process, not as a claim that installation is already verified.

## Using ApinOS

### The XFCE desktop

After starting the graphical session, you can use the XFCE desktop to launch applications, manage windows, browse files, and adjust system settings.

- **Applications menu:** Open the desktop menu to find installed applications and system tools.
- **Brave Browser:** Use Brave for web browsing.
- **XFCE Terminal:** Open the terminal to run commands and manage software.
- **Thunar:** Use the file manager to browse files and folders.
- **NetworkManager:** Connect to wired or wireless networks using the desktop network controls.

### Terminal basics

Open **XFCE Terminal** from the Applications menu. These commands are useful for everyday tasks:

| Command | Purpose |
| --- | --- |
| `pwd` | Show the current directory |
| `ls` | List files and folders |
| `cd folder-name` | Change directories |
| `mkdir folder-name` | Create a directory |
| `cp source destination` | Copy files |
| `mv source destination` | Move or rename files |
| `rm file-name` | Delete a file |
| `clear` | Clear the terminal screen |
| `btop` | View system resource usage |
| `neowofetch` | Display system information |
| `git --version` | Check the installed Git version |
| `curl --version` | Check the installed curl version |

Be careful with commands that delete files, especially when used with `sudo` or as the root user.

### Live-session account

The development live image is configured to use the username `apin`. The current configuration documents the Debian Live default password, `live`, for this temporary session. Change the password immediately after logging in:

```sh
passwd
```

A live session runs from the boot media and is not the same as a normal installed system. Files saved in a live session may be lost after shutdown unless persistence is configured. Do not assume that live-session credentials or privileges are the same as those on an installed system.

## Installing Software

ApinOS uses Debian's APT package manager. You can install software from the terminal when the computer has an internet connection and your account has administrative privileges.

### 1. Refresh the package list

Run this before installing software:

```sh
sudo apt update
```

### 2. Install a package

For example, to install VLC:

```sh
sudo apt install vlc
```

Replace `vlc` with the Debian package name you want to install. You can install more than one package in a single command:

```sh
sudo apt install package-one package-two
```

### 3. Find a package

Search the package repositories with:

```sh
apt search package-name
```

To view details about a package:

```sh
apt show package-name
```

Only install software from repositories and vendors you trust. Check the publisher and source before adding third-party repositories or downloading installer files.

### 4. Install a downloaded Debian package

If a trusted vendor provides a `.deb` file, open a terminal in the download folder and run:

```sh
sudo apt install ./package-file.deb
```

APT can resolve dependencies from your configured repositories. Do not install unknown `.deb` files.

## Removing Software

### Remove an application but keep its configuration

```sh
sudo apt remove package-name
```

### Remove an application and its system configuration files

```sh
sudo apt purge package-name
```

### Remove unused dependencies

After removing software, you can clean up packages that are no longer needed:

```sh
sudo apt autoremove
```

Review the packages APT proposes to remove before confirming. Do not remove desktop, networking, kernel, or system packages unless you understand what depends on them.

### Upgrade installed software

To install available package updates:

```sh
sudo apt update
sudo apt upgrade
```

Restart the computer if an update replaces important system components such as the kernel or core services.

### Administrative access

The commands above use `sudo), which requires an account with administrator privileges. If your account does not have those privileges, do not try to bypass the restriction. Sign in with an authorized administrator account or ask the system administrator to perform the installation.

## Building ApinOS from Source

ApinOS uses Debian Live Build to create its live ISO. Build from a Debian 13 (Trixie) AMD64 host or virtual machine with an internet connection and sufficient free disk space.

Install the build dependencies:

```sh
sudo apt update
sudo apt install -y live-build debootstrap xorriso squashfs-tools
```

Clone the repository and build:

```sh
git clone https://github.com/altavista21/ApinOS.git
cd ApinOS
sudo ./scripts/build-iso.sh
```

The build script configures the Debian live system and runs the ISO build. After a successful build, the expected output is:

```text
build/apinos-amd64.iso
```

The build requires root privileges. Run it in a disposable virtual machine if you are experimenting with the build configuration.

## Security and Testing

The project includes automated checks intended to improve build quality:

- GitHub Actions builds the ISO and refreshes package metadata on a weekly schedule.
- Dependabot checks GitHub Actions and Cargo dependencies for available updates.
- Trivy scans source files and configuration for vulnerabilities, misconfigurations, and exposed secrets.
- ClamAV scans the assembled live filesystem for known malware signatures.
- Trivy checks Debian packages in the assembled root filesystem for HIGH and CRITICAL vulnerabilities.
- QEMU attempts to boot the ISO and checks for the graphical system target or LightDM startup.
- A prerelease is published only after the required build, scan, and virtual boot jobs pass.

These checks reduce risk but do not prove that an operating system is completely secure. They do not replace code review, manual installation testing, hardware compatibility testing, network testing, Secure Boot testing, or a full review of the installed system.

## Repository Structure

- `config/` — Debian Live Build configuration, package lists, and hooks
- `scripts/` — ISO build scripts
- `apps/apinos-info/` — Rust-based ApinOS system-information utility
- `.github/workflows/` — Automated build, scanning, and virtual boot workflow

## License

ApinOS is licensed under **GPL-3.0-or-later**. Individual bundled components remain subject to their respective licenses.
