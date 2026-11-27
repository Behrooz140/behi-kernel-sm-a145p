#!/system/bin/sh
# behi kernel — report the new stock firmware version / vermagic.
#
# Run on the phone in Termux:
#   sh diag_firmware_header.sh
#
# Root is required. The report is printed and saved to
# /sdcard/Download/behi-firmware-header-report.txt so it can be sent back.

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
SCRIPT="$SCRIPT_DIR/$(basename "$0")"
OUT="/sdcard/Download/behi-firmware-header-report.txt"

if [ "$(id -u)" != "0" ]; then
    if command -v su >/dev/null 2>&1; then
        exec su -c "sh '$SCRIPT'"
    fi
    echo "ROOT is required. Allow su for Termux first."
    exit 1
fi

: > "$OUT" 2>/dev/null || OUT="/data/local/tmp/behi-firmware-header-report.txt"

{
    echo "##### behi firmware-header diagnostic #####"
    date
    echo

    echo "=== 1. Firmware identity ==="
    for p in ro.product.model ro.boot.bootloader ro.build.display.id \
             ro.build.version.release ro.build.version.security_patch \
             ro.boot.vbmeta.device_state; do
        echo "$p = $(getprop "$p" 2>/dev/null)"
    done
    echo

    echo "=== 2. Running kernel ==="
    uname -r
    cat /proc/version 2>/dev/null
    echo

    echo "=== 3. Bootloader from cmdline ==="
    tr ' ' '\n' < /proc/cmdline 2>/dev/null | \
        grep -E 'bootloader|build|firmware' || echo "(no match)"
    echo

    echo "=== 4. Vermagic strings in stock vendor modules ==="
    VLIST=""
    for d in /vendor_dlkm/lib/modules /vendor/lib/modules; do
        [ -d "$d" ] || continue
        for m in "$d"/*.ko; do
            [ -f "$m" ] || continue
            V="$(grep -a -o -E \
                '6\.6\.[0-9]+[^[:cntrl:]]*modversions[^[:cntrl:]]*' \
                "$m" 2>/dev/null | head -1)"
            [ -n "$V" ] || continue
            VLIST="${VLIST}$(printf '%s : %s\n' "$(basename "$m")" "$V")"
        done
    done
    printf '%s\n' "$VLIST" | sort -u | head -60
    [ -n "$VLIST" ] || echo "(no vermagic string found; modinfo unavailable)"
    echo

    echo "=== 5. Input Booster / touch module vermagic ==="
    for d in /vendor_dlkm/lib/modules /vendor/lib/modules; do
        for m in "$d"/*boost*.ko "$d"/*touch*.ko; do
            [ -f "$m" ] || continue
            V="$(grep -a -o -E \
                '6\.6\.[0-9]+[^[:cntrl:]]*modversions[^[:cntrl:]]*' \
                "$m" 2>/dev/null | head -1)"
            printf '%s : %s\n' "$(basename "$m")" "${V:-unknown}"
        done
    done | sort -u | head -30
    echo

    echo "=== 6. Stock boot header magic ==="
    for b in /dev/block/by-name/boot /dev/block/by-name/boot_a \
             /dev/block/by-name/boot_b; do
        [ -r "$b" ] || continue
        MAGIC="$(dd if="$b" bs=1 count=8 2>/dev/null)"
        printf '%s : %s\n' "$b" "$MAGIC"
    done
    echo

    echo "##### end of report #####"
} 2>&1 | tee "$OUT"

echo
echo "Report saved to: $OUT"
