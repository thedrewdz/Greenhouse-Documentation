# Flutter (via flutter-pi) for the Main Unit touchscreen UI

Status: accepted
Date: 2026-06-29

## Context

The Main Unit UI renders on a touchscreen attached to the device itself, not primarily a remote browser. On an on-device display a web SPA requires a full browser engine (a Chromium kiosk) resident on the constrained hardware, which dominates the device's resource cost regardless of which JavaScript framework is chosen. The maintainer has strong Flutter experience and limited experience with the web frameworks considered.

This is the separate UI process defined in ADR 0001.

## Decision

Build the Main Unit UI as a **Flutter** application rendered through **`flutter-pi`**, which draws directly to KMS/DRM + GLES with no X11/Wayland and no browser engine. The UI talks to the services daemon over loopback REST (a Dart client generated from the daemon's OpenAPI) plus a WebSocket/SSE (or `signalr_netcore`) push channel.

## Considered options

- Blazor Server — rejected: server-side per-client render is heavy and re-introduces UI/services coupling (see ADR 0001).
- Blazor WebAssembly, or a JS SPA (Svelte/Vue/React) in a kiosk browser — rejected for the on-device case: all require Chromium resident on the device, and the .NET WASM runtime is additionally heavy.
- Angular — rejected: heaviest option with the most ceremony and no offsetting benefit here.
- Flutter via flutter-pi — chosen: no browser engine on the device, native touch rendering, and alignment with maintainer skill.

## Consequences

- Target hardware is a **Raspberry Pi 4 (8 GB)**, which is on flutter-pi's documented support list; the UI ships in flutter-pi **release/AOT** mode.
- flutter-pi is community-maintained (latest release **1.1.1**, 2026-01-31). Mitigations: pin engine/tool versions; **Sony's `flutter-embedded-linux`** is the documented fallback embedder.
- **Raspberry Pi 5 is not on flutter-pi's documented support list.** Moving to a Pi 5 (for performance or price reasons) requires re-validating the embedder and may supersede this ADR.
- Any upcoming official embedded-Flutter announcement is treated as upside, not a dependency.

## Validation spike (passed 2026-06-29)

Validated on a Raspberry Pi 4 (8 GB, Debian Bookworm) via `side-quests/flutter_pi_spike`: a minimal Flutter app built in flutter-pi release/AOT mode, deployed and launched full-screen on the touchscreen, rendering correctly and responding to pointer/touch input. REST + push were intentionally out of scope (standard Dart networking, not flutter-pi-specific).

Lessons folded into the `/ui` flutter-pi skill pack:

- flutterpi_tool cannot be globally activated (Dart pub forbids SDK-dependent global executables); add it as a project dev-dependency and run via `dart run flutterpi_tool build`.
- flutterpi_tool 0.11.0 only compiles against Flutter 3.41.x; pin the SDK (Flutter 3.44+ broke it on internal `flutter_tools` API).
- Launch needs the `--release` flag; the bundle lands in `build/flutter-pi/<target>/`.
- Touch arrives over a separate USB connection (HDMI carries video only).

## Display resolution issue (resolved 2026-06-30)

The earlier open issue — the touchscreen rendered scaled/blurry — is **resolved**. Root cause: the panel ships a spoofed EDID impersonating a *Lenovo L1950wD* (declares 1920x1080 native) with a malformed 1024x600 detailed timing that the Pi `vc4-kms-v3d` driver rejects, so it fell back to 1080p and the 1024x600 panel downscaled it. A `video=` cmdline override could not fix it while the bad EDID was authoritative; legacy `config.txt` `hdmi_*` settings are inert under full KMS.

Fix: override the EDID with `drm.edid_firmware`, advertising only 1024x600 at the panel's native pixel clock/timing with legal blanking that vc4 accepts, baked into the initramfs (vc4 loads before the rootfs mounts). Verified on the Pi 4: framebuffer and output are native 1024x600, 1:1, no scaling.

This is an OS/boot-level fix and must be reapplied after any Pi reimage. The concrete, reapply-able runbook and the EDID assets live in the `/ui` repo: `docs/skills/flutter-pi-on-pi4.md` ("Display resolution / EDID override") and `docs/skills/assets/flutter-pi-edid/`.
