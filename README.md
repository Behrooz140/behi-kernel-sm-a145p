# behi kernel — Samsung Galaxy A14 4G (SM-A145P / `a14m`)

**English** | [فارسی](README.fa.md)

![kernel](https://img.shields.io/badge/kernel-6.6.144-blue)
![device](https://img.shields.io/badge/device-SM--A145P-green)
![KernelSU](https://img.shields.io/badge/KernelSU-v3.3.1-orange)
![release](https://img.shields.io/github/v/release/Behrooz140/behi-kernel-sm-a145p?label=release)

A personalised Android 15 GKI kernel (Linux 6.6.144) for the **Samsung Galaxy A14 4G,
exact model SM-A145P** (`a14m`, MediaTek Helio G80 / MT6769V), built for KernelSU
and container workloads such as Droidspaces.

> **Only for SM-A145P.** The Galaxy A14 family has several variants — SM-A145F,
> SM-A145R, SM-A146B, SM-A146P/U and others — with different firmware and module
> ABIs. This kernel is built and verified for SM-A145P only; flashing it on any
> other variant can leave the device unbootable.

The release is a **single boot image**. There are no KernelSU modules, no
`vendor_dlkm` changes and nothing to install inside Android: flash `boot`, reboot,
done.

Current release: **v1.6.2** —
`6.6.144-android15-8-abA145PXXUEDZJ2-4k-behi-v1.6.2`

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
| Kernel | 6.6.144 GKI, `android15-6.6` |
| Base firmware | `A145PXXUEDZJ2` |
| Kernel release string | `6.6.144-android15-8-abA145PXXUEDZJ2-4k-behi-v1.6.2` |
| Boot image | 32 MiB, header v4, AVB hash footer (`SHA256_RSA4096`, AOSP test key) |
| Build variant | KernelSU `v3.3.1` (version `32680`), user build |

The kernel release string carries the ACK base it was rebased onto
(`6.6.144-android15-8-abA145PXXUEDZJ2-4k`) and appends the personal brand and the
package version. The module ABI stamp (vermagic) is pinned to the **stock**
firmware value (`6.6.118-android15-8-abA145PXXUEDZJ2-4k`) so all prebuilt modules
under `/vendor` keep loading — only the user-visible string changed.

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
  matches/targets, and IPv6 NAT/masquerade for `--net=nat` containers.
- **Storage / network filesystems**: SquashFS with XZ, LZ4 and ZSTD; NFSv4.2; SMB/CIFS.
- **Hardening**: kernel stack offset randomization.
- **ABI guard in CI**: exported symbol CRCs are compared against the known-good
  v1.0 baseline on every build, so a kernel that would reject stock vendor
  modules cannot be released.
- **Stock CPU clocks** — no overclock, no voltage changes. `scaling_max_freq`
  is pinned to the hardware maximum below 75 C (see [CPU clocks](#cpu-clocks)).
- **Network defaults** — TCP BBR with fq_codel, enabled at build time.

v1.6.2 makes the boot-time scheduler perf tune harmless for ported `system`
images: `sched_pelt_multiplier` is capped at 1 and the global
`sched_util_clamp_min` defaults to and stays at 0. This replaces the
`a34_coolfix` Magisk module. KMI/vermagic and `scaling_min_freq` behaviour are
unchanged.

v1.6.1 fixes two small issues on top of v1.6: the MTK `mtktsflash`
(USB/flash thermistor) zone no longer reports the bogus 125 C ADC saturation
value to sysfs and `vbus_ctrl` (so the spurious 70 C charging cutoff no longer
trips). `scaling_max_freq` is now pinned to the hardware maximum while the CPU
is below 75 C — the MTK ATM/PPM adaptive limit otherwise makes it oscillate at
53-63 C — while above 75 C normal thermal mitigation is untouched. The kernel
also defaults to TCP BBR and fq_codel. Both fixes live in the built-in GKI
kernel because the MediaTek drivers are prebuilt `/vendor` modules. The KMI
baseline is unchanged. `scaling_min_freq` is deliberately left alone, so the
stock Input Booster touch boost still works.

v1.6 rebases the kernel onto the newer ACK release — Linux 6.6.144
(`android15-6.6.144_r00`), firmware `A145PXXUEDZJ2` — with the same feature set as
v1.5. The vermagic stamp stays pinned to the stock 6.6.118 value so the prebuilt
`/vendor` modules keep loading.

v1.5 rebases the kernel onto the newer stock base — Linux 6.6.118, firmware
`A145PXXUEDZJ2` — so the custom boot image matches the latest firmware and its
prebuilt `/vendor` modules, with the same feature set as v1.4.

v1.4 adds IPv6 NAT (`CONFIG_IP6_NF_NAT`,
`CONFIG_IP6_NF_TARGET_MASQUERADE`) to the Droidspaces feature set: `--net=nat`
containers now get NAT over IPv6 as well as IPv4. The remaining two optional
items, `--cpus` (cgroup v2 `cpu.max`, needs `CONFIG_CFS_BANDWIDTH`) and
`--pids-limit` (`pids.max`, needs `CONFIG_CGROUP_PIDS`), **cannot be enabled**
without breaking the stock `/vendor` module ABI; Droidspaces simply skips them.
See the ABI section below for the exact reason.

## Requirements

- **Unlocked bootloader** (the boot image is signed with a public AOSP test key,
  not a Samsung key; this is accepted on unlocked devices).
- **Odin** (Windows, or Wine on Linux) to flash the AP package.
- Base firmware **`A145PXXUEDZJ2`** is recommended. The vermagic is pinned to this
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
# 6.6.144-android15-8-abA145PXXUEDZJ2-4k-behi-v1.6.1
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

Verify the v1.6.1 fixes:

```sh
# Bogus 125 C flash thermistor reading is filtered (expect 25000)
su -c 'for z in /sys/class/thermal/thermal_zone*; do \
  [ "$(cat $z/type)" = mtktsflash ] && cat $z/temp; done'

# Charging control sees the sanitized value (expect "mtktsusb = 25")
su -c 'dmesg | grep update_usb_connector_state | tail -1'

# max frequency stays pinned below 75 C (2 minutes, expect no dips)
su -c 'for i in $(seq 1 120); do \
  printf "%s %s %s\n" "$(date +%T)" \
  "$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq)" \
  "$(cat /sys/devices/system/cpu/cpufreq/policy6/scaling_max_freq)"; sleep 1; done'

# Network defaults
su -c 'sysctl net.ipv4.tcp_congestion_control net.core.default_qdisc'
# net.ipv4.tcp_congestion_control = bbr
# net.core.default_qdisc = fq_codel
```

Check that stock vendor modules loaded (Wi-Fi, GPS, FM, …):

```sh
su -c 'lsmod | wc -l; lsmod | head'
```

## Rollback

Flashing only changes `boot`, so rollback is a normal Odin flash:

- Flash your previous working boot image, or
- Flash the full stock firmware for `A145PXXUEDZJ2` (AP + BL + CP + CSC;
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

Below 75 C in the `mtktscpu` thermal zone, `scaling_max_freq` is clamped to
`cpuinfo.max_freq` in the GKI cpufreq core. MediaTek's ATM cooler still requests
adaptive power limits around 53-63 C, but they no longer reach sysfs — so the
maximum stays at 1.8/2.0 GHz instead of oscillating. Above 75 C the clamp is
removed and normal thermal throttling applies. `scaling_min_freq` is **not**
clamped: the stock Input Booster touch boost may still raise it for a moment.

## ABI compatibility with stock vendor modules

The device loads hundreds of prebuilt modules from `/vendor` and `/vendor_dlkm`.
With `CONFIG_MODVERSIONS=y`, every exported symbol carries a CRC derived from its
signature; changing the layout of any exported GKI structure changes thousands of
CRCs and makes **all** stock modules fail with
`disagrees about version of symbol module_layout` (this is what broke v1.1).

This project therefore:

- pins `VERMAGIC_STRING` to the exact stock value in
  `kernel-6.6/include/linux/vermagic.h`;
- keeps the firmware part of the release string
  (`android15-8-abA145PXXUEDZJ2-4k`) and only appends `-behi-vX.Y`;
- refuses to enable ABI-breaking options (`NF_TABLES*`, `KSM`, `VXLAN`, `IPVLAN`,
  `NF_CONNTRACK_LABELS`, `LRU_GEN`, `CFS_BANDWIDTH`, `CGROUP_PIDS`, …);
- runs `scripts/kmi_check.py` against `configs/kmi-baseline-v1.6.2.txt` on every
  build and fails if any exported CRC differs or disappears. The v1.6.2
  baseline is an unchanged copy of v1.6.1, which is the v1.6 one with the ACK
  6.6.118 -> 6.6.144 delta's non-ABI changes pre-applied; none of them is part
  of the GKI ABI.

### Why `--cpus` and `--pids-limit` are not supported

Both need cgroup v2 controllers that change structures visible to exported GKI
symbols:

- `CONFIG_CFS_BANDWIDTH` adds fields to `struct rq` / `struct cfs_rq`
  (`kernel/sched/sched.h`), so the CRCs of the exported `set_next_entity` and
  `update_misfit_status` change.
- `CONFIG_CGROUP_PIDS` adds `pids_cgrp_id` to `enum cgroup_subsys_id`, which
  increments `CGROUP_SUBSYS_COUNT`; the `struct css_set` arrays embedded in
  `struct task_struct` grow, which changed **5853** exported CRCs when it was
  tried in v1.4.

Neither option can be enabled without risking the stock `/vendor` modules, so
the CI gate rejects them and Droidspaces skips the corresponding flags. IPv6 NAT
does not touch any exported structure and is safe.

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
| `configs/kmi-baseline-v1.6.2.txt` | Known-good exported symbol CRC baseline (unchanged from v1.6.1) |
| `configs/stock-a145pxxuedzj2.config` | Reference stock configuration |
| `scripts/kmi_check.py` | ABI gate used by CI |
| `scripts/build_boot_image.sh` | 32 MiB boot image + AVB footer builder |
| `build_kernel.sh` | Small convenience wrapper around the device-tree build |

## Troubleshooting

**Bootloop or black screen after flashing.** Flash the stock firmware (or the
previous working boot image) with Odin. Only `boot` changed, so user data is
intact.

**Wi-Fi / GPS / FM / other hardware missing.** Those drivers are prebuilt modules
from `/vendor`; if they are rejected, the boot image and the firmware base do not
match. Make sure the device runs `A145PXXUEDZJ2` and that the boot image comes
from this project's release.

**`scaling_max_freq` sometimes dips.** Below 75 C it should stay at 1.8/2.0 GHz
even when the log shows `set_adaptive_cpu_power_limit` at 53-63 C — that is the
MediaTek ATM cooler requesting a limit that the GKI clamp now ignores. If the
`mtktscpu` zone reads 75 C or above, throttling is expected and intentional.

**Thermal zone reports 125 C for `mtktsflash`.** That is the raw vendor module
reading; it is expected in `dmesg`, but sysfs and `vbus_ctrl` see `25000`
instead, so charging is no longer cut off at a bogus 70 C.

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
- Samsung for the stock `A145PXXUEDZJ2` firmware and MediaTek for the MT6769V
  vendor modules this kernel stays compatible with.

## Disclaimer

This is an unofficial, personal project. Flashing a custom kernel voids your
warranty and can brick the device if something goes wrong. The boot image is
signed with a public AOSP test key, not a Samsung key. You are responsible for
your own device and data — keep a stock firmware package and a backup at hand.

The kernel source is licensed under GPL-2.0; the rest of the repository is
provided as-is, without warranty of any kind.
