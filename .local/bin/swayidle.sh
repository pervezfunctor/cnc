#!/usr/bin/env bash

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

SUSPEND_ENABLED=true
LOCK_TIME=150
DPMS_TIME=180
SUSPEND_TIME=600

while [[ $# -gt 0 ]]; do
  case "$1" in
  --lock-time)
    LOCK_TIME="$2"
    shift 2
    ;;
  --dpms-time)
    DPMS_TIME="$2"
    shift 2
    ;;
  --suspend-time)
    SUSPEND_TIME="$2"
    shift 2
    ;;
  --no-suspend)
    SUSPEND_ENABLED=false
    shift
    ;;
  *)
    echo "Unknown option: $1" >&2
    echo "Usage: $0 [--no-suspend] [--lock-time <sec>] [--dpms-time <sec>] [--suspend-time <sec>]" >&2
    exit 1
    ;;
  esac
done

if command -v systemd-detect-virt >/dev/null; then
  if systemd-detect-virt --quiet; then
    SUSPEND_ENABLED=false
  fi
fi

vmware_product="/sys/class/dmi/id/product_name"
vmware_sysvendor="/sys/class/dmi/id/sys_vendor"
if [[ -f "$vmware_product" ]] && grep -qi vmware "$vmware_product" 2>/dev/null; then
  SUSPEND_ENABLED=false
fi
if [[ -f "$vmware_sysvendor" ]] && grep -qi vmware "$vmware_sysvendor" 2>/dev/null; then
  SUSPEND_ENABLED=false
fi

if [[ "$XDG_CURRENT_DESKTOP" == *"mango"* ]] ||
  [[ "$XDG_CURRENT_DESKTOP" == *"niri"* ]] ||
  [[ "$XDG_CURRENT_DESKTOP" == *"sway"* ]]; then
  has_cmd swayidle || {
    echo "swayidle not found" >&2
    exit 1
  }

  swayidle_args=(
    "timeout" "${LOCK_TIME}" "dms ipc call lock lock"
    "timeout" "${DPMS_TIME}" "dms dpms off"
    "resume" "dms dpms on"
  )

  if [ "$SUSPEND_ENABLED" = true ]; then
    swayidle_args+=("timeout" "${SUSPEND_TIME}" 'systemctl suspend')
  fi

  swayidle -w "${swayidle_args[@]}"
else
  echo "No compatible compositor or idle manager found" >&2
  exit 1
fi
