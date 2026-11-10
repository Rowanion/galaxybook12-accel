#!/usr/bin/env bash
# Install the SAM0201 accelerometer driver (DKMS package st-accel-sam0201) for
# every installed kernel, plus the post-network rebuild service.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Checking for ACPI device SAM0201 (Samsung K2HH/LIS2HH12-compatible accelerometer)..."
if ! compgen -G "/sys/bus/acpi/devices/SAM0201*" >/dev/null; then
    echo "ERROR: No ACPI device with HID SAM0201 found on this system."
    echo "This fix only applies to Samsung Galaxy Book devices exposing this ACPI ID"
    echo "(confirmed on the Galaxy Book 12 / SM-W720)."
    echo "Detected: $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) $(cat /sys/class/dmi/id/product_name 2>/dev/null) ($(cat /sys/class/dmi/id/board_name 2>/dev/null))"
    exit 1
fi
echo "    Found. Detected as: $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) $(cat /sys/class/dmi/id/product_name 2>/dev/null) ($(cat /sys/class/dmi/id/board_name 2>/dev/null))"

"$HERE/common/install-dkms.sh" st-accel-sam0201 "$HERE/dkms"
echo "Reboot once to use it. Verify:"
echo "  cat /sys/bus/iio/devices/iio:device*/name          # -> lis2hh12"
echo "  cat /sys/bus/iio/devices/iio:device*/mount_matrix"
