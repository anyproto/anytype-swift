---
allowed-tools: Bash(git diff:*), Grep, Glob, Read, Edit
---

# Polish Code

Simplify and clean up code in the current changes.

**⚠️ REQUIRES EXPLICIT USER APPROVAL before making any changes.**

## Usage
```
/polish [to branch <base>]
```

## Optional Arguments
- `to branch <base>` - Specifies the base branch to compare against (default: `develop`)

## Git Context (Precomputed)
- **Current branch**: !`git branch --show-current`

## Process

### Step 1: Analyze (READ-ONLY)
Get changed Swift files and review them. **Do NOT edit yet.**

```bash
# Use user-specified base branch, or "develop" if not specified
git diff origin/<base>...HEAD --name-only -- "*.swift"

# Get the actual changes for each file
git diff origin/<base>...HEAD -- "path/to/file.swift"
```

### Step 2: Present Findings
**Before making ANY changes**, present a summary:

**If NO polish opportunities found** (no simplifications AND no unused code):
```
## Polish Analysis ✅
All files already follow best practices. No changes needed.
```
→ **Auto-proceed** - no approval needed, skip directly to final output.

**If polish opportunities ARE found:**
```
## Polish Proposals

### Simplifications Found:
1. `File.swift:42` - Can use guard let instead of nested if
2. `File.swift:78` - Can use \.keyPath shorthand
3. ...

### Unused Code Found:
1. `OldHelper.swift` - No longer referenced after refactoring
2. `Model.swift:15` - `unusedProperty` has no references
3. ...

### No Changes Needed:
- `CleanFile.swift` - Already follows best practices

**Apply these changes? (yes/no)**
```

### Step 3: Wait for Approval (only if findings exist)
- **If no findings**: Skip this step (auto-proceed)
- **If user says yes/approved**: Proceed to Step 4
- **If user says no/skip**: Exit without changes
- **If user wants partial**: Apply only approved items

### Step 4: Apply Changes (only after approval)

Look for and fix:
- **Unnecessary nesting** → Use `guard let` early returns
- **Verbose closures** → Use shorthand `$0`, `\.property`
- **Repeated logic** → Extract to local variable or function
- **Force unwraps** → Replace with safe unwrapping where possible
- **Long functions** → Split if doing multiple distinct things

**Swift idioms to apply:**
```swift
// ❌ Verbose
if let x = optional {
    return x
} else {
    return default
}

// ✅ Idiomatic
return optional ?? default
```

```swift
// Option A - Closure syntax
array.filter { $0.isActive }.map { $0.name }

// Option B - Keypath shorthand (when clearer)
array.filter(\.isActive).map(\.name)
```
**Use judgment**: Keypath is cleaner for simple properties; closures may be clearer for complex expressions.

### Step 5: Clean Up Unused Code

For any renamed/removed symbols in the diff:

1. **Search for references** (run from repo root):
   ```bash
   rg "oldSymbolName" --type swift .
   ```

2. **Check common locations**:
   - `AnyTypeTests/` - Test files
   - `*Mock*.swift` - Mock implementations
   - `*Assembly*.swift` - DI registrations
   - `PreviewMocks/` - Preview providers

3. **Remove if unreferenced**:
   - Delete unused properties, functions, files
   - Update DI registrations
   - Remove stale imports

### Step 6: Final Check

- Ensure no broken references introduced
- Verify code still follows project patterns (check `IOS_DEVELOPMENT_GUIDE.md` if unsure)

## Output

After user approves and changes are applied:
```
## Polish Applied ✅
- Simplified: [list of changes made]
- Removed: [list of unused code removed]
```

If user declines:
```
## Polish Skipped
No changes made per user request.
```
