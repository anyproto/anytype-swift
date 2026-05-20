---
name: sentry-triage
description: Triage Sentry crashes for an iOS release. Pulls unresolved fatal events from sentry.anytype.io, investigates each fingerprint cluster against the source, creates one Linear ticket per cluster with a root-cause hypothesis (no proposed fix - the implementer figures that out with full context), then archives the Sentry issue (status `ignored`) so it stops cluttering the inbox. Activate on "triage Sentry crashes", "triage fatal errors", "investigate crashes in release", "fatal errors in 0.X.Y", or any time the user wants to turn a release's Sentry inbox into actionable Linear tickets. The slash entry is `/do-sentry-triage`.
user-invocable: false
---

# Sentry Triage

## Purpose
Turn a release's unresolved Sentry crashes into actionable Linear tickets in one pass. The user ships a release, opens this skill, and gets back a list of Linear tickets - one per crash fingerprint - each carrying enough context (stack trace, suspect code, root-cause hypothesis from source reading, Sentry permalink, resolve footer) that picking up the fix is a single regular PR.

**No proposed fix in the ticket.** Triage is a fast survey across many clusters; the triager does not have enough implementation context to propose a fix that's actually right. Empirically the proposed-fix block in older versions of this skill was wrong nearly every time and biased the eventual implementer toward the wrong approach. The implementer reads the hypothesis + stack + source themselves and decides the fix with full context.

## When to Use
- After a TestFlight or production release where Sentry shows fatal events
- When the user types `/do-sentry-triage` (with or without args)
- When the user says "triage crashes", "go through Sentry fatals", "what's broken in 0.X.Y"
- Any time the user wants a release's Sentry inbox turned into Linear work

## Anytype iOS context (hardcoded constants)

The skill is project-scoped, so these don't need lookup at runtime:
- **Sentry host**: `sentry.anytype.io` (self-hosted)
- **Organization slug**: `anytype`
- **Project slug**: `ios`
- **Linear team key**: `iOS`
- **Release name format**:
  - Production: `io.anytype.app@<version>+<build>` (App Store)
  - Development: `io.anytype.app.dev@<version>+<build>` (TestFlight nightly)

## Prerequisites (one-time)

1. Sentry auth token from `https://sentry.anytype.io` (User Settings -> Auth Tokens). Required scopes: `org:read`, `project:read`, `project:releases`, `event:read`, `event:write`.
2. MCP server wired at user scope:
   ```
   claude mcp add --scope user sentry -- npx -y @sentry/mcp-server@latest \
     --access-token=$SENTRY_TOKEN --host=sentry.anytype.io
   ```
   Verify with `/mcp` - `sentry` should be listed and connected.
3. `linctl` authenticated (`linctl auth`) - see `.claude/skills/linear-developer/SKILL.md`.

If the MCP isn't connected when the skill runs, stop and tell the user. The MCP tools we use are `mcp__sentry__find_releases`, `mcp__sentry__list_issues`, `mcp__sentry__get_sentry_resource`, `mcp__sentry__update_issue`.

## Self-hosted Sentry quirks (these are not bugs - know them up front)

- **Seer is unavailable**: `analyze_issue_with_seer` returns 404 on `sentry.anytype.io`. Don't call it. The skill works fine on stack + source reading alone.
- **`ignoreMode='untilEscalating'` resolves to "Forever"**: self-hosted maps the Sentry-Cloud-only ignore modes to `Forever`. The issue still leaves the unresolved inbox, which is the goal. The `Fixes <shortId>` commit footer still auto-resolves on next release.
- **`assignedTo` field is not used in this org**. Don't read it, don't filter on it, don't mention it in tickets.

## Invocation

| Form | Behavior |
|------|----------|
| `/do-sentry-triage` | Latest production release in Sentry, fatal only |
| `/do-sentry-triage 0.46.0` | Specific version, production env, fatal only |
| `/do-sentry-triage 0.46.0 development` | Same version, development env (TestFlight) |
| `/do-sentry-triage 0.46.0 --include-errors` | Fatal + error level |
| `/do-sentry-triage --include-errors` | Latest production, fatal + error |

Parse args off the user message. Default env is `production`. Default severity is `level:fatal`. `--include-errors` widens to `level:[fatal,error]`.

## Workflow

### Step 1: Resolve the full release name

The full release name is what Sentry's `release:` query filter expects, e.g. `io.anytype.app@0.46.1+6`. Construct it:

- **Env-based prefix**:
  - production -> `io.anytype.app@`
  - development -> `io.anytype.app.dev@`
