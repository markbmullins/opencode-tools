#!/usr/bin/env bash
set -e

TARGET="$HOME/.config/opencode/agents"
SOURCE="$HOME/dev/opencode-tools/agents"

mkdir -p "$TARGET"

rm -rf "$TARGET"/*
cp -r "$SOURCE"/* "$TARGET"/

echo "Synced agents → $TARGET"