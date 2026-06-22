#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-all}"
SKILL_NAME="rtl-agent-output-fixer"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/skills/$SKILL_NAME"
CODEX_RULES_SRC="$SCRIPT_DIR/codex/AGENTS.md"
CLAUDE_FRAGMENT_SRC="$SCRIPT_DIR/CLAUDE.md.fragment"
GEMINI_FRAGMENT_SRC="$SCRIPT_DIR/GEMINI.md.fragment"

START_MARK="<!-- rtl-agent-output-fixer:start -->"
END_MARK="<!-- rtl-agent-output-fixer:end -->"

copy_skill() {
  local dest_root="$1"
  mkdir -p "$dest_root"
  rm -rf "$dest_root/$SKILL_NAME"
  cp -R "$SKILL_SRC" "$dest_root/$SKILL_NAME"
  echo "Installed skill: $dest_root/$SKILL_NAME"
}

append_block_once() {
  local file="$1"
  local fragment="$2"
  local title="$3"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if grep -q "$START_MARK" "$file"; then
    echo "Already configured: $file"
    return 0
  fi
  cp "$file" "$file.bak.$(date +%Y%m%d%H%M%S)"
  {
    printf '\n%s\n' "$START_MARK"
    cat "$fragment"
    printf '\n%s\n' "$END_MARK"
  } >> "$file"
  echo "Added always-on RTL rules to $title: $file"
}

install_claude() {
  local base="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  copy_skill "$base/skills"
  append_block_once "$base/CLAUDE.md" "$CLAUDE_FRAGMENT_SRC" "Claude Code"
}

install_codex() {
  copy_skill "$HOME/.agents/skills"
  append_block_once "$HOME/.codex/AGENTS.md" "$CODEX_RULES_SRC" "Codex"
}

install_antigravity() {
  copy_skill "$HOME/.agents/skills"
  copy_skill "$HOME/.gemini/antigravity-cli/skills"
  append_block_once "$HOME/.gemini/GEMINI.md" "$GEMINI_FRAGMENT_SRC" "Antigravity/Gemini"
}

case "$TARGET" in
  claude-code|claude) install_claude ;;
  codex) install_codex ;;
  antigravity|gemini) install_antigravity ;;
  all) install_claude; install_codex; install_antigravity ;;
  *)
    echo "Usage: $0 [claude-code|codex|antigravity|all]" >&2
    exit 1
    ;;
esac

echo "Done. Restart the agent app/CLI if it was already open."
