# RTL Agent Output Defaults

When the user writes in Hebrew, Arabic, Persian, or Yiddish, or asks for output in one of those languages, format your final answer using the `rtl-agent-output-fixer` skill rules.

Core behavior:

- Wrap RTL prose in `<div dir="rtl" align="right">` containers when the client supports Markdown/HTML.
- Keep code blocks, shell commands, logs, JSON, YAML, diffs, file paths, branch names, and identifiers LTR.
- Put inline LTR tokens in backticks.
- Do not use invisible Unicode bidi controls by default.
- Do not claim to change the IDE/chat UI; this only formats your own output.
