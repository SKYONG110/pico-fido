# ESP32-S3 build with custom VID/PID

Two ways to build the ESP32-S3 firmware (no-LED build is default ON):

## 1. GitHub Actions (easiest, no local toolchain)

`.github/workflows/build-esp32s3-vidpid.yml`

- Go to the Actions tab -> "Build ESP32-S3 (custom VID/PID)" -> Run workflow,
  pick a VIDPID preset (`Yubikey5` default), Run.
- When done, download the `pico-fido-esp32s3-vidpid` artifact.
- Flash the `.bin` at offset `0x0` with https://espressif.github.io/esptool-js/.

## 2. Local script

```bash
chmod +x tools/esp32s3-vidpid-build/build.sh
tools/esp32s3-vidpid-build/build.sh Yubikey5   # or any preset, or "" for stock VID/PID
```

Requires ESP-IDF with the `esp32s3` target installed (`./install.sh esp32s3`)
and `idf.py` on PATH (or `IDF_PATH` set). Output lands in `release/`.

## Notes

- Supported presets: `Yubikey5`, `YubikeyNeo`, `YubiHSM`, `NitroHSM`,
  `NitroFIDO2`, `NitroStart`, `NitroPro`, `Nitro3`, `Gnuk`, `GnuPG`.
- Per the project README, a VID/PID you do not own is for internal use only;
  do not distribute built binaries carrying someone else's VID/PID.
- Reflashing preserves credentials: they live in the dedicated `part0`
  flash partition, which the merged image does not touch.
