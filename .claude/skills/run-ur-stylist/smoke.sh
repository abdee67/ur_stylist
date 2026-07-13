#!/usr/bin/env bash
# Launch the UR Stylist app on a connected Android device/emulator, drive one
# real interaction (onboarding -> next page), and write screenshots to
# ./screenshots/. Run from the repo root (ur_stylist/).
#
#   bash .claude/skills/run-ur-stylist/smoke.sh [device-id]
#
# If no device-id is given, the first Android device from `flutter devices`
# is used. Android is the only fully working target: flutter_stripe has no
# Windows desktop support (native-assets build fails) and the web build fails
# to compile under dart2js.
set -euo pipefail

DEVICE="${1:-}"
if [ -z "$DEVICE" ]; then
  DEVICE="$(flutter devices --machine 2>/dev/null \
    | grep -B2 '"targetPlatform": *"android' \
    | grep -oE '"id": *"[^"]+"' | head -1 | grep -oE '[^"]+$' | tail -1 || true)"
fi
if [ -z "$DEVICE" ]; then
  # Fallback: first android-* device from the human-readable list.
  DEVICE="$(flutter devices 2>/dev/null | grep -i 'android-' \
    | sed -E 's/.*•[[:space:]]*([0-9A-Za-z]+)[[:space:]]*•[[:space:]]*android-.*/\1/' | head -1 || true)"
fi
if [ -z "$DEVICE" ]; then
  echo "No Android device found. Plug in a device or start an emulator (flutter devices)." >&2
  exit 1
fi
echo "Driving on Android device: $DEVICE"

# Kotlin incremental cache occasionally corrupts on Windows -> wipe it first.
rm -rf build/app/kotlin 2>/dev/null || true
rm -rf screenshots

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_smoke_test.dart \
  -d "$DEVICE"

echo "--- screenshots ---"
ls -la screenshots/
