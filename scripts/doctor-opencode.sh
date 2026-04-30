#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="${OPENCODE_CONFIG_HOME:-$HOME/.config/opencode}"

OPENCODE_DIR="$REPO_DIR/opencode"
AUTHORED_SKILLS_DIR="$OPENCODE_DIR/skills/authored"
VENDOR_SKILLS_DIR="$OPENCODE_DIR/skills/vendor"

status=0

check_legacy_project_paths() {
  local legacy_dir
  local legacy_dirs=(
    "$REPO_DIR/.agents/skills"
    "$REPO_DIR/.opencode/skills"
  )

  for legacy_dir in "${legacy_dirs[@]}"; do
    if [ -d "$legacy_dir" ]; then
      echo "legacy project skill path present: $legacy_dir"
      echo "remove or migrate it so repo/runtime discovery stays unambiguous"
      status=1
    fi
  done
}

check_duplicate_skills() {
  local skill_dir
  for skill_dir in "$AUTHORED_SKILLS_DIR"/*; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    if [ -d "$VENDOR_SKILLS_DIR/$skill_name" ]; then
      echo "duplicate skill: $skill_name exists in authored and vendor"
      status=1
    fi
  done
}

report_runtime_diff() {
  local label="$1"
  local expected_dir="$2"
  local actual_dir="$3"

  if [ ! -d "$actual_dir" ]; then
    echo "$label missing at runtime: $actual_dir"
    status=1
    return
  fi

  if ! diff -qr "$expected_dir" "$actual_dir" >/dev/null; then
    echo "$label drift detected between repo and runtime"
    diff -qr "$expected_dir" "$actual_dir" || true
    status=1
  else
    echo "$label OK"
  fi
}

staging_dir="$(mktemp -d)"
trap 'rm -rf "$staging_dir"' EXIT

mkdir -p "$staging_dir/skills"
if [ -d "$AUTHORED_SKILLS_DIR" ]; then
  cp -R "$AUTHORED_SKILLS_DIR"/. "$staging_dir/skills"/
fi
if [ -d "$VENDOR_SKILLS_DIR" ]; then
  cp -R "$VENDOR_SKILLS_DIR"/. "$staging_dir/skills"/
fi

check_duplicate_skills
check_legacy_project_paths
report_runtime_diff "agents" "$OPENCODE_DIR/agents" "$CONFIG_DIR/agents"
report_runtime_diff "skills" "$staging_dir/skills" "$CONFIG_DIR/skills"

if [ ! -f "$CONFIG_DIR/opencode.json" ]; then
  echo "config missing at runtime: $CONFIG_DIR/opencode.json"
  status=1
elif ! cmp -s "$OPENCODE_DIR/config/opencode.json" "$CONFIG_DIR/opencode.json"; then
  echo "config drift detected between repo and runtime"
  status=1
else
  echo "config OK"
fi

exit "$status"
