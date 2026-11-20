# Validation — 2026-11-20

Base: upstream v1.1.0, `7cc44f2b2c63341e2b478463c7467759837a74a9`.

## Completed local checks

- Windows x64 build with Microsoft C++ Build Tools and Windows SDK, static C++ runtime.
- Four personal-policy regression tests passed: stable metadata cannot enable official updates; report transport cannot open a network session; HeadsetControl transport cannot start a process; updater initialization leaves shared cache alone and disabled apply mode returns failure.
- Twelve selected upstream test programs passed: device aliases, alerts, history, runtime estimates, JSON output, labels, brands, update core, update signatures and three HyperX protocol suites.
- Both disabled standalone commands (`--report`, `--apply-update`) exited promptly with code 2.
- Microsoft Defender custom scan of the locally built executable reported no threats.
- Authenticode status: NotSigned (locally compiled personal executable).
- `git diff --check` passed.
- Local hardware discovery found Logitech PRO X Wireless, Logitech PRO X TKL and the HyperX Cloud III Wireless receiver. Mouse and keyboard returned numeric battery readings. The initial headset query reported a disconnected wireless link; its live battery reading still needs confirmation with the headset on.

## Review and fixes

A separate static reviewer checked the personal-policy changes. Its findings were addressed: disabled report mode no longer enters a message loop without a window; disabled apply mode cannot fall through to widget startup; personal initialization cannot clean another installation's cached updater files; the README points to the personal build command instead of the upstream installer.

Compiler compatibility adjustments: capture the Razer report length explicitly in its lambda; select the Windows SDK's integer-reference type for MSVC. No Logitech or HyperX query logic was changed.

The completed executable was linked from successfully compiled objects; failed translation units and modified files were rebuilt. The checked-in default script performs a full build. A GitHub Actions workflow provides a fresh Windows build and the same selected regression checks on the personal branch.

## Limits

This is a focused review, not a full security audit. A clean antivirus result does not prove safety. WinHTTP and shell APIs remain in the compiled application; the personal policy disables update/report entry points, while explicit support links can still open the user's browser. Native Bluetooth peripheral communication remains available. Upstream shared display settings and local history paths are retained. No device dumps, unit identifiers, battery readings or machine-specific paths are published here.
