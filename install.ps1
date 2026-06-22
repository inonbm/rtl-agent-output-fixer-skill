param(
  [ValidateSet('claude-code','claude','codex','antigravity','gemini','all')]
  [string]$Target = 'all',
  [string]$Ref = $env:RTL_SKILL_REF
)

$ErrorActionPreference = 'Stop'
$SkillName = 'rtl-agent-output-fixer'
$Repo = 'inonbm/rtl-agent-output-fixer-skill'
if ([string]::IsNullOrWhiteSpace($Ref)) { $Ref = 'main' }
$StartMark = '<!-- rtl-agent-output-fixer:start -->'
$EndMark = '<!-- rtl-agent-output-fixer:end -->'
$TempDir = $null

function Get-ScriptDirectory {
  if ($PSCommandPath) {
    return Split-Path -Parent $PSCommandPath
  }
  if ($MyInvocation.MyCommand.Path) {
    return Split-Path -Parent $MyInvocation.MyCommand.Path
  }
  return (Get-Location).Path
}

$PackageDir = Get-ScriptDirectory

function Initialize-PackageIfNeeded {
  $LocalSkill = Join-Path $PackageDir "skills/$SkillName"
  if (Test-Path $LocalSkill) { return }

  $script:TempDir = Join-Path $env:TEMP ("rtl-agent-output-fixer-" + [guid]::NewGuid().ToString())
  New-Item -ItemType Directory -Force -Path $script:TempDir | Out-Null
  $ZipPath = Join-Path $script:TempDir 'package.zip'
  $ExtractPath = Join-Path $script:TempDir 'extract'
  New-Item -ItemType Directory -Force -Path $ExtractPath | Out-Null

  $Url = "https://github.com/$Repo/archive/$Ref.zip"
  Write-Host "Downloading $Repo@$Ref..."
  Invoke-WebRequest -Uri $Url -OutFile $ZipPath -UseBasicParsing
  Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

  $Root = Get-ChildItem -Path $ExtractPath -Directory | Select-Object -First 1
  if (-not $Root) { throw 'Downloaded package could not be extracted.' }
  $script:PackageDir = $Root.FullName

  $DownloadedSkill = Join-Path $script:PackageDir "skills/$SkillName"
  if (-not (Test-Path $DownloadedSkill)) {
    throw "Downloaded package does not contain skills/$SkillName."
  }
}

try {
  Initialize-PackageIfNeeded

  $SkillSrc = Join-Path $PackageDir "skills/$SkillName"
  $CodexRulesSrc = Join-Path $PackageDir 'codex/AGENTS.md'
  $ClaudeFragmentSrc = Join-Path $PackageDir 'CLAUDE.md.fragment'
  $GeminiFragmentSrc = Join-Path $PackageDir 'GEMINI.md.fragment'

  foreach ($Required in @((Join-Path $SkillSrc 'SKILL.md'), $CodexRulesSrc, $ClaudeFragmentSrc, $GeminiFragmentSrc)) {
    if (-not (Test-Path $Required)) { throw "Missing required file: $Required" }
  }

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
}
finally {
  if ($TempDir -and (Test-Path $TempDir)) {
    Remove-Item -Recurse -Force $TempDir
  }
}
