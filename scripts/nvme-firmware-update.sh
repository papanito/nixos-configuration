#!/usr/bin/env bash
# nvme-firmware-update.sh — Download, extract, and flash NVMe SSD firmware from Linux
#
# Supports:
#   - Crucial P3 Plus (CT4000P3PSSD8) — via Crucial's firmware API → .zip → .bin → nvme-cli
#   - Samsung 990 PRO                — via Samsung ISO → initrd → fumagician
#
# Usage:
#   sudo ./nvme-firmware-update.sh                  # auto-detect drives, interactive
#   sudo ./nvme-firmware-update.sh --check           # check for updates only, no flash
#   sudo ./nvme-firmware-update.sh --flash nvme0     # flash specific device
#   sudo ./nvme-firmware-update.sh --flash nvme1
#   sudo ./nvme-firmware-update.sh --all             # flash all supported drives
#
# Requirements: nvme-cli, curl, jq, unzip, p7zip, gzip, cpio, smartmontools
# On NixOS these are available in the system profile or via nix-shell.
#
# IMPORTANT: Firmware updates can brick your drive. Back up data first.
# The drive must NOT be actively in use during flash (best done from a live USB
# or with the filesystem unmounted). A full power cycle is required after flash.

set -euo pipefail

# --- Constants ---
CRUCIAL_API_URL="https://www.orderingmemory.com/firmware/firmware.aspx"
SAMSUNG_BASE_URL="https://download.semiconductor.samsung.com/resources/software-resources"
SAMSUNG_TOOLS_PAGE="https://semiconductor.samsung.com/consumer-storage/support/tools/"

# Drive model → NVMe device mapping (filled at runtime)
declare -A DRIVE_MAP
declare -A DRIVE_MODEL
declare -A DRIVE_FW
declare -A DRIVE_SERIAL

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- Helpers ---
# log() { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $*" >&2; }
ok() { echo -e "${GREEN}[OK]${NC} $*" >&2; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
err() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log() { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $*"; }
die() {
  err "$*"
  exit 1
}
confirm() {
  local prompt="$1"
  echo -en "${YELLOW}${prompt} [y/N]: ${NC}"
  read -r response
  [[ "$response" =~ ^[Yy]$ ]]
}

# --- Check dependencies ---
check_deps() {
  local missing=()
  for cmd in nvme curl jq unzip gzip 7z cpio; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    err "Missing dependencies: ${missing[*]}"
    err "On NixOS: nix-shell -p nvme-cli curl jq unzip p7zip gzip cpio smartmontools"
    die "Install missing tools and retry."
  fi
}

# --- Detect NVMe drives ---
detect_drives() {
  log "Detecting NVMe drives..."
  local found=0

  for dev in /dev/nvme*n1; do
    [[ -e "$dev" ]] || continue
    local name model fw serial
    name=$(basename "$dev" | sed 's/n1$//') # nvme0, nvme1, etc.
    model=$(cat "/sys/class/nvme/${name}/model" 2>/dev/null | xargs)
    fw=$(cat "/sys/class/nvme/${name}/firmware_rev" 2>/dev/null | xargs)
    serial=$(cat "/sys/class/nvme/${name}/serial" 2>/dev/null | xargs)

    # Only track supported models
    case "$model" in
    *P3PSSD8* | *CT4000P3*)
      DRIVE_MAP["$name"]="$dev"
      DRIVE_MODEL["$name"]="crucial-p3plus"
      DRIVE_FW["$name"]="$fw"
      DRIVE_SERIAL["$name"]="$serial"
      echo -e "  ${GREEN}$name${NC}: $model (FW: $fw, SN: $serial) → ${BOLD}Crucial P3 Plus${NC}"
      found=1
      ;;
    *990\ PRO* | *SSD\ 990\ PRO*)
      DRIVE_MAP["$name"]="$dev"
      DRIVE_MODEL["$name"]="samsung-990pro"
      DRIVE_FW["$name"]="$fw"
      DRIVE_SERIAL["$name"]="$serial"
      echo -e "  ${GREEN}$name${NC}: $model (FW: $fw, SN: $serial) → ${BOLD}Samsung 990 PRO${NC}"
      found=1
      ;;
    *)
      echo -e "  ${YELLOW}$name${NC}: $model (FW: $fw) — unsupported model, skipping"
      ;;
    esac
  done

  [[ $found -eq 0 ]] && die "No supported NVMe drives found."
  echo ""
}

