# Personal BatteryHub build

Approved scope: fork BatteryHub, pin v1.1.0, inspect the relevant code and build our own portable executable for Logitech mouse/keyboard and HyperX Cloud III Wireless.

Base: `7cc44f2b2c63341e2b478463c7467759837a74a9` (v1.1.0). Work is isolated in a new clone on `personal-v1.1.0`; upstream main is left intact.

Approaches: use the published executable (least control); fork and compile the pinned source (chosen by the user); rewrite the application (unnecessary maintenance).

Implementation choices: keep upstream drivers and UI, compile a personal development build, prohibit upstream updates even if someone selects a stable channel, disable report submission and the optional external HeadsetControl executable. Cloud III has a native driver including receiver 03F0:05B7. Use the already installed Microsoft C++ compiler if compatible. Preserve GPL and copyright notices. Do not automatically merge upstream changes. Start with a portable executable, without an installer or startup registration.

Review covers network/process entry points, build scripts and the two relevant native drivers. This is not a complete security audit or proof of absence of malware. Actual device discovery and displayed percentages must be checked on this PC.
