#!/usr/bin/env bash
set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly IMAGE="qemu-tdx-hugetlb-deb-verify"

docker build -t "${IMAGE}" -f - "${ROOT_DIR}" <<'EOF'
FROM ubuntu:25.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY dist/ /packages/
RUN apt-get update && apt-get install -y --no-install-recommends \
    /packages/qemu-system-common_*.deb \
    /packages/qemu-system-data_*.deb \
    /packages/qemu-system-x86_*.deb
RUN test "$(dpkg-query -W -f='${Version}' qemu-system-x86)" = \
        '1:9.2.1+ds-1ubuntu4+tdx2.0~ppa2+hugetlb1' && \
    qemu-system-x86_64 --version
EOF
