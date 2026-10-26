#!/usr/bin/env bash

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
TEST_HOME=$(mktemp -d)
trap 'rm -rf -- "$TEST_HOME"' EXIT
export HOME="$TEST_HOME"
export XDG_CONFIG_HOME="$TEST_HOME/config"
export XDG_STATE_HOME="$TEST_HOME/state"
export XDG_CACHE_HOME="$TEST_HOME/cache"
export XDG_RUNTIME_DIR="$TEST_HOME/runtime"
mkdir -p "$XDG_RUNTIME_DIR"

[[ $(./desu version) == "$(head -n 1 VERSION)" ]]
./desu help >/dev/null
./desu config >/dev/null
if ./config/scripts/desu-recorder not-a-command >/dev/null 2>&1; then
    printf '%s\n' 'recorder accepted an invalid command' >&2
    exit 1
fi

for file in install.sh uninstall.sh config/scripts/desu-lib.sh \
    config/scripts/desu-clipboard config/scripts/desu-recorder \
    config/scripts/desu-wallpaper config/scripts/desu-bar-settings; do
    bash -n "$file"
done

printf '%s\n' 'DESU CLI smoke tests passed'