# --- Crucial P3 Plus firmware ---
check_crucial_firmware() {
  local devname="$1"
  local current_fw="${DRIVE_FW[$devname]}"

  log "Checking Crucial firmware API for P3 Plus (current: $current_fw)..."

  local response
  response=$(curl -sf "${CRUCIAL_API_URL}?key=P3Plus&fw=${current_fw}&fwType=CR" 2>/dev/null) ||
    die "Failed to query Crucial firmware API."

  local latest_fw manualurl result
  latest_fw=$(echo "$response" | jq -r '.latestFW')
  manualurl=$(echo "$response" | jq -r '.manualurl')
  result=$(echo "$response" | jq -r '.result')
  local release_notes
  release_notes=$(echo "$response" | jq -r '.releasenotes // "N/A"')

  echo "  Current firmware: $current_fw"
  echo "  Latest firmware:  $latest_fw"
  echo "  Status:           $result"
  echo "  Release notes:    $(echo "$release_notes" | head -5 | sed 's/<[^>]*>//g' | tr -s ' ')"

  if [[ "$result" == "Update available" ]]; then
    echo "  Download URL:     $manualurl"
    # Store for later use
    CRUCIAL_LATEST_FW="$latest_fw"
    CRUCIAL_DOWNLOAD_URL="$manualurl"
    return 0 # update available
  elif [[ "$result" == "No update available" ]]; then
    ok "Firmware is already up to date."
    return 1 # no update
  else
    warn "Unexpected API response: $result"
    return 1
  fi
}

download_and_extract_crucial() {
  local workdir="$1"
  local -n bin_file="$2"

  log "Downloading Crucial P3 Plus firmware ($CRUCIAL_LATEST_FW)..."
  local zipfile="$workdir/crucial_fw.zip"
  curl -sL -o "$zipfile" "$CRUCIAL_DOWNLOAD_URL" || die "Download failed."
  ok "Downloaded $(ls -lh "$zipfile" | awk '{print $5}')"

  log "Extracting firmware..."
  unzip -o "$zipfile" -d "$workdir/crucial_extracted" >/dev/null || die "Extraction failed."

  # Find the .bin file
  local binfile_cruical # must not be binfile as this is the referenced name and it will shadow it and hence disapper after function is closed
  binfile_cruical=$(find "$workdir/crucial_extracted" -name "*.bin" -type f | head -1)
  [[ -z "$binfile_cruical" ]] && die "No .bin firmware file found in archive."

  echo "  Firmware file: $binfile_cruical" >&2
  bin_file="$binfile_cruical"
}

flash_crucial() {
  local devname="$1"
  local devpath="${DRIVE_MAP[$devname]}"
  local binfile="$2"

  echo ""
  echo -e "${BOLD}=== Flashing Crucial P3 Plus ($devname) ===${NC}"
  echo "  Device:     $devpath"
  echo "  Firmware:    $binfile"
  echo "  Target FW:   $CRUCIAL_LATEST_FW"
  echo ""

  warn "WARNING: Do NOT interrupt this process. Power loss = bricked drive."
  warn "Best practice: flash from a live USB with /home unmounted."
  if ! confirm "Proceed with firmware flash?"; then
    echo "Aborted."
    return 1
  fi

  log "Downloading firmware image to NVMe device..."
  nvme fw-download "$devpath" --fw="$binfile" || die "Firmware download to device failed."
  ok "Firmware downloaded to device."

  log "Committing and activating firmware (action=3, activate at next reset)..."
  # action=3: commit + activate without reset (activate on next power cycle)
  # Use slot 1 (the only slot on most Crucial drives)
  nvme fw-commit "$devpath" --action=3 || die "Firmware commit failed."
  ok "Firmware committed. Will activate on next power cycle."

  echo ""
  warn "A FULL POWER CYCLE (shutdown → power off → power on) is required to activate the new firmware."
  warn "Do not just reboot — shut down completely and wait 10 seconds before powering on."
  echo ""
  ok "After power cycle, verify with: nvme list"
}

