#!/usr/bin/env bash
#
# pico-fido ESP32-S3 one-click local build with custom VID/PID.
# No-LED build is default ON (src/fido/no_led.c + DISABLE_LED).
#
# Usage (run from the repository root):
#   tools/esp32s3-vidpid-build/build.sh [VIDPID]
#
# VIDPID presets: Yubikey5 (default), YubikeyNeo, YubiHSM,
#                 NitroHSM, NitroFIDO2, NitroStart, NitroPro, Nitro3,
#                 Gnuk, GnuPG. Empty string = stock FEFF:FCFD.
#
# Requirements:
#   - ESP-IDF installed with the esp32s3 target (./install.sh esp32s3)
#   - Either idf.py on PATH or IDF_PATH pointing at your esp-idf checkout
#
# Output:
#   release/pico_fido_esp32s3_<VIDPID>.bin  (merged image, flash at 0x0
#   via https://espressif.github.io/esptool-js/)
#
# Note: credentials stored in the part0 flash partition are preserved
# across reflashing; only bootloader + partition table + app are rewritten.
set -euo pipefail

VIDPID="${1:-Yubikey5}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

if ! command -v idf.py >/dev/null 2>&1; then
  if [ -n "${IDF_PATH:-}" ] && [ -f "$IDF_PATH/export.sh" ]; then
    # shellcheck disable=SC1091
    . "$IDF_PATH/export.sh"
  else
    echo "ERROR: idf.py not found. Install ESP-IDF, then run: . \$IDF_PATH/export.sh" >&2
    exit 1
  fi
fi

CMAKE_ARGS=(-DDISABLE_LED=ON)
[ -n "$VIDPID" ] && CMAKE_ARGS+=("-DVIDPID=$VIDPID")

# shellcheck disable=SC2086
idf.py "${CMAKE_ARGS[@]}" set-target esp32s3
idf.py all

mkdir -p release
(
  cd build
  # shellcheck disable=SC2086
  esptool.py --chip ESP32-S3 merge_bin -o "../release/pico_fido_esp32s3_${VIDPID:-default}.bin" @flash_args
)

BIN="release/pico_fido_esp32s3_${VIDPID:-default}.bin"
echo "Done: $BIN"
echo "Flash it at offset 0x0 with esptool-js (https://espressif.github.io/esptool-js/)."
