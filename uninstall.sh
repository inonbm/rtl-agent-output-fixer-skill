#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-all}"
SKILL_NAME="rtl-agent-output-fixer"
START_MARK="<!-- rtl-agent-output-fixer:start -->"
END_MARK="<!-- rtl-agent-output-fixer:end -->"

remove_skill() {
  local dest_root="$1"
  local path="$dest_root/$SKILL_NAME"
  if [ -d "$path" ]; then
    rm -rf "$path"
    echo "Removed skill: $path"
  else
    echo "Skill not found: $path"
  fi
}

remove_block() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "Config not found: $file"
    return 0
  fi
  if ! grep -q "$START_MARK" "$file"; then
    echo "No RTL block found in: $file"
    return 0
  fi
  cp "$file" "$file.bak.$(date +%Y%m%d%H%M%S)"
  awk -v start="$START_MARK" -v end="$END_MARK" '
    index($0, start) { skip=1; next }
    index($0, end) { skip=0; next }
    !skip { print }
  ' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
  echo "Removed RTL rules from: $file"
}

uninstall_claude() {
  local base="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  remove_skill "$base/skills"
  remove_block "$base/CLAUDE.md"
}

uninstall_codex() {
  remove_skill "$HOME/.agents/skills"
  remove_block "$HOME/.codex/AGENTS.md"
}

uninstall_antigravity() {
  remove_skill "$HOME/.agents/skills"
  remove_skill "$HOME/.gemini/antigravity-cli/skills"
  remove_block "$HOME/.gemini/GEMINI.md"
}

case "$TARGET" in
  claude-code|claude) uninstall_claude ;;
  codex) uninstall_codex ;;
  antigravity|gemini) uninstall_antigravity ;;
  all) uninstall_claude; uninstall_codex; uninstall_antigravity ;;
  *)
    echo "Usage: uninstall.sh [claude-code|codex|antigravity|all]" >&2
    exit 1
    ;;
esac

echo "Done. Restart the agent app/CLI if it was already open."
