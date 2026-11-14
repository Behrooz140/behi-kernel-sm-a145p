# behi kernel — Samsung Galaxy A14 4G (SM-A145P / `a14m`)

**English** | [فارسی](README.fa.md)

![kernel](https://img.shields.io/badge/kernel-6.6.92-blue)
![device](https://img.shields.io/badge/device-SM--A145P-green)
![KernelSU](https://img.shields.io/badge/KernelSU-v3.3.1-orange)
![release](https://img.shields.io/github/v/release/Behrooz140/behi-kernel-sm-a145p?label=release)

A personalised Android 15 GKI kernel (Linux 6.6.92) for the **Samsung Galaxy A14 4G,
exact model SM-A145P** (`a14m`, MediaTek Helio G80 / MT6769V), built for KernelSU
and container workloads such as Droidspaces.

> **Only for SM-A145P.** The Galaxy A14 family has several variants — SM-A145F,
> SM-A145R, SM-A146B, SM-A146P/U and others — with different firmware and module
> ABIs. This kernel is built and verified for SM-A145P only; flashing it on any
> other variant can leave the device unbootable.

The release is a **single boot image**. There are no KernelSU modules, no
`vendor_dlkm` changes and nothing to install inside Android: flash `boot`, reboot,
done.

Current release: **v1.3** —
`6.6.92-android15-8-abA145PXXSDDZH1-4k-behi-v1.3`

---

## Table of contents

- [Device](#device)
- [What you get](#what-you-get)
- [Features](#features)
- [Requirements](#requirements)
- [Install (Odin)](#install-odin)
- [Verify the installation](#verify-the-installation)
- [Rollback](#rollback)
- [CPU clocks](#cpu-clocks)
- [ABI compatibility with stock vendor modules](#abi-compatibility-with-stock-vendor-modules)
- [Releases and versioning](#releases-and-versioning)
- [Building](#building)
- [Repository layout](#repository-layout)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)
- [Disclaimer](#disclaimer)

---

## Device

| Item | Value |
|---|---|
| Model | Samsung Galaxy A14 4G (SM-A145P / `a14m`) |
| SoC | MediaTek Helio G80 (MT6769V) |
| CPU | 2 × Cortex-A75 + 6 × Cortex-A55 |
| Kernel | 6.6.92 GKI, `android15-6.6` |
| Base firmware | `A145PXXSDDZH1` |
| Kernel release string | `6.6.92-android15-8-abA145PXXSDDZH1-4k-behi-v1.3` |
| Boot image | 32 MiB, header v4, AVB hash footer (`SHA256_RSA4096`, AOSP test key) |
| Build variant | KernelSU `v3.3.1` (version `32680`), user build |

The kernel release string keeps the stock base
(`6.6.92-android15-8-abA145PXXSDDZH1-4k`) and appends the personal brand and the
package version. The module ABI stamp (vermagic) is pinned to the **stock** value
so all prebuilt modules under `/vendor` keep loading — only the user-visible
string changed.

## What you get

Each GitHub release contains only:

| Asset | Purpose |
|---|---|
| `A145P-Kernel-vX.Y-boot.img` | 32 MiB boot image, ready to flash |
| `A145P-Kernel-vX.Y-Odin.tar.md5` | The same `boot.img` inside an Odin AP package |
| `SHA256SUMS` | Checksums for every asset |
| `build-info.txt` | Exact toolchain/commit provenance |
| `RELEASE_NOTES.md` | Release notes (also shown on the release page) |

No `.ko` files, no `system` overlays, no module zips. KernelSU support is
compiled into the kernel itself.

## Features

- **KernelSU v3.3.1** (version 32680) built in — use the official KernelSU manager.
- **Namespaces for containers**: SYSVIPC, POSIX message queues, IPC/PID/USER
  namespaces (Droidspaces-ready), TMPFS POSIX ACL and extended attributes.
- **Networking**: CAKE qdisc (SQM / low latency), MACVLAN for containers, TTL/HL
  targets for tethering, `xt_cpu` and `xt_CHECKSUM`, ipset, common netfilter
  matches/targets.
- **Storage / network filesystems**: SquashFS with XZ, LZ4 and ZSTD; NFSv4.2; SMB/CIFS.
- **Hardening**: kernel stack offset randomization.
- **ABI guard in CI**: exported symbol CRCs are compared against the known-good
  v1.0 baseline on every build, so a kernel that would reject stock vendor
  modules cannot be released.
- **Stock CPU clocks** — no overclock, no voltage changes (see below).

## Requirements

- **Unlocked bootloader** (the boot image is signed with a public AOSP test key,
  not a Samsung key; this is accepted on unlocked devices).
- **Odin** (Windows, or Wine on Linux) to flash the AP package.
- Base firmware **`A145PXXSDDZH1`** is recommended. The vermagic is pinned to this
  base; on other firmware revisions the prebuilt `/vendor` modules may report a
  version mismatch.
- KernelSU manager **v3.3.1 or newer** if you want root.
- USB debugging / a working `adb` and `su` for the verification steps.

## Install (Odin)

1. Download `A145P-Kernel-vX.Y-Odin.tar.md5` and (optionally) `SHA256SUMS`.
2. Verify the download:
   ```sh
   sha256sum -c SHA256SUMS
   ```
3. Power the phone off.
4. Enter Download mode: hold **Vol+ and Vol−** while connecting the USB cable.
5. Long-press **Vol+** to accept the download-mode warning.
6. In Odin, put the `.tar.md5` file in the **AP** slot.
7. **Do not** enable *Re-Partition*. Flash and let the phone reboot.

Data is preserved: only the `boot` partition is written. The first boot after
flashing can take a few minutes.

## Verify the installation

```sh
adb shell uname -r
# 6.6.92-android15-8-abA145PXXSDDZH1-4k-behi-v1.3
```

With root:

```sh
su -c 'uname -r; grep . /sys/devices/system/cpu/cpufreq/policy*/cpuinfo_max_freq'
```

Expected CPU limits (stock clocks):

```
/sys/devices/system/cpu/cpufreq/policy0/cpuinfo_max_freq:1800000
/sys/devices/system/cpu/cpufreq/policy6/cpuinfo_max_freq:2000000
```

Check that stock vendor modules loaded (Wi-Fi, GPS, FM, …):

```sh
su -c 'lsmod | wc -l; lsmod | head'
```

## Rollback

Flashing only changes `boot`, so rollback is a normal Odin flash:

- Flash your previous working boot image, or
- Flash the full stock firmware for `A145PXXSDDZH1` (AP + BL + CP + CSC;
  use `HOME_CSC` to keep user data).

There is no module or partition to undo.

## CPU clocks

| Cluster | Max frequency |
|---|---|
| little (6 × Cortex-A55) | 1.8 GHz |
| big (2 × Cortex-A75) | 2.0 GHz |

These are the stock values for the G75 (CPU level 6) OPP table used by the
SM-A145P. The experimental overclock that was tested in v1.4-oc was dropped from
the project and is not part of any release.

## ABI compatibility with stock vendor modules

The device loads hundreds of prebuilt modules from `/vendor` and `/vendor_dlkm`.
With `CONFIG_MODVERSIONS=y`, every exported symbol carries a CRC derived from its
signature; changing the layout of any exported GKI structure changes thousands of
CRCs and makes **all** stock modules fail with
`disagrees about version of symbol module_layout` (this is what broke v1.1).

This project therefore:

- pins `VERMAGIC_STRING` to the exact stock value in
  `kernel-6.6/include/linux/vermagic.h`;
- keeps the release string base identical to stock
  (`6.6.92-android15-8-abA145PXXSDDZH1-4k`) and only appends `-behi-vX.Y`;
- refuses to enable ABI-breaking options (`NF_TABLES*`, `KSM`, `VXLAN`, `IPVLAN`,
  `NF_CONNTRACK_LABELS`, `LRU_GEN`, …);
- runs `scripts/kmi_check.py` against `configs/kmi-baseline-v1.0.txt` on every
  build and fails if any exported CRC differs or disappears.

`CONFIG_MODULE_SIG_PROTECT` is intentionally disabled, matching the behaviour of
the stock vendor build.

## Releases and versioning

Releases are **automatic and public**: every push to `main` builds the kernel and
publishes a GitHub release. The version is derived from `CONFIG_LOCALVERSION`, so
cutting a release means:

1. Bump `CONFIG_LOCALVERSION="-4k-behi-vX.Y"` in:
   - `kernel-6.6/arch/arm64/configs/gki_defconfig`
   - `kernel/kernel_device_modules-6.6/arch/arm64/configs/a14m_defconfig`
2. Commit and push to `main`.

The workflow then derives the tag (`vX.Y`), builds, and publishes the release with
`boot.img`, the Odin package and checksums. If the tag already exists on a
different commit the build fails early, so two different kernels can never share
one version. You can also start a build manually from
**Actions → Build Kernel A145P → Run workflow**.

## Building

### GitHub Actions (supported path)

The workflow is the reference build. It:

1. syncs the AOSP `common-android15-6.6` toolchain and prebuilts;
2. fetches pinned `mkbootimg` and `avbtool` revisions;
3. applies the pinned Droidspaces GKI SYSVIPC kABI patch;
4. sets up KernelSU at a pinned commit;
5. enables the required kernel options and disables ABI breakers;
6. builds with Kleaf/Bazel (`a14m`, `mgk_64_k66`, user mode) and the
   `mt6768_overlay.config`, `o22.config`, `a145p_advanced.config` overlays;
7. verifies the release string, stock vermagic and exported symbol CRCs;
8. produces the boot image (header v4 + AVB) and the Odin package.

A full build takes roughly 35–45 minutes on `ubuntu-latest`.

### Local build (advanced)

The CI steps are the authoritative recipe. A minimal local flow, assuming the
repo is checked out next to a synced AOSP toolchain tree:

```sh
# 1. toolchain + prebuilts (same manifest as CI)
repo init -u https://android.googlesource.com/kernel/manifest -b common-android15-6.6 --depth=1
repo sync -c -j"$(nproc)"

# 2. copy build/, external/, prebuilts/, tools/ into ./kernel/
#    (see the "Set up environment & sync AOSP toolchains" workflow step)

# 3. apply the Droidspaces patch and add KernelSU (pinned commits in build.yml)

# 4. build
cd kernel
export USE_BAZEL_VERSION=6.4.0
export DEVICE_MODULES_DIR=kernel_device_modules-6.6
export BUILD_CONFIG=../out/target/product/a14m/obj/KERNEL_OBJ/build.config
export OUT_DIR=../out/target/product/a14m/obj/KLEAF_OBJ
export DIST_DIR=../out/target/product/a14m/obj/KLEAF_OBJ/dist
export DEFCONFIG_OVERLAYS="mt6768_overlay.config o22.config a145p_advanced.config"
export PROJECT=mgk_64_k66 MODE=user
python3 kernel_device_modules-6.6/scripts/gen_build_config.py \
  --kernel-defconfig mediatek-bazel_defconfig \
  --kernel-defconfig-overlays "mt6768_overlay.config o22.config a145p_advanced.config" \
  -m user -o "$BUILD_CONFIG"
./kernel_device_modules-6.6/build.sh --nokleaf_localversion

# 5. boot image
cd ..
MBOOTIMG=<mkbootimg.py> AVBTOOL=<avbtool.py> \
AVB_KEY=<testkey_rsa4096.pem> AVB_ALGORITHM=SHA256_RSA4096 \
BOOT_PARTITION_SIZE=33554432 \
  bash scripts/build_boot_image.sh "$DIST_DIR/.../Image.gz" boot.img
```

The boot image layout is: 4 KiB boot header v4, gzip kernel, `SEANDROIDENFORCE`,
then an AVB hash footer sized to the 32 MiB `boot` partition.

## Repository layout

| Path | Contents |
|---|---|
| `.github/workflows/build.yml` | Full CI: toolchain, patches, KernelSU, config gates, build, packaging, release |
| `kernel/` | Device kernel modules tree (`kernel_device_modules-6.6`) and the Kleaf/Bazel build entrypoint |
| `kernel-6.6/` | GKI kernel source (Android common kernel 6.6) |
| `configs/kmi-baseline-v1.0.txt` | Known-good exported symbol CRC baseline |
| `configs/stock-a145pxxsddzh1.config` | Reference stock configuration |
| `scripts/kmi_check.py` | ABI gate used by CI |
| `scripts/build_boot_image.sh` | 32 MiB boot image + AVB footer builder |
| `build_kernel.sh` | Small convenience wrapper around the device-tree build |

## Troubleshooting

**Bootloop or black screen after flashing.** Flash the stock firmware (or the
previous working boot image) with Odin. Only `boot` changed, so user data is
intact.

**Wi-Fi / GPS / FM / other hardware missing.** Those drivers are prebuilt modules
from `/vendor`; if they are rejected, the boot image and the firmware base do not
match. Make sure the device runs `A145PXXSDDZH1` and that the boot image comes
from this project's release.

**KernelSU manager says "unsupported".** Use KernelSU manager `v3.3.1` or newer.
The kernel reports KernelSU version `32680`.

**USB serial adapters do not work.** `CONFIG_USB_SERIAL` stays `=m`, exactly like
stock, and the release does not ship `.ko` files. A module-enabled build is
required for those adapters.

## Credits

- [AOSP common kernel](https://android.googlesource.com/kernel/common/) — GKI 6.6 base.
- [KernelSU](https://github.com/tiann/KernelSU) by tiann — kernel-level root.
- [Droidspaces](https://github.com/ravindu644/Droidspaces-OSS) by ravindu644 —
  container support and the GKI SYSVIPC kABI patch.
- Android `mkbootimg` and `avbtool` for image creation and AVB signing.
- Samsung for the stock `A145PXXSDDZH1` firmware and MediaTek for the MT6769V
  vendor modules this kernel stays compatible with.

## Disclaimer

This is an unofficial, personal project. Flashing a custom kernel voids your
warranty and can brick the device if something goes wrong. The boot image is
signed with a public AOSP test key, not a Samsung key. You are responsible for
your own device and data — keep a stock firmware package and a backup at hand.

The kernel source is licensed under GPL-2.0; the rest of the repository is
provided as-is, without warranty of any kind.