# --- Samsung 990 PRO firmware ---
get_samsung_iso_url() {
  log "Finding latest Samsung 990 PRO firmware ISO..."

  # Scrape the Samsung tools page for the 990 PRO ISO link
  local page
  page=$(curl -sfL "$SAMSUNG_TOOLS_PAGE" 2>/dev/null) ||
    die "Failed to fetch Samsung tools page."

  local iso_url
  iso_url=$(echo "$page" | grep -oE 'https?://[^"]*Samsung_SSD_990_PRO_[^"]*\.iso' | head -1)

  [[ -z "$iso_url" ]] && die "Could not find Samsung 990 PRO ISO download URL."

  # Extract firmware version from URL
  local fw_version
  fw_version=$(echo "$iso_url" | grep -oE '[0-9]+B2QJXD[0-9]+' | head -1)

  echo "  Latest firmware:  $fw_version"
  echo "  Download URL:     $iso_url"

  SAMSUNG_LATEST_FW="$fw_version"
  SAMSUNG_ISO_URL="$iso_url"
}

check_samsung_firmware() {
  local devname="$1"
  local current_fw="${DRIVE_FW[$devname]}"

  get_samsung_iso_url

  echo "  Current firmware: $current_fw"
  echo "  Latest firmware:  $SAMSUNG_LATEST_FW"

  if [[ "$current_fw" == "$SAMSUNG_LATEST_FW" ]]; then
    ok "Firmware is already up to date."
    return 1
  fi

  # Version comparison (strip letters, compare numeric)
  local current_num latest_num
  current_num=$(echo "$current_fw" | grep -oE '[0-9]+' | head -1)
  latest_num=$(echo "$SAMSUNG_LATEST_FW" | grep -oE '[0-9]+' | head -1)

  if [[ -n "$current_num" ]] && [[ -n "$latest_num" ]] && [[ "$current_num" -ge "$latest_num" ]]; then
    ok "Firmware is already up to date."
    return 1
  fi

  return 0 # update available
}

download_and_extract_samsung() {
  local workdir="$1"
  local -n fuma_dir="$2"

  log "Downloading Samsung 990 PRO firmware ISO ($SAMSUNG_LATEST_FW)..."
  local isofile="$workdir/samsung_990pro.iso"
  curl -sL -o "$isofile" "$SAMSUNG_ISO_URL" || die "Download failed."
  ok "Downloaded $(ls -lh "$isofile" | awk '{print $5}')"

  log "Extracting initrd from ISO..."
  local initrd="$workdir/samsung_initrd"
  local iso_extract_dir="$workdir/samsung_iso_extracted"
  mkdir -p "$iso_extract_dir"
  chmod 755 "$iso_extract_dir"
  7z x -o"$iso_extract_dir" "$isofile" initrd >/dev/null 2>&1 ||
    die "Failed to extract initrd from ISO."
  mv "$iso_extract_dir/initrd" "$initrd" 2>/dev/null || true
  ok "initrd extracted."

  log "Decompressing initrd (gzip + cpio)..."
  local extract_dir="$workdir/samsung_fw_extracted"
  mkdir -p "$extract_dir"
  (
    cd "$extract_dir"
    gzip -dc "$initrd" | cpio -idv --no-absolute-filenames >/dev/null 2>&1
  ) || die "Failed to decompress initrd."

  # Find fumagician
  local fuma_dir_samsung
  fuma_dir_samsung=$(find "$extract_dir" -name "fumagician" -type f -printf '%h' 2>/dev/null | head -1)
  [[ -z "$fuma_dir_samsung" ]] && die "fumagician not found in extracted initrd."

  local enc_files
  enc_files=$(find "$fuma_dir_samsung" -name "*.enc" -type f | wc -l)
  [[ "$enc_files" -eq 0 ]] && die "No .enc firmware files found."

  echo "  fumagician:  $fuma_dir_samsung/fumagician"
  echo "  .enc files:  $(find "$fuma_dir_samsung" -name '*.enc' -printf '%f\n' | tr '\n' ' ')"
  fuma_dir="$fuma_dir_samsung"
}