- **If the user gave a version with a build (e.g. `0.46.1+6`)**: concatenate `<prefix><version>+<build>` and use that.
- **If the user gave only a version (`0.46.1`)**: call `mcp__sentry__find_releases(organizationSlug='anytype', projectSlug='ios', query='<prefix><version>')` and pick the highest `+N` build.
- **If the user gave nothing**: call `mcp__sentry__find_releases(organizationSlug='anytype', projectSlug='ios')` and pick the most recent release whose name starts with the env prefix.

If no matching release is found, stop and ask the user.

### Step 2: Query unresolved crashes

```
mcp__sentry__list_issues(
  organizationSlug='anytype',
  projectSlugOrId='ios',
  query='is:unresolved level:fatal release:<FULL_RELEASE_NAME>',  # or level:[fatal,error]
  sort='freq',
  limit=20
)
```

Capture per cluster: `shortId`, `permalink`, `title`, `culprit`, `level`, `firstSeen`, `lastSeen`, `count`, `userCount`.

If empty, print `No unresolved <severity> in <RELEASE>` and exit.

If 20 come back, note "more may exist - re-run after handling these" in the final summary.

### Step 3: Idempotency check (Linear-side)

**Critical:** Linear's team prefix is also `IOS`, so `linctl issue search "IOS-93H"` matches Linear's own ticket IOS-93H, not Sentry references. Search by **Sentry permalink** instead:

```
linctl issue search "issues/<shortId>" --json
```

Or use the full permalink. If a Linear ticket already references that permalink in its body, skip the cluster and record "already triaged" in the final summary.

### Step 4: Investigate each remaining cluster

For each cluster:

1. **Fetch full issue + latest event in one call**: `mcp__sentry__get_sentry_resource(url=<permalink>)`. This returns the issue metadata, the latest event, and the full stack trace in one response. Do **not** use `list_issue_events` - it returns summaries without stacks.

2. **Classify** by where the crash happened:
   - **Swift / iOS-side**: top frames in `Anytype/Sources/` or `Modules/`. Proceed to read source.
   - **Middleware / Go-side**: stack is entirely `github.com/anyproto/anytype-heart/...`. Skip source-reading; the ticket exists to route to the middleware team.
   - **Watchdog / no-stack**: `mechanism: watchdog_termination` or `Stacktrace: No stacktrace available`. No specific code site; ticket describes the symptom only.
   - **Symbolication failure**: hex addresses instead of names. Note dSYM upload status, recommend re-upload.

3. **For Swift-side clusters**: read source at the top app frame's `file:line` (skip `Pods/`, system frameworks, `<compiler-generated>` - walk up to the first app frame). Read ~30 lines for context. Walk up the stack as needed to follow the call chain.

4. **Form your hypothesis** in one or two sentences. Be honest about uncertainty: "likely a force-unwrap when X is nil after Y" beats "the bug is on line 42".

Stop at the hypothesis. Do **not** write a proposed fix, a corrected snippet, or "the fix is to do X" guidance into the ticket. Triage is a fast survey; you don't have the implementation context to propose a fix that's actually correct, and a wrong proposal anchors the implementer toward the wrong approach (this was observed across ~15 fixes - the proposed-fix block was wrong nearly every time). The hypothesis + stack + source links are enough; the implementer reads them with full context and decides the fix themselves.

### Step 5: Create the Linear ticket

```
linctl issue create --team iOS --title "<TITLE>" --description "<BODY>" --json
```

**Do not pass `--labels`**. The title prefix carries the categorization signal:
- Swift / iOS-side bug: `[Sentry] <error_type> in <top_app_frame>`
- Middleware / Go-side bug: `[Sentry][Middleware] <error_type> in <go_path>`

Capture the returned `IOS-XXXX` identifier and Linear URL from the JSON output (it can be long; pipe through `jq -r '.identifier'` to extract just the ID).

Body must follow the template in the next section verbatim - same headings, same order. Same structure across tickets is what makes the inbox scannable when there are five at once.

### Step 6: Archive the Sentry issue

```
mcp__sentry__update_issue(
  organizationSlug='anytype',
  issueId=<shortId>,
  status='ignored',
  ignoreMode='untilEscalating'
)
```

On self-hosted this resolves to `Forever` (see Quirks); the issue still leaves the inbox, which is the goal.

If the update fails (network, permission), continue without it - the Linear ticket already exists. Log the failure for the final summary.

### Step 7: Final summary

Print a markdown table to chat:

```
| Linear | Sentry | Title | Events / Users | Hypothesis |
|--------|--------|-------|----------------|------------|
| IOS-6178 | IOS-59D | Spreadsheet selectItem OOB section | 293 / 10 | re-selection uses pre-snapshot indexPaths; clamp to new section count |
```

