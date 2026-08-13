#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mapfile -t packages < <(find "${ROOT_DIR}/dist" -maxdepth 1 -type f -name '*.deb' | sort)
((${#packages[@]} > 0)) || { echo "No packages found in dist/" >&2; exit 1; }
sudo apt-get install -y "${packages[@]}"
