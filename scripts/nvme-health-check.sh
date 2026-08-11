#!/bin/bash
# nvme-health-check.sh — Diagnose NVMe controller health on clawfinger
#
# Usage: sudo ./nvme-health-check.sh
#
# This script checks:
# 1. NVMe controller state (live/dead)
# 2. SMART health data (if nvme-cli is available)
# 3. Recent kernel I/O errors on NVMe devices
# 4. BTRFS filesystem error counters
# 5. Current mount state of /home
# 6. Power management settings (APST, ASPM, D3cold)
#
# Exit codes:
#   0 = healthy
#   1 = warnings (recent errors but filesystem still writable)
#   2 = critical (controller down or filesystem read-only)

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

EXIT_CODE=0

print_status() {
    local level="$1"
    local msg="$2"
    case "$level" in
        OK)   echo -e "${GREEN}[OK]${NC} $msg" ;;
        WARN) echo -e "${YELLOW}[WARN]${NC} $msg"; EXIT_CODE=1 ;;
        CRIT) echo -e "${RED}[CRITICAL]${NC} $msg"; EXIT_CODE=2 ;;
    esac
}

echo "=== NVMe Health Check ==="
echo "Date: $(date -Iseconds)"
echo ""

# --- 1. Controller state ---
echo "--- Controller State ---"
for dev in /sys/class/nvme/nvme*; do
    name=$(basename "$dev")
    state=$(cat "$dev/state" 2>/dev/null || echo "unknown")
    model=$(cat "$dev/model" 2>/dev/null | xargs)
    fw=$(cat "$dev/firmware_rev" 2>/dev/null | xargs)
    echo "  $name: $model (FW: $fw) — state: $state"
    if [ "$state" != "live" ]; then
        print_status CRIT "$name controller is NOT live (state: $state)"
    else
        print_status OK "$name controller is live"
    fi
done
echo ""

# --- 2. SMART data (if nvme-cli available) ---
echo "--- SMART Health ---"
if command -v nvme &>/dev/null; then
    for dev in /dev/nvme0 /dev/nvme1; do
        if [ -e "$dev" ]; then
            echo "  $dev:"
            nvme smart-log "$dev" 2>/dev/null | grep -E "critical_warning|temperature|available_spare|percentage_used|data_units|power_on_hours|unsafe|media_errors|num_err_log" | sed 's/^/    /' || true
        fi
    done
else
    echo "  nvme-cli not installed — install with: nix-env -iA nixos.nvme-cli"
fi
echo ""

# --- 3. Recent kernel I/O errors ---
echo "--- Recent NVMe I/O Errors (last 24h) ---"
err_count=$(journalctl -k --since "24 hours ago" --no-pager -o cat 2>/dev/null | grep -c "I/O error, dev nvme" || true)
ctrl_down=$(journalctl -k --since "24 hours ago" --no-pager -o cat 2>/dev/null | grep -c "controller is down" || true)
btrfs_ro=$(journalctl -k --since "24 hours ago" --no-pager -o cat 2>/dev/null | grep -c "forced readonly" || true)
echo "  I/O errors: $err_count"
echo "  Controller resets: $ctrl_down"
echo "  BTRFS forced readonly: $btrfs_ro"
if [ "$ctrl_down" -gt 0 ]; then
    print_status CRIT "$ctrl_down controller crash(es) in last 24h"
elif [ "$err_count" -gt 0 ]; then
    print_status WARN "$err_count I/O error(s) in last 24h"
else
    print_status OK "No NVMe I/O errors in last 24h"
fi
echo ""

# --- 4. BTRFS filesystem error counters ---
echo "--- BTRFS Error Counters (/home) ---"
for f in /sys/fs/btrfs/*/devinfo/1/error_stats; do
    if [ -f "$f" ]; then
        echo "  $(cat "$f")"
        wr_errs=$(echo "$(cat "$f")" | grep -oP 'write_errs \K[0-9]+' || echo "0")
        rd_errs=$(echo "$(cat "$f")" | grep -oP 'read_errs \K[0-9]+' || echo "0")
        if [ "$wr_errs" -gt 0 ] || [ "$rd_errs" -gt 0 ]; then
            print_status WARN "BTRFS has accumulated errors: wr=$wr_errs rd=$rd_errs"
        else
            print_status OK "BTRFS error counters are zero (since last mount)"
        fi
    fi
done
echo ""

# --- 5. Mount state ---
echo "--- Mount State ---"
home_mount=$(findmnt -n -o OPTIONS,FSTYPE /home 2>/dev/null || echo "not mounted")
echo "  /home: $home_mount"
if echo "$home_mount" | grep -q "ro,"; then
    print_status CRIT "/home is mounted READ-ONLY"
elif echo "$home_mount" | grep -q "^ro"; then
    print_status CRIT "/home is mounted READ-ONLY"
else
    print_status OK "/home is mounted read-write"
fi
echo ""

# --- 6. Power management settings ---
echo "--- Power Management ---"
for dev in /sys/class/nvme/nvme*; do
    name=$(basename "$dev")
    aspm=$(cat /sys/module/pcie_aspm/parameters/policy 2>/dev/null || echo "N/A")
    d3cold=$(cat "$dev/device/d3cold_allowed" 2>/dev/null || echo "N/A")
    pwr_ctrl=$(cat "$dev/device/power/control" 2>/dev/null || echo "N/A")
    ps_lat=$(cat /sys/module/nvme_core/parameters/default_ps_max_latency_us 2>/dev/null || echo "N/A")
    echo "  $name: ASPM=$aspm D3cold_allowed=$d3cold power_control=$pwr_ctrl APST_latency=$ps_lat"
    if [ "$d3cold" = "1" ]; then
        print_status WARN "$name: D3cold is allowed (can cause controller lockups)"
    fi
    if [ "$pwr_ctrl" = "auto" ]; then
        print_status WARN "$name: runtime PM is auto (can cause controller lockups)"
    fi
done
echo ""

# --- Summary ---
echo "=== Summary ==="
if [ "$EXIT_CODE" -eq 0 ]; then
    print_status OK "All checks passed"
elif [ "$EXIT_CODE" -eq 1 ]; then
    print_status WARN "Warnings detected — monitor closely"
else
    print_status CRIT "Critical issues detected — reboot recommended"
fi

exit "$EXIT_CODE"