flash_samsung() {
  local devname="$1"
  local fuma_dir="$2"

  echo ""
  echo -e "${BOLD}=== Flashing Samsung 990 PRO ($devname) ===${NC}"
  echo "  Device:      ${DRIVE_MAP[$devname]}"
  echo "  Firmware:    $SAMSUNG_LATEST_FW"
  echo "  Method:      fumagician (Samsung proprietary updater)"
  echo ""

  warn "WARNING: fumagician is Samsung's proprietary firmware updater."
  warn "It flashes directly via NVMe commands — do NOT interrupt."
  warn "Best practice: run from a live USB with /home unmounted."
  if ! confirm "Proceed with firmware flash?"; then
    echo "Aborted."
    return 1
  fi

  # Make fumagician executable
  chmod +x "$fuma_dir/fumagician" || die "Cannot make fumagician executable."

  # fumagician detects the drive automatically
  # It may need the working directory to be where the .enc files are
  log "Running fumagician..."
  (
    cd "$fuma_dir"
    ./fumagician 2>&1
  ) || warn "fumagician exited with non-zero status (may still be OK)."

  echo ""
  warn "A FULL POWER CYCLE (shutdown → power off → power on) is required to activate the new firmware."
  echo ""
  ok "After power cycle, verify with: nvme list"
}

# --- Cleanup ---
cleanup() {
  return
  if [[ -n "${WORKDIR:-}" ]] && [[ -d "$WORKDIR" ]]; then
    log "Cleaning up $WORKDIR..."
    rm -rf "$WORKDIR"
  fi
}

# --- Main ---
main() {
  echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║  NVMe Firmware Update Tool — Crucial P3 Plus + Samsung 990 PRO ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  [[ $EUID -ne 0 ]] && die "Must be run as root (sudo)."
  check_deps

  local check_only=false
  local flash_target=""
  local flash_all=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --check) check_only=true ;;
    --flash)
      flash_target="$2"
      shift
      ;;
    --all) flash_all=true ;;
    --help | -h)
      echo "Usage: $0 [--check] [--flash nvme0|nvme1] [--all]"
      echo "  --check       Check for updates only, do not flash"
      echo "  --flash DEV   Flash specific device (e.g., nvme0)"
      echo "  --all         Flash all supported drives"
      exit 0
      ;;
    *) die "Unknown argument: $1" ;;
    esac
    shift
  done

  detect_drives

  WORKDIR=$(mktemp -d /tmp/nvme-fw-update.XXXXXX)
  trap cleanup EXIT

  local any_update=false

  for devname in "${!DRIVE_MAP[@]}"; do
    local model="${DRIVE_MODEL[$devname]}"
    local has_update=false

    case "$model" in
    crucial-p3plus)
      if check_crucial_firmware "$devname"; then
        has_update=true
        any_update=true
      fi
      ;;
    samsung-990pro)
      if check_samsung_firmware "$devname"; then
        has_update=true
        any_update=true
      fi
      ;;
    esac

    if $has_update; then
      echo ""

      if $check_only; then
        warn "Update available for $devname. Run without --check to flash."
        continue
      fi

      if $flash_all || [[ "$flash_target" == "$devname" ]]; then
        case "$model" in
        crucial-p3plus)
          local binfile
          download_and_extract_crucial "$WORKDIR" binfile
          flash_crucial "$devname" "$binfile"
          ;;
        samsung-990pro)
          local fumadir
          download_and_extract_samsung "$WORKDIR" fumadir
          flash_samsung "$devname" "$fumadir"
          ;;
        esac
      else
        echo "  To flash: $0 --flash $devname"
      fi
    fi
    echo ""
  done

  if $check_only; then
    if $any_update; then
      warn "Firmware updates are available. Run: sudo $0 --all"
    else
      ok "All firmware is up to date."
    fi
  fi
}

main "$@"
