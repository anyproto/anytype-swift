# Apple Documentation Lookup

Smart router to Apple Developer documentation using the `sosumi` CLI.

## When Auto-Activated

- Looking up Apple framework APIs (SwiftUI, UIKit, Foundation, Combine, etc.)
- Checking method signatures, availability, or deprecation status
- Exploring new iOS/macOS APIs (WWDC sessions, new frameworks)
- Verifying Swift standard library behavior
- Answering "how does X work in SwiftUI/UIKit?" questions

## Tool: sosumi CLI

Installed globally via `npm install -g @nshipster/sosumi`.

Fetches Apple Developer documentation and WWDC video transcripts as LLM-readable Markdown.

## Commands

### Search for documentation

```bash
sosumi search "query" [--json]
```

- Returns matching docs with titles, URLs, descriptions, and types
- Use `--json` for structured output when you need to pick from results
- Searches across documentation, WWDC videos, and sample code

### Fetch a documentation page

```bash
sosumi fetch <url-or-path>
```

- Accepts full URLs or paths:
  - `sosumi fetch /documentation/swiftui/scrollview`
  - `sosumi fetch https://developer.apple.com/documentation/swift/array`
- Also fetches WWDC session transcripts:
  - `sosumi fetch /videos/play/wwdc2024/10133`
- Returns full Markdown with code examples, availability info, and API details

## Workflow

1. **Search first** when you don't know the exact path:
   ```bash
   sosumi search "ScrollViewReader" --json
   ```

2. **Fetch the result** for full details:
   ```bash
   sosumi fetch /documentation/swiftui/scrollviewreader
   ```

3. **Apply to implementation** using project patterns from IOS_DEVELOPMENT_GUIDE.md

## When to Use

| Scenario | Action |
|----------|--------|
| Need API signature/params | `sosumi fetch /documentation/framework/type` |
| Check availability (iOS version) | `sosumi fetch` → look at "Available on" |
| Explore new API options | `sosumi search "topic" --json` → pick → fetch |
| WWDC session reference | `sosumi fetch /videos/play/wwdcYEAR/ID` |
| Verify deprecation | `sosumi fetch` → check for deprecation notices |

## Critical Rules

1. **Search before guessing** - Don't assume API signatures, look them up
2. **Check availability** - Verify minimum iOS version matches project target
3. **Prefer project patterns** - Use sosumi for reference, but implement using project conventions (AnytypeText, Color.Text.primary, etc.)
4. **Cache mentally** - If you fetched a doc in this conversation, don't fetch it again
