param(
  [ValidateSet('claude-code','claude','codex','antigravity','gemini','all')]
  [string]$Target = 'all'
)

$ErrorActionPreference = 'Stop'
$SkillName = 'rtl-agent-output-fixer'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillSrc = Join-Path $ScriptDir "skills/$SkillName"
$CodexRulesSrc = Join-Path $ScriptDir 'codex/AGENTS.md'
$ClaudeFragmentSrc = Join-Path $ScriptDir 'CLAUDE.md.fragment'
$GeminiFragmentSrc = Join-Path $ScriptDir 'GEMINI.md.fragment'
$StartMark = '<!-- rtl-agent-output-fixer:start -->'
$EndMark = '<!-- rtl-agent-output-fixer:end -->'

function Copy-Skill {
  param([string]$DestRoot)
  New-Item -ItemType Directory -Force -Path $DestRoot | Out-Null
  $Dest = Join-Path $DestRoot $SkillName
  if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
  Copy-Item -Recurse -Path $SkillSrc -Destination $Dest
  Write-Host "Installed skill: $Dest"
}

function Add-BlockOnce {
  param([string]$File, [string]$Fragment, [string]$Title)
  $Dir = Split-Path -Parent $File
  New-Item -ItemType Directory -Force -Path $Dir | Out-Null
  if (-not (Test-Path $File)) { New-Item -ItemType File -Path $File | Out-Null }
  $Content = Get-Content -Raw -Path $File
  if ($Content -like "*$StartMark*") {
    Write-Host "Already configured: $File"
    return
  }
  $Backup = "$File.bak.$(Get-Date -Format yyyyMMddHHmmss)"
  Copy-Item -Path $File -Destination $Backup
  $FragmentContent = Get-Content -Raw -Path $Fragment
  Add-Content -Path $File -Value "`n$StartMark`n$FragmentContent`n$EndMark`n" -Encoding UTF8
  Write-Host "Added always-on RTL rules to $Title: $File"
}

function Install-Claude {
  $Base = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
  Copy-Skill (Join-Path $Base 'skills')
  Add-BlockOnce (Join-Path $Base 'CLAUDE.md') $ClaudeFragmentSrc 'Claude Code'
}

function Install-Codex {
  Copy-Skill (Join-Path $HOME '.agents/skills')
  Add-BlockOnce (Join-Path $HOME '.codex/AGENTS.md') $CodexRulesSrc 'Codex'
}

function Install-Antigravity {
  Copy-Skill (Join-Path $HOME '.agents/skills')
  Copy-Skill (Join-Path $HOME '.gemini/antigravity-cli/skills')
  Add-BlockOnce (Join-Path $HOME '.gemini/GEMINI.md') $GeminiFragmentSrc 'Antigravity/Gemini'
}

switch ($Target) {
  'claude-code' { Install-Claude }
  'claude' { Install-Claude }
  'codex' { Install-Codex }
  'antigravity' { Install-Antigravity }
  'gemini' { Install-Antigravity }
  'all' { Install-Claude; Install-Codex; Install-Antigravity }
}

Write-Host 'Done. Restart the agent app/CLI if it was already open.'
