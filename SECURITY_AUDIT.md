# Security Audit — RTL Agent Output Fixer Skill

## Scope

Reviewed package files:

- `install.sh`
- `install.ps1`
- `uninstall.sh`
- `uninstall.ps1`
- `skills/rtl-agent-output-fixer/SKILL.md`
- `codex/AGENTS.md`
- `CLAUDE.md.fragment`
- `GEMINI.md.fragment`

## Summary

Risk level: Low to Medium.

The skill itself is instruction-only. It does not include executable helper scripts inside the installed skill directory. The installers copy the skill into local agent skill directories and append marked RTL formatting rules to local agent instruction files.

## Positive findings

- No `sudo` usage.
- No package installation.
- No credential handling.
- No telemetry or analytics.
- No runtime analytics or tracking.
- No destructive file deletion outside this package's own installed skill directories.
- Existing instruction files are backed up before modification.
- Installed config blocks use clear begin/end markers.
- Uninstall scripts remove only this skill and the marked RTL config block.
- The skill explicitly forbids invisible Unicode bidi controls in code, logs, commands, JSON, YAML, diffs, and filenames.

## Installer behavior

The installers support two modes:

1. Local mode: run from a cloned/downloaded repository directory.
2. One-command remote mode: when streamed through `curl | bash` or `irm | powershell`, the installer downloads the repository archive for the selected ref into a temporary directory, installs from it, then removes the temporary directory.

The default remote ref is `main`. For safer public distribution, use a pinned release tag and pass it through `RTL_SKILL_REF` on macOS/Linux or `-Ref` on Windows.

## Main risks

1. `curl | bash` / `irm | powershell` executes remote code. Use pinned tags and SHA-256 hashes for safer public distribution.
2. The installer appends global instructions to agent configuration files. This is intentional for always-on RTL behavior, but it can affect all future agent responses.
3. Skills are natural-language instructions. A malicious future update could steer the agent toward unsafe behavior. Review diffs before release.
4. The remote installer downloads a GitHub archive. If using `main`, users receive the latest repository state rather than an immutable release.

## Recommended controls

- Publish public releases by immutable tag instead of distributing `main` commands.
- Add SHA-256 hashes to release notes for `install.sh`, `install.ps1`, `uninstall.sh`, and `uninstall.ps1`.
- Keep the installed skill instruction-only; avoid helper scripts inside the skill directory unless necessary.
- Review all diffs before creating a new release tag.
- Keep uninstall instructions visible in `README.md`.
