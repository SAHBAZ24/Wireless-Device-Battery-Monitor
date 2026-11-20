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
- [x] Add a personal policy regression test and observe the upstream behavior fail the personal expectation.
- [x] Add the minimum compile-time guards and a reproducible PowerShell build script.
- [x] Compile the application and run relevant existing tests and the personal policy tests.
- [x] Inspect executable imports and run a local Defender scan where available.

## Task 2: Publish and verify hardware
- [x] Commit source, design, plan, and review notes; push `personal-v1.1.0` to the user's fork.
- [x] Run the personal executable's local JSON discovery and verify the three devices.
- [x] Launch the portable widget and verify its visible state.
- [x] Record the binary SHA-256, validation results and remaining limitations.

## Execution ledger

Task 1: complete; policy regressions observed failing before guards, then passing. Selected local suite: 18/18 checks passed. Defender reported no threats; local binary is unsigned.

Ruling: an isolated new clone was used instead of an additional worktree, because no existing project checkout needed protection.

Ruling: use the installed Microsoft compiler instead of installing MinGW; two equivalent driver syntax changes were needed for that compiler. Cost if incorrect: compatibility outside the tested Windows toolchain; the original MinGW integer-reference spelling is preserved under its compiler path.

Final review: a separate reviewer identified four lifecycle/documentation issues; all were addressed. A regression test caught cache cleanup and apply-mode fallthrough before the fixes, then passed. Standalone command exit checks passed after the report-loop fix.

Task 2: complete; source published at `bf2369a`; local discovery verified all three devices. Portable widget is running. The user's initial screenshot showed a stale disconnected headset; widget restarted after live discovery succeeded. The user confirmed the live headset percentage was visible after restart. Clean GitHub runner build, selected tests and portable artifact upload succeeded in run `44737652179`.
