#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${OPENCODE_CONFIG_HOME:-$HOME/.config/opencode}"

sync_dir() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "$target_dir"
  rm -rf "$target_dir"
  mkdir -p "$target_dir"

  if [ -d "$source_dir" ]; then
    cp -R "$source_dir"/. "$target_dir"/
  fi
}

sync_dir "$REPO_DIR/agents" "$CONFIG_DIR/agents"
sync_dir "$REPO_DIR/.agents/skills" "$CONFIG_DIR/skills"
cp "$REPO_DIR/opencode.json" "$CONFIG_DIR/opencode.json"

echo "Synced OpenCode config → $CONFIG_DIR"
echo "  agents: $CONFIG_DIR/agents"
echo "  skills: $CONFIG_DIR/skills"
echo "  config: $CONFIG_DIR/opencode.json"