Always include a final line summarizing skips: clusters already triaged (Linear hit in Step 3), Sentry status-update failures, and whether the 20-cluster cap was hit.

## Linear ticket template

**Title** (no labels - title prefix is the only categorization):
- Swift / iOS-side: `[Sentry] <error_type> in <top_app_frame>`
- Middleware / Go-side: `[Sentry][Middleware] <error_type> in <go_path>`

**Body for Swift / iOS-side bugs**:

```markdown
## Summary
<one or two sentence root-cause hypothesis - what likely went wrong, not how to fix it>

## Sentry data
- Issue: <permalink>
- Short ID: `<shortId>`
- First seen: <ISO timestamp>
- Last seen: <ISO timestamp>
- Affected release: <full release name>
- Environment: <production|development>
- Events: <count> / Users: <userCount>
- Top device: <device tag>
- Top OS: <os tag>

## Stack (app frames only)
\```
<top 5-10 frames inside Anytype/Sources or Modules, with file:line>
\```

---
**Resolve on merge**: include `Fixes <shortId>` in the fix commit. Sentry CI auto-resolves on the next release containing the commit.
```

**Body for middleware / Go-side bugs** - prepend a Routing block:

```markdown
## Routing
**This crash is in Go middleware (`anytype-heart` v<X.Y.Z>), not iOS Swift code.** Please route to the middleware team.

## Summary
<symptom + Go-side hypothesis - what likely went wrong, not how to fix it>

## Sentry data
... (same fields as Swift template)

## Stack (Go runtime)
\```
github.com/anyproto/anytype-heart/<...>:line
\```

---
**Resolve on merge**: middleware fix lands in `anytype-heart`, then iOS bumps the middleware version. Include `Fixes <shortId>` in the bump commit message.
```

**Body for watchdog / stackless events**:

```markdown
## Summary
<symptom - OOM, hang, etc.>. No stack available; this is a profiling task, not a code-fix task. The implementer will need to instrument and reproduce to find the underlying pressure source.

## Sentry data
... (same fields)

## Stack
`No stacktrace available` - <mechanism> events don't capture call stacks.

---
**Resolve on merge**: include `Fixes <shortId>` in any commit that meaningfully reduces the underlying pressure (memory, main-thread blocking, etc.).
```

The `Fixes <shortId>` footer is load-bearing - the auto-resolve loop only works if the commit message contains it exactly. Use the **Sentry short ID** (e.g. `IOS-93H`), not the Linear ID.

## Idempotency

Re-running the skill on the same release is safe:
1. Step 6 sets handled clusters to ignored, so the next run's `is:unresolved` query won't return them.
2. Step 3 cross-checks Linear by Sentry **permalink** before any expensive work. (Don't search by short ID - Linear's `IOS-` prefix collides with Sentry's.)

## Edge cases

- **Crash inside Go middleware**: stack is entirely `github.com/anyproto/anytype-heart/...`. Use the `[Sentry][Middleware]` title prefix and the routing block. Don't read iOS source.
- **WatchdogTermination / no stack**: use the watchdog body template. Describe the symptom only - don't fabricate a fix or prescribe specific instrumentation steps.
- **Symbolication failure**: hex addresses instead of names. Mention dSYM upload status in the ticket.
- **Same fingerprint, different versions**: Sentry groups by fingerprint across releases. The release filter narrows to the current one, but `firstSeen` may predate it. Call that out so the user knows it's recurring, not a regression.
- **Top frame in `<compiler-generated>`**: Swift trap from `Array._checkIndex`, `range`, `Optional.unsafelyUnwrapped`. Walk up the stack to the first app frame; that's the call site.
- **No fatal events found**: print "No unresolved fatals in <release>" and exit. Don't widen severity automatically; that's what `--include-errors` is for.
- **Sentry MCP times out**: stop, surface the error, suggest `/mcp` and checking the token.

## What this skill does NOT do

- Write code or open PRs - only triage tickets
- Resolve Sentry issues - that happens automatically on the next release that contains a `Fixes <shortId>` commit, via the existing sentry-cli pipeline
- Run on a schedule - interactive only
- Triage warnings or non-crash events unless `--include-errors` is passed
- Use Linear labels - title prefix carries the categorization
- Read or filter on the Sentry `assignedTo` field - it's not used by this team

## Related skills
- `linear-developer` - linctl command reference for ticket creation
- `confidence-check` - run before *implementing* the fix, not during triage
- `ios-dev-guidelines` - context when reading Swift source to form a hypothesis
