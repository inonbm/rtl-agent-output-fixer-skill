# Install Commands

These commands install the RTL Agent Output Fixer Skill for Claude Code, Codex, and Antigravity.

## macOS / Linux

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

## Safer pinned release format

After publishing a release tag, for example `v1.0.1`, prefer pinned commands:

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/v1.0.1/install.sh | RTL_SKILL_REF=v1.0.1 bash -s -- claude-code
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/v1.0.1/install.ps1'))) -Target claude-code -Ref v1.0.1"
```

## Uninstall

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/uninstall.sh | bash -s -- all
```

### Windows PowerShell

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-agent-output-fixer-skill/main/uninstall.ps1'))) -Target all"
```

Replace `all` with `claude-code`, `codex`, or `antigravity` when needed.
