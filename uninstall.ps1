param(
  [ValidateSet('claude-code','claude','codex','antigravity','gemini','all')]
  [string]$Target = 'all'
)

$ErrorActionPreference = 'Stop'
$SkillName = 'rtl-agent-output-fixer'
$StartMark = '<!-- rtl-agent-output-fixer:start -->'
$EndMark = '<!-- rtl-agent-output-fixer:end -->'

function Remove-Skill {
  param([string]$DestRoot)
  $Path = Join-Path $DestRoot $SkillName
  if (Test-Path $Path) {
    Remove-Item -Recurse -Force $Path
    Write-Host "Removed skill: $Path"
  } else {
    Write-Host "Skill not found: $Path"
  }
}

function Remove-Block {
  param([string]$File)
  if (-not (Test-Path $File)) {
    Write-Host "Config not found: $File"
    return
  }
  $Content = Get-Content -Raw -Path $File
  if ($Content -notlike "*$StartMark*") {
    Write-Host "No RTL block found in: $File"
    return
  }
  $Backup = "$File.bak.$(Get-Date -Format yyyyMMddHHmmss)"
  Copy-Item -Path $File -Destination $Backup
  $Pattern = [regex]::Escape($StartMark) + '(?s).*?' + [regex]::Escape($EndMark) + '\r?\n?'
  $Updated = [regex]::Replace($Content, $Pattern, '')
  Set-Content -Path $File -Value $Updated -Encoding UTF8
  Write-Host "Removed RTL rules from: $File"
}

function Uninstall-Claude {
  $Base = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
  Remove-Skill (Join-Path $Base 'skills')
  Remove-Block (Join-Path $Base 'CLAUDE.md')
}

function Uninstall-Codex {
  Remove-Skill (Join-Path $HOME '.agents/skills')
  Remove-Block (Join-Path $HOME '.codex/AGENTS.md')
}

function Uninstall-Antigravity {
  Remove-Skill (Join-Path $HOME '.agents/skills')
  Remove-Skill (Join-Path $HOME '.gemini/antigravity-cli/skills')
  Remove-Block (Join-Path $HOME '.gemini/GEMINI.md')
}

switch ($Target) {
  'claude-code' { Uninstall-Claude }
  'claude' { Uninstall-Claude }
  'codex' { Uninstall-Codex }
  'antigravity' { Uninstall-Antigravity }
  'gemini' { Uninstall-Antigravity }
  'all' { Uninstall-Claude; Uninstall-Codex; Uninstall-Antigravity }
}

Write-Host 'Done. Restart the agent app/CLI if it was already open.'
