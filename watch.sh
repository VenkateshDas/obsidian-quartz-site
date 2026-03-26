#!/usr/bin/env bash
# Watches the ObsidianQuartz vault folder and triggers publish.sh on any change.
# Debounces rapid saves (e.g. Obsidian autosave) with a 10-second quiet period.

VAULT="/Users/venkateshmurugadas/Library/Mobile Documents/iCloud~md~obsidian/Documents/Venkatesh Learning/Research/ObsidianQuartz"
PUBLISH_SCRIPT="$(cd "$(dirname "$0")" && pwd)/publish.sh"
LOG="$HOME/.quartz-obsidian-quartz-watcher.log"
DEBOUNCE=10  # seconds to wait after last change before publishing

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

log "Watcher started. Monitoring: $VAULT"

last_change=0

fswatch -r -e '\.DS_Store$' -e '\.obsidian/' -e '\.canvas$' "$VAULT" | while read -r event; do
  now=$(date +%s)
  last_change=$now

  # Wait for the debounce window, then check if no newer change arrived
  (
    sleep $DEBOUNCE
    current=$(date +%s)
    if (( current - last_change >= DEBOUNCE )); then
      log "Change detected — running publish.sh"
      bash "$PUBLISH_SCRIPT" >> "$LOG" 2>&1
    fi
  ) &
done
