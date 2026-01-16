---
allowed-tools: Bash(swiftlint:*), Bash(xcodebuild:*), Bash(git diff:*), Bash(git fetch:*)
---

# Verify Build

Run build verification on current changes.

## Context (Precomputed)
- **Fetch**: !`git fetch origin develop 2>/dev/null`
- **Changed Swift files**: !`git diff --name-only origin/develop...HEAD -- "*.swift" 2>/dev/null | head -20`

## Usage
```
/verify        # SwiftLint only (fast, ~5-10 seconds)
/verify full   # SwiftLint + xcodebuild (slow, 2-5 minutes)
```

## Process

### Step 1: SwiftLint Check

Run SwiftLint on changed Swift files:

```bash
# Lint specific files
swiftlint lint --config .swiftlint.yml -- path/to/file1.swift path/to/file2.swift

# Or lint all changed files at once
git diff --name-only -z origin/develop...HEAD -- "*.swift" | xargs -0 swiftlint lint --config .swiftlint.yml --
```

### Step 2: Report Results

Present findings in this format:

```
## SwiftLint Results

### ❌ Errors (must fix)
- `File.swift:42` - Trailing whitespace violation
- `File.swift:78` - Force cast violation

### ⚠️ Warnings (optional)
- `File.swift:15` - Line length warning (105 > 100)

### ✅ No Issues
All files pass SwiftLint checks.
```

**If errors found:**
- List each error with file:line
- Offer to fix automatically if fixable (trailing whitespace, etc.)

### Step 3: Full Build (only if `/verify full`)

If user requested full build:

1. **Ask about execution mode:**
   ```
   Full xcodebuild takes 2-5 minutes.
   Run in background? (yes/no)
   ```

2. **If background (yes):**
   - Use Bash tool with `run_in_background: true`
   - User can continue working
   - Check results later with TaskOutput

3. **If foreground (no):**
   - Run inline, blocks until complete
   - Show build output

```bash
# Build command
xcodebuild build \
  -workspace Anytype.xcworkspace \
  -scheme Anytype \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -quiet \
  2>&1 | grep -E "(error:|warning:|BUILD)"
```

## Output

### SwiftLint Only
```
## Verify Results ✅
SwiftLint: Passed (0 errors, 2 warnings)
```

### Full Build
```
## Verify Results ✅
SwiftLint: Passed (0 errors, 2 warnings)
Build: Success (running in background, task_id: abc123)
```

### With Errors
```
## Verify Results ❌
SwiftLint: 3 errors found

Fix these errors before committing:
1. `File.swift:42` - Trailing whitespace
2. `File.swift:78` - Force cast
3. `File.swift:90` - Unused variable

Would you like me to fix the auto-fixable issues? (yes/no)
```
