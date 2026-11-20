# Personal BatteryHub Implementation Plan

> Execute inline in this session using the executing-plans workflow.

**Goal:** Build and verify a pinned personal BatteryHub executable and publish the source changes in the user's fork.

**Architecture:** Preserve upstream device polling and presentation. Add a compile-time personal policy for update, report and external-helper entry points. Use a portable build with the installed Windows compiler.

**Tech Stack:** C++17, Win32, PowerShell, Microsoft C++ Build Tools.

**Spec:** `docs/superpowers/specs/2026-11-20-personal-build-design.md`

## Global Constraints
- Base: v1.1.0 commit `7cc44f2b2c63341e2b478463c7467759837a74a9`.
- Preserve GPL and notices; no automatic upstream merge or installer.
- Do not publish local device dumps, battery readings, credentials or personal paths.

## Review Focus
- Stable version metadata must not re-enable upstream updates in a personal build.
- Explicit report requests must not transmit device data.
- A helper executable found on PATH must not run in a personal build.
- Unsupported devices must remain unknown rather than acquire fabricated readings.
- Hardware access can differ inside the sandbox; validate on the actual host.

## Task 1: Build and enforce personal policy
- [ ] Add a personal policy regression test and observe the upstream behavior fail the personal expectation.
- [ ] Add the minimum compile-time guards and a reproducible PowerShell build script.
- [ ] Compile the application and run relevant existing tests and the personal policy tests.
- [ ] Inspect executable imports and run a local Defender scan where available.

## Task 2: Publish and verify hardware
- [ ] Commit source, design, plan, and review notes; push `personal-v1.1.0` to the user's fork.
- [ ] Run the personal executable's local JSON discovery and verify the three devices.
- [ ] Launch the portable widget and verify its visible state.
- [ ] Record the binary SHA-256, validation results and remaining limitations.
