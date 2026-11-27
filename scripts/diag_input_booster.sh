#!/system/bin/sh
# behi kernel — Input Booster / scaling_min_freq diagnostic
#
# Copy this file to the phone and run it in Termux:
#   sh diag_input_booster.sh
#
# It asks for root (su) and prints a report. The same report is saved to
# /sdcard/Download/behi-input-booster-report.txt so it can be sent back.

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
SCRIPT="$SCRIPT_DIR/$(basename "$0")"
OUT="/sdcard/Download/behi-input-booster-report.txt"

if [ "$(id -u)" != "0" ]; then
    if command -v su >/dev/null 2>&1; then
        exec su -c "sh '$SCRIPT'"
    fi
    echo "ROOT is required. Allow su for Termux first."
    exit 1
fi

: > "$OUT" 2>/dev/null || OUT="/data/local/tmp/behi-input-booster-report.txt"

{
    echo "##### behi input-booster diagnostic #####"
    date
    echo

    echo "=== 1. Kernel / device ==="
    uname -r
    getprop ro.product.model 2>/dev/null
    getprop ro.boot.bootloader 2>/dev/null
    echo

    echo "=== 2. cpufreq policies (before test) ==="
    for p in /sys/devices/system/cpu/cpufreq/policy*; do
        [ -d "$p" ] || continue
        echo "-- $(basename "$p")"
        for f in cpuinfo_min_freq cpuinfo_max_freq scaling_min_freq \
                 scaling_max_freq scaling_governor; do
            [ -r "$p/$f" ] && echo "   $f = $(cat "$p/$f")"
        done
    done
    echo

    echo "=== 3. Kernel config (if exposed) ==="
    if [ -r /proc/config.gz ]; then
        CFG="$(gzip -dc /proc/config.gz 2>/dev/null | \
            grep -E '^CONFIG_(SEC_INPUT_BOOSTER|SEC_INPUT_BOOSTER_MODE|SEC_INPUT_BOOSTER_MTK|SEC_INPUT_BOOSTER_HANDLER|INPUT_EVDEV|MTK_PERFORMANCE_MODULE|MTK_PPM_V3)=')"
        [ -n "$CFG" ] && echo "$CFG" || echo "(no matching options)"
    else
        echo "(/proc/config.gz not available)"
    fi
    echo

    echo "=== 4. Input Booster sysfs ==="
    FOUND=0
    for d in /sys/class/input_booster /sys/class/Disable_Mode \
             /sys/class/Sip_Mode /sys/class/Game_Mode; do
        [ -d "$d" ] || continue
        FOUND=1
        echo "-- $d"
        for f in "$d"/*; do
            [ -f "$f" ] || continue
            echo "   $(basename "$f") = $(cat "$f" 2>/dev/null)"
        done
    done
    [ "$FOUND" = 1 ] || echo "(no input_booster class found)"
    echo

    echo "=== 5. Loaded modules / vendor module files ==="
    MODS="$(lsmod 2>/dev/null | grep -i -E 'boost|ppm')"
    [ -n "$MODS" ] && echo "$MODS" || echo "(no matching loaded module)"
    find /vendor/lib/modules /vendor_dlkm/lib/modules -maxdepth 1 \
        -type f -iname '*boost*' 2>/dev/null | head -20
    echo

    echo "=== 6. dmesg booster lines ==="
    DM="$(dmesg 2>/dev/null | grep -i -E 'input.?booster|touch.?boost|booster' | tail -40)"
    [ -n "$DM" ] && echo "$DM" || echo "(dmesg unavailable or no matches)"
    echo

    MODE="/sys/class/input_booster/ib_mode_state"
    OLD=""
    [ -r "$MODE" ] && OLD="$(cat "$MODE")"

    sample() {
        echo "--- $1 ---"
        i=0
        while [ "$i" -lt 10 ]; do
            line="$(date +%H:%M:%S)"
            for p in /sys/devices/system/cpu/cpufreq/policy*; do
                [ -r "$p/scaling_min_freq" ] || continue
                line="$line $(basename "$p")=$(cat "$p/scaling_min_freq")"
            done
            echo "$line"
            sleep 1
            i=$((i + 1))
        done
        echo
    }

    echo "=== 7. LIVE TEST (10 s + 10 s) ==="
    echo ">>> Phase 1: current mode=${OLD:-unknown}"
    echo ">>> الان انگشتت رو روی صفحه بکش و لمس کن تا ۱۰ ثانیه دیگه ..."
    sleep 2
    sample "normal mode=${OLD:-unknown}"

    echo ">>> Switching Input Booster to Disable_Mode (mode=1) ..."
    if [ -e "$MODE" ]; then
        if echo 1 > "$MODE" 2>&1; then
            echo "write OK"
        else
            echo "write FAILED"
        fi
        echo "mode now = $(cat "$MODE" 2>/dev/null)"
    else
        echo "mode sysfs not found: $MODE"
    fi

    echo ">>> Phase 2: دوباره ۱۰ ثانیه صفحه رو لمس کن ..."
    sleep 2
    sample "Disable_Mode mode=$(cat "$MODE" 2>/dev/null)"

    echo "=== 8. Restore ==="
    if [ -n "$OLD" ] && [ -e "$MODE" ]; then
        if echo "$OLD" > "$MODE" 2>/dev/null; then
            echo "restored mode=$OLD"
        else
            echo "restore failed"
        fi
    else
        echo "nothing to restore"
    fi

    echo "##### end of report #####"
} 2>&1 | tee "$OUT"

echo
echo "Report saved to: $OUT"
