#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="${OPENCODE_CONFIG_HOME:-$HOME/.config/opencode}"

OPENCODE_DIR="$REPO_DIR/opencode"
AGENTS_SOURCE_DIR="$OPENCODE_DIR/agents"
AUTHORED_SKILLS_DIR="$OPENCODE_DIR/skills/authored"
VENDOR_SKILLS_DIR="$OPENCODE_DIR/skills/vendor"
CONFIG_SOURCE_FILE="$OPENCODE_DIR/config/opencode.json"

sync_dir() {
  local source_dir="$1"
  local target_dir="$2"

  rm -rf "$target_dir"
  mkdir -p "$target_dir"

  if [ -d "$source_dir" ]; then
    cp -R "$source_dir"/. "$target_dir"/
  fi
}

assert_no_duplicate_skills() {
  local authored_dir="$1"
  local vendor_dir="$2"
  local duplicate=0

  if [ ! -d "$authored_dir" ] || [ ! -d "$vendor_dir" ]; then
    return 0
  fi

  local skill_dir
  for skill_dir in "$authored_dir"/*; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    if [ -d "$vendor_dir/$skill_name" ]; then
      printf 'Duplicate skill name in authored and vendor trees: %s\n' "$skill_name" >&2
      duplicate=1
    fi
  done

  if [ "$duplicate" -ne 0 ]; then
    exit 1
  fi
}

sync_skills() {
  local authored_dir="$1"
  local vendor_dir="$2"
  local target_dir="$3"
  local staging_dir

  staging_dir="$(mktemp -d)"
  trap 'rm -rf "$staging_dir"' EXIT

  mkdir -p "$staging_dir"

  if [ -d "$authored_dir" ]; then
    cp -R "$authored_dir"/. "$staging_dir"/
  fi

  if [ -d "$vendor_dir" ]; then
    cp -R "$vendor_dir"/. "$staging_dir"/
  fi

  sync_dir "$staging_dir" "$target_dir"
  rm -rf "$staging_dir"
  trap - EXIT
}

mkdir -p "$CONFIG_DIR"

assert_no_duplicate_skills "$AUTHORED_SKILLS_DIR" "$VENDOR_SKILLS_DIR"
sync_dir "$AGENTS_SOURCE_DIR" "$CONFIG_DIR/agents"
sync_skills "$AUTHORED_SKILLS_DIR" "$VENDOR_SKILLS_DIR" "$CONFIG_DIR/skills"
cp "$CONFIG_SOURCE_FILE" "$CONFIG_DIR/opencode.json"

echo "Synced OpenCode config -> $CONFIG_DIR"
echo "  agents: $CONFIG_DIR/agents"
echo "  skills: $CONFIG_DIR/skills"
echo "  config: $CONFIG_DIR/opencode.json"
