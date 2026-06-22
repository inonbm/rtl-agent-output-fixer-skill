# Security Audit — RTL Agent Output Fixer Skill

## Scope

Reviewed package files:

- `install.sh`
- `install.ps1`
- `skills/rtl-agent-output-fixer/SKILL.md`
- `codex/AGENTS.md`
- `CLAUDE.md.fragment`
- `GEMINI.md.fragment`

## Summary

Risk level: Low to Medium.

The package is instruction-only. It does not include executable helper scripts inside the skill itself. The installers write local instruction files and copy the skill into local agent skill directories.

## Positive findings

- No `sudo` usage.
- No package installation.
- No credential handling.
- No telemetry or analytics.
- No network calls after the installer has been downloaded.
- No destructive file deletion except replacing this package's own skill directory.
- Existing instruction files are backed up before modification.
- The skill explicitly forbids invisible Unicode bidi controls in code, logs, commands, JSON, YAML, diffs, and filenames.

## Main risks

1. `curl | bash` / `irm | powershell` executes remote code. Use pinned tags and checksums for safer distribution.
2. The installer appends global instructions to agent configuration files. This is intentional for always-on RTL behavior, but it can affect all future agent responses.
3. Skills are natural-language instructions. A malicious future update could steer the agent toward unsafe behavior. Review diffs before release.

## Recommended controls

- Publish releases by immutable tag, not `main`.
- Add SHA-256 hashes to release notes.
- Keep the skill instruction-only; avoid helper scripts unless necessary.
- Use clear begin/end markers for installed config blocks.
- Offer uninstall instructions in future versions.
