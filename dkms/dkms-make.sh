#!/bin/bash
# Build st_accel + st_accel_i2c with the SAM0201 ACPI id for one kernel, from
# that kernel's own vanilla source (not a frozen copy).
set -euo pipefail
KVER="${1:?kernelver required}"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HEADERS="/lib/modules/$KVER/build"
# shellcheck source=/dev/null
. "${GB_HELPER:-/usr/local/lib/galaxybook-dkms/kernel-src.sh}"

[ -d "$HEADERS" ] || { echo "ERROR: no kernel headers at $HEADERS (install kernel-devel-$KVER)" >&2; exit 1; }
F=(st_accel_core.c st_accel_buffer.c st_accel_i2c.c st_accel.h)
SRC="$(gb_kernel_src "$KVER" "${F[@]/#/drivers/iio/accel/}")"

OUT="$HERE/out"; rm -rf "$OUT"; A="$OUT/drivers/iio/accel"; mkdir -p "$A"
for f in "${F[@]}"; do cp "$SRC/drivers/iio/accel/$f" "$A/"; done
gb_apply_patches "$HERE" "$OUT"

printf '%s\n' 'obj-m += st_accel.o' 'st_accel-y := st_accel_core.o st_accel_buffer.o' \
  'obj-m += st_accel_i2c.o' > "$A/Makefile"
make -C "$HEADERS" M="$A" modules -j"${JOBS:-$(nproc)}" CONFIG_DEBUG_INFO_BTF_MODULES=
echo "Built st_accel + st_accel_i2c for $KVER"
