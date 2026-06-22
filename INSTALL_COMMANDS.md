# Install Commands

Replace `v1.1.0` with the release tag you publish.

## macOS / Linux

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

## Windows PowerShell

Claude Code:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-skill-installer/v1.1.0/install.ps1'))) -Target claude-code"
```

Codex:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-skill-installer/v1.1.0/install.ps1'))) -Target codex"
```

Antigravity:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/inonbm/rtl-skill-installer/v1.1.0/install.ps1'))) -Target antigravity"
```
