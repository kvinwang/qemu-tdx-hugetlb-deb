# QEMU TDX HugeTLB Debian package

This repository builds Ubuntu Debian packages from Canonical's TDX QEMU source
package and backports the upstream fix for HugeTLB-backed guest memory:

- Base: `1:9.2.1+ds-1ubuntu4+tdx2.0~ppa2` (Ubuntu Plucky TDX PPA)
- Output: `1:9.2.1+ds-1ubuntu4+tdx2.0~ppa2+hugetlb1`
- Upstream fix: QEMU commit `8922a758b29251d9009ec509e7f580b76509ab3d`

The patch makes TDX memory attributes use the real host base-page granularity
instead of asserting that a HugeTLB RAMBlock uses the host base page size.

## Prerequisites

Use Ubuntu 25.04 (Plucky) with the Canonical TDX PPA source entries enabled.
The build script installs the exact source package's build dependencies.

## Build

```bash
./scripts/build.sh
```

Packages and build metadata are copied to `dist/`.

To prepare the Debian source tree without compiling:

```bash
./scripts/prepare-source.sh
```

## Install

```bash
./scripts/install.sh
```

For a minimal host, install only the generated `qemu-system-x86`,
`qemu-system-common`, and any generated dependencies required by APT rather
than every binary package in `dist/`.

## Verification

```bash
qemu-system-x86_64 --version
dpkg-query -W qemu-system-x86
```

A TDX CVM using `memory-backend-file,mem-path=/dev/hugepages` should start
without the `memory_attribute_manager_get_block_size` assertion.
