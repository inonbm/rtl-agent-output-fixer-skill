# RTL Agent Output Fixer Skill

This package installs an agent-side RTL formatting skill for Claude Code, Codex, and Antigravity.

It is not a Chrome extension. It does not modify the host UI. It makes the agent's own answers more readable when using Hebrew, Arabic, Persian, or Yiddish by wrapping RTL prose with direction-aware Markdown/HTML and keeping code/commands LTR.

## Install

Claude Code:

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-skill-installer/v1.1.0/install.sh | bash -s -- claude-code
```

Codex:

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-skill-installer/v1.1.0/install.sh | bash -s -- codex
```

Antigravity:

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-skill-installer/v1.1.0/install.sh | bash -s -- antigravity
```

All:

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-skill-installer/v1.1.0/install.sh | bash -s -- all
```

Windows PowerShell example:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-skill-installer/v1.1.0/install.ps1'))) -Target claude-code"
```

## What it installs

- `rtl-agent-output-fixer` skill under the relevant skills directory.
- Always-on formatting rules for the selected tool:
  - Claude Code: `~/.claude/CLAUDE.md`
  - Codex: `~/.codex/AGENTS.md`
  - Antigravity/Gemini: `~/.gemini/GEMINI.md`

Existing files are backed up before modification.

## Test prompt

After installation, restart the agent and write in Hebrew:

```text
תענה לי בעברית ותשלב פקודת npm, שם קובץ וטבלת צעדים קצרה.
```

Expected result: Hebrew prose should be wrapped RTL, while commands and filenames remain LTR.
