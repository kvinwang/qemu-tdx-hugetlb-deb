#!/usr/bin/env bash
set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$(${ROOT_DIR}/scripts/prepare-source.sh)"

if [[ "${INSTALL_BUILD_DEPS:-1}" == "1" ]]; then
    sudo apt-get update
    sudo apt-get build-dep -y "qemu=${SOURCE_VERSION:-1:9.2.1+ds-1ubuntu4+tdx2.0~ppa2}"
fi

cd "${source_dir}"
dpkg-buildpackage --build=binary --no-sign ${DEB_BUILD_OPTIONS:+--jobs="$(nproc)"}
mkdir -p "${ROOT_DIR}/dist"
find .. -maxdepth 1 -type f \( -name '*.deb' -o -name '*.buildinfo' -o -name '*.changes' \) \
    -exec cp -f {} "${ROOT_DIR}/dist/" \;
