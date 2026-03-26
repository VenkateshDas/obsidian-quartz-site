#!/usr/bin/env bash
set -euo pipefail

VAULT="/Users/venkateshmurugadas/Library/Mobile Documents/iCloud~md~obsidian/Documents/Venkatesh Learning/Research/ObsidianQuartz"
CONTENT_DIR="$(cd "$(dirname "$0")" && pwd)/content"
PREVIEW=false

for arg in "$@"; do
  [[ "$arg" == "--preview" ]] && PREVIEW=true
done

echo "Syncing from Obsidian → Quartz content/"
rsync -a --delete --delete-excluded \
  --exclude='.DS_Store' \
  --exclude='*.canvas' \
  --exclude='.obsidian/' \
  --exclude='examples/' \
  --exclude='drafts/' \
  "$VAULT/" "$CONTENT_DIR/"

if $PREVIEW; then
  echo "Starting local preview..."
  npx quartz build --serve
  exit 0
fi

cd "$(dirname "$0")"
if git diff --quiet HEAD -- content/; then
  echo "No changes. Nothing to publish."
  exit 0
fi

TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
git add content/
git commit -m "sync: Obsidian → Quartz · $TIMESTAMP"
git push origin HEAD:main
echo "Pushed. Site will be live at https://venkateshdas.github.io/obsidian-quartz-site/ in ~2 min."
