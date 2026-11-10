#!/usr/bin/env bash
# Remove the SAM0201 accelerometer driver; the stock st_accel is used again
# after a reboot (without SAM0201 support: no auto-rotation).
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$HERE/common/uninstall-dkms.sh" st-accel-sam0201
