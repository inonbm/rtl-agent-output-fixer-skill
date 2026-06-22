#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-all}"
SKILL_NAME="rtl-agent-output-fixer"
REPO="inonbm/rtl-agent-output-fixer-skill"
REF="${RTL_SKILL_REF:-main}"
START_MARK="<!-- rtl-agent-output-fixer:start -->"
END_MARK="<!-- rtl-agent-output-fixer:end -->"
TEMP_DIR=""

cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

script_dir() {
  if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
  else
    pwd
  fi
}

PACKAGE_DIR="$(script_dir)"

bootstrap_package_if_needed() {
  if [ -d "$PACKAGE_DIR/skills/$SKILL_NAME" ]; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required for one-command remote installation." >&2
    exit 1
  fi
  if ! command -v tar >/dev/null 2>&1; then
    echo "Error: tar is required for one-command remote installation." >&2
    exit 1
  fi

  TEMP_DIR="$(mktemp -d)"
  echo "Downloading $REPO@$REF..."
  curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" | tar -xz -C "$TEMP_DIR" --strip-components=1
  PACKAGE_DIR="$TEMP_DIR"

  if [ ! -d "$PACKAGE_DIR/skills/$SKILL_NAME" ]; then
    echo "Error: downloaded package does not contain skills/$SKILL_NAME." >&2
    exit 1
  fi
}

bootstrap_package_if_needed

SKILL_SRC="$PACKAGE_DIR/skills/$SKILL_NAME"
CODEX_RULES_SRC="$PACKAGE_DIR/codex/AGENTS.md"
CLAUDE_FRAGMENT_SRC="$PACKAGE_DIR/CLAUDE.md.fragment"
GEMINI_FRAGMENT_SRC="$PACKAGE_DIR/GEMINI.md.fragment"

require_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "Error: missing required file: $file" >&2
    exit 1
  fi
}

require_file "$SKILL_SRC/SKILL.md"
require_file "$CODEX_RULES_SRC"
require_file "$CLAUDE_FRAGMENT_SRC"
require_file "$GEMINI_FRAGMENT_SRC"

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
    echo "Usage: install.sh [claude-code|codex|antigravity|all]" >&2
    exit 1
    ;;
esac

echo "Done. Restart the agent app/CLI if it was already open."
