---
name: rtl-agent-output-fixer
description: Format Hebrew, Arabic, Persian, or Yiddish agent replies so they render correctly in coding-agent chats and terminals. Use whenever the user writes in an RTL language, asks for Hebrew/Arabic/Persian/Yiddish output, reports RTL rendering issues, or asks for mixed RTL/LTR text, code, tables, or documentation.
---

# RTL Agent Output Fixer

## Goal

Make the agent's own final answers readable in right-to-left languages inside coding-agent chats, terminals, and IDE panels without modifying the host UI.

This skill is an output-formatting skill. It does not install browser extensions, edit application CSS, inject JavaScript, or modify Claude Code/Codex/Antigravity UI. It only controls how the agent writes its own responses.

## When to use

Use this skill when any of these are true:

- The user writes in Hebrew, Arabic, Persian, or Yiddish.
- The user asks for output in Hebrew, Arabic, Persian, or Yiddish.
- The response contains substantial RTL prose mixed with English, code, paths, filenames, commands, issue keys, URLs, JSON, YAML, or tables.
- The user says RTL text is reversed, misaligned, visually broken, or hard to read.

Do not use this skill for purely English responses unless the user explicitly asks for RTL-safe formatting.

## Output contract

For Markdown-capable clients, wrap RTL prose blocks in HTML direction containers:

```html
<div dir="rtl" align="right">
טקסט בעברית כאן.
</div>
```

Keep code blocks, commands, logs, JSON, YAML, file paths, and diffs outside RTL containers so they remain LTR:

```js
const value = "example";
console.log(value);
```

Then reopen the RTL container for continued prose.

## Core formatting rules

1. Use `dir="rtl"` and `align="right"` only on the agent's own prose containers.
2. Never wrap fenced code blocks inside RTL containers.
3. Keep inline code, filenames, commands, URLs, issue keys, branch names, package names, and identifiers inside backticks.
4. Prefer bullets or numbered steps over wide Markdown tables for mixed RTL/LTR content. Tables are fragile in terminals.
5. If a table is necessary, prefer an HTML table with `dir="rtl"` on the table and `dir="ltr"` on cells that contain commands, paths, code, or English identifiers.
6. Do not insert invisible Unicode bidi control characters by default. They are hard to review and may create security confusion in code or logs.
7. If the user specifically asks for plain-text-only output, use simple visual structure instead of HTML wrappers. Keep LTR tokens in backticks and avoid tables.
8. Do not alter code semantics to solve visual direction problems.
9. Do not add CSS or scripts unless the user explicitly asks to modify a project file.
10. Do not claim this fixes the entire IDE or terminal UI. It only makes the agent's own output more direction-safe.

## Recommended response pattern for Hebrew answers

Use this shape:

```markdown
<div dir="rtl" align="right">

הסבר בעברית...

1. שלב ראשון עם `npm run build` בתוך backticks.
2. שלב שני עם שם קובץ כמו `src/content.js`.

</div>

```bash
npm run build
```

<div dir="rtl" align="right">

המשך ההסבר בעברית אחרי הקוד.

</div>
```

## Mixed RTL/LTR examples

Bad:

```markdown
תפתח את src/content.js ותריץ npm run build ואז תבדוק CLAUDE-123.
```

Good:

```markdown
<div dir="rtl" align="right">

תפתח את `src/content.js`, תריץ `npm run build`, ואז תבדוק את `CLAUDE-123`.

</div>
```

## Code block example

When the user asks in Hebrew for a command:

```markdown
<div dir="rtl" align="right">

תריץ את הפקודה הזו מתוך תיקיית הפרויקט:

</div>

```bash
npm run build
```

<div dir="rtl" align="right">

אם מתקבלת שגיאה, שלח את הפלט המלא כמו שהוא.

</div>
```

## HTML table example

Use only when a table is really useful:

```html
<table dir="rtl">
  <thead>
    <tr>
      <th>שלב</th>
      <th>מה עושים</th>
      <th dir="ltr">Command / File</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>פתיחת קובץ ההגדרות</td>
      <td dir="ltr"><code>src/content.js</code></td>
    </tr>
  </tbody>
</table>
```

## Plain-text fallback

If HTML is not supported or the user requests plain text only:

- Keep the answer simple.
- Put LTR tokens in backticks.
- Put commands in separate fenced blocks.
- Avoid Markdown tables.
- Use short lines.

Example:

```markdown
מה לעשות:
1. פתח את `src/content.js`.
2. בדוק את `CLAUDE-123`.
3. הרץ:

```bash
npm run build
```
```

## Security rules

- Never use Unicode bidi override characters in code, logs, shell commands, JSON, YAML, diffs, or filenames.
- Do not hide or reorder security-relevant text with invisible characters.
- Prefer visible Markdown/HTML direction attributes over invisible controls.
- Do not make network calls.
- Do not read or write files unless the user explicitly asks you to modify a repository or install this skill.
