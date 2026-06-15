---
description: Triage Sentry crashes for an iOS release into Linear tickets
model: opus
---

USE EXTENDED THINKING

Run the `sentry-triage` skill at `.claude/skills/sentry-triage/SKILL.md`.

User args (may be empty): `$ARGUMENTS`

Parse args per the skill's Invocation table:
- First positional arg: release version (e.g. `0.46.0`). If absent, use the latest production release.
- Second positional arg: environment (`production` or `development`). Default `production`.
- `--include-errors` flag: widen from `level:fatal` to `level:[fatal,error]`.

Then follow the skill's Workflow section step by step. Print the final summary table to chat when done.
