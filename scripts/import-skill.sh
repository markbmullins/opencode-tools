#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <skill-name> [source-path]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="$1"
TARGET_DIR="$REPO_DIR/opencode/skills/vendor/$SKILL_NAME"

resolve_source_dir() {
  if [ "$#" -eq 2 ]; then
    printf '%s\n' "$2"
    return 0
  fi

  local candidates=(
    "$REPO_DIR/.agents/skills/$SKILL_NAME"
    "$REPO_DIR/.opencode/skills/$SKILL_NAME"
    "$PWD/.agents/skills/$SKILL_NAME"
    "$PWD/.opencode/skills/$SKILL_NAME"
    "$HOME/.agents/skills/$SKILL_NAME"
    "${OPENCODE_CONFIG_HOME:-$HOME/.config/opencode}/skills/$SKILL_NAME"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [ -d "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

SOURCE_DIR="$(resolve_source_dir "$@")" || {
  echo "Could not find skill '$SKILL_NAME' in project or global skill paths." >&2
  exit 1
}

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -R "$SOURCE_DIR"/. "$TARGET_DIR"/

echo "Imported skill '$SKILL_NAME'"
echo "  from: $SOURCE_DIR"
echo "  to:   $TARGET_DIR"
echo "Review and commit the vendored files if you want them portable."
