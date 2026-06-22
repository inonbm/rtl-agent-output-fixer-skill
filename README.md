# RTL Agent Output Fixer Skill

Agent-side RTL output formatting for Claude Code, Codex, and Antigravity.

This is **not** a Chrome extension. It does **not** modify the host UI, inject CSS, or change the app layout. It helps the agent write Hebrew, Arabic, Persian, or Yiddish answers in a direction-safe format by wrapping RTL prose and keeping code, commands, paths, filenames, URLs, and logs LTR.

## What it does

- Installs the `rtl-agent-output-fixer` skill.
- Adds always-on local instructions for the selected agent tool.
- Keeps code blocks and commands LTR.
- Uses visible Markdown/HTML direction wrappers instead of invisible Unicode bidi controls.
- Creates backups before editing existing local instruction files.

## Requirements

- macOS / Linux: `curl` and `tar`.
- Windows: PowerShell 5.1+.
- Restart the agent app/CLI after installation.

## Install

### Claude Code

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/install.sh | bash -s -- claude-code
```

### Codex

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/install.sh | bash -s -- codex
```

### Antigravity

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/install.sh | bash -s -- antigravity
```

### All supported tools

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/install.sh | bash -s -- all
```

## Windows PowerShell

### Claude Code

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/install.ps1'))) -Target claude-code"
```

### Codex

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/install.ps1'))) -Target codex"
```

### Antigravity

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/install.ps1'))) -Target antigravity"
```

### All supported tools

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/install.ps1'))) -Target all"
```

## Safer pinned release install

For public distribution, prefer a fixed release tag instead of `main`.

After publishing a release, for example `v1.0.1`, use:

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/v1.0.1/install.sh | RTL_SKILL_REF=v1.0.1 bash -s -- claude-code
```

The `RTL_SKILL_REF` value tells the remote installer which full package archive to download.

## What gets changed locally

The installer copies the skill and appends a marked instruction block to the relevant local config file:

- Claude Code skill: `~/.claude/skills/rtl-agent-output-fixer/`
- Claude Code rules: `~/.claude/CLAUDE.md`
- Codex skill: `~/.agents/skills/rtl-agent-output-fixer/`
- Codex rules: `~/.codex/AGENTS.md`
- Antigravity/Gemini skill: `~/.agents/skills/rtl-agent-output-fixer/` and `~/.gemini/antigravity-cli/skills/rtl-agent-output-fixer/`
- Antigravity/Gemini rules: `~/.gemini/GEMINI.md`

Existing config files are backed up before modification.

## Test prompt

After installation, restart the agent and write:

```text
Use the rtl-agent-output-fixer skill. תענה לי בעברית ותשלב פקודת npm, שם קובץ וטבלת צעדים קצרה.
```

Expected result: Hebrew prose should be wrapped RTL, while commands and filenames remain LTR.

## Uninstall

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/uninstall.sh | bash -s -- all
```

### Windows PowerShell

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/uninstall.ps1'))) -Target all"
```

You can replace `all` with `claude-code`, `codex`, or `antigravity`.

## Security

See [`SECURITY_AUDIT.md`](SECURITY_AUDIT.md). The main risk is the convenience install style (`curl | bash` / `irm | powershell`), which executes remote code. For public release, use pinned tags and publish SHA-256 hashes.
