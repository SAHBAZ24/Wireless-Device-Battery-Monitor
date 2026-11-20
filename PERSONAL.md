# BatteryHub Personal

This fork is based on upstream v1.1.0, commit `7cc44f2b2c63341e2b478463c7467759837a74a9`. The personal branch is `personal-v1.1.0`; upstream main is retained separately. Changes are reviewed and merged manually.

## Build

Use Windows x64, PowerShell, Microsoft C++ Build Tools with the x64 compiler, and the Windows SDK:

```powershell
./scripts/build-personal.ps1
```

The result is `build/personal/BatteryHub.exe`. Run it without administrator rights. It is portable; no installer or startup entry is created. Windows startup remains an explicit menu choice. Do not use the upstream installer or normal `build.bat` for this build.

## Changes

- `WB_PERSONAL_BUILD=1` prohibits upstream release updates even with stable version metadata.
- Report submission is disabled; standalone `--report` exits with code 2.
- The optional HeadsetControl executable is not started. Native Logitech and HyperX drivers remain available.
- `--apply-update` exits with code 2 and cannot become an installer helper.
- The updater leaves upstream temporary downloads and registry cache alone.
- Two compiler compatibility changes use an explicit lambda capture and Microsoft's WinRT integer-reference spelling. Battery query logic is unchanged.

The existing device-name, display, polling, language and local history features remain. User-selected browser links (for example, the author's support page) can still open a browser. Bluetooth drivers can communicate with paired peripherals. This is not a promise that the entire application has no network-related APIs or that it has passed a full security audit.

## Verification

The build first runs regression tests with stable metadata to ensure that personal policy still wins. Tests intercept the report's network-session function and the helper's process-start function; they do not send reports or launch vendor helpers. Another test verifies no updater-cache search and the disabled apply-mode exit code. The build then creates development metadata and compiles the application.

Actual device discovery uses `BatteryHub.exe --json`; percentages are read from hardware, never inserted into the source. Do not commit device dumps or local readings to this public repository. See `VALIDATION.md` for completed checks and practical limits.

## License and attribution

Original author: krisgfx9 and upstream contributors. Original project: https://github.com/krisgfx9/Wireless-Device-Battery-Monitor

The original GPL-3.0 license and copyright notices remain in `LICENSE` and the source. These personal modifications are distributed under the same license. No upstream precompiled executable or HeadsetControl binary is bundled.
