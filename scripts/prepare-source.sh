#!/usr/bin/env bash
set -euo pipefail

readonly SOURCE_VERSION="${SOURCE_VERSION:-1:9.2.1+ds-1ubuntu4+tdx2.0~ppa2}"
readonly PACKAGE_VERSION="${PACKAGE_VERSION:-1:9.2.1+ds-1ubuntu4+tdx2.0~ppa2+hugetlb1}"
readonly DIST="${DIST:-plucky}"
readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly WORK_DIR="${WORK_DIR:-${ROOT_DIR}/work}"

mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"
rm -rf qemu-*/
if [[ -n "${SOURCE_DSC:-}" ]]; then
    if [[ "${SOURCE_DSC}" =~ ^https?:// ]]; then
        dget --allow-unauthenticated "${SOURCE_DSC}" >&2
        source_dsc="${WORK_DIR}/$(basename "${SOURCE_DSC}")"
    else
        source_dsc="$(realpath "${SOURCE_DSC}")"
    fi
    dpkg-source -x "${source_dsc}" >&2
else
    apt-get source "qemu=${SOURCE_VERSION}" >&2
fi
source_dir="$(find . -maxdepth 1 -type d -name 'qemu-*' -print -quit)"
test -n "${source_dir}"

install -m 0644 "${ROOT_DIR}/patches/hugetlb-memory-attributes.patch" \
    "${source_dir}/debian/patches/hugetlb-memory-attributes.patch"
grep -qxF hugetlb-memory-attributes.patch "${source_dir}/debian/patches/series" || \
    printf '%s\n' hugetlb-memory-attributes.patch >> "${source_dir}/debian/patches/series"

cd "${source_dir}"
QUILT_PATCHES=debian/patches quilt push -a >&2
DEBEMAIL="${DEBEMAIL:-build@localhost}" \
DEBFULLNAME="${DEBFULLNAME:-QEMU TDX HugeTLB Builder}" \
dch --newversion "${PACKAGE_VERSION}" --distribution "${DIST}" \
    "Backport upstream HugeTLB memory-attribute manager fix." >&2
printf '%s\n' "$(pwd)"
