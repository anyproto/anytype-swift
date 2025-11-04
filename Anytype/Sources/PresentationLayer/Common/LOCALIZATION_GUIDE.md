# Localization System Guide

Complete guide to the Anytype iOS localization system using SwiftGen and .xcstrings files.

*Last updated: 2025-01-30*

## Overview

The Anytype iOS app uses a 3-file localization system with SwiftGen code generation:
- **Auth.xcstrings** (86 keys): Authentication, login/join flows, keychain, vault, onboarding, migration
- **Workspace.xcstrings** (493 keys): Spaces, objects, relations, collections, sets, types, templates, collaboration
- **UI.xcstrings** (667 keys): Settings, widgets, alerts, common UI elements, general app strings

All three files generate into a single `Strings.swift` file (~5,000 lines) with type-safe constants.

## ⚠️ CRITICAL RULES

1. **NEVER use hardcoded strings in UI** - Always use localization constants
2. **Keys must be unique across ALL three .xcstrings files** - Duplicate keys break code generation
3. **Only update English (`en`) translations** - All other languages handled by Crowdin
4. **Always run `make generate` after changes** - Regenerates Strings.swift constants

## 📋 Quick Workflow

### 1. Search Existing Keys First

```bash
rg "yourSearchTerm" Modules/Loc/Sources/Loc/Generated/Strings.swift
```

**Use existing patterns**:
- Block titles: `[feature]BlockTitle`
- Block subtitles: `[feature]BlockSubtitle`
- Common words: `camera`, `photo`, `picture`, `video(1)`

### 2. Choose the Right .xcstrings File

| File | Count | Use For |
|------|-------|---------|
| **Auth.xcstrings** | 86 keys | Authentication, login/join flows, keychain, vault, onboarding, migration |
| **Workspace.xcstrings** | 493 keys | Spaces, objects, relations, collections, sets, types, templates, collaboration |
| **UI.xcstrings** | 667 keys | Settings, widgets, alerts, common UI elements, general app strings |

### 3. Add Key (If Doesn't Exist)

**Location**: `Modules/Loc/Sources/Loc/Resources/[File].xcstrings`

**Format**:
```json
"Your localization key" : {
  "extractionState" : "manual",
  "localizations" : {
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Your English text here"
      }
    }
  }
}
```

**⚠️ IMPORTANT**: Only edit the `"en"` (English) translation. Do not manually edit translations for other languages (de, es, fr, ja, etc.) - the localization team manages non-English translations through Crowdin workflow.

### 4. Generate Constants

```bash
make generate
```

This runs SwiftGen to generate type-safe constants in `Modules/Loc/Sources/Loc/Generated/Strings.swift`.

### 5. Use in Code

```swift
import Loc

// Simple text
AnytypeText(Loc.yourLocalizationKey, style: .uxCalloutMedium)

// Or with Text
Text(Loc.yourLocalizationKey)
    .anytypeStyle(.bodyRegular)
```

## 🔤 Key Naming Patterns

### Short, Descriptive Keys

✅ **CORRECT**: `"No properties yet"`
❌ **WRONG**: `"No properties yet. Add some to this type."`

**Why**: Keys should be concise. Full sentences belong in the value, not the key name.

### Hierarchical Organization

Use dots for organization. SwiftGen creates nested enums:

**Input** (in .xcstrings):
```json
"QR.join.title": { "en": "Join with QR" }
"QR.join.subtitle": { "en": "Scan code to join" }
```

**Generated** (in Strings.swift):
```swift
enum Loc {
    enum Qr {
        enum Join {
            static let title = "Join with QR"
            static let subtitle = "Scan code to join"
        }
    }
}
```

**Usage**:
```swift
Text(Loc.Qr.Join.title)
Text(Loc.Qr.Join.subtitle)
```

## 🔧 Dynamic Localization (with Parameters)

For strings with format specifiers (%lld, %d, %@), SwiftGen automatically generates functions with parameters.

### Format Specifiers

| Specifier | Type | Example |
|-----------|------|---------|
| `%lld` | Integer (long long) | "You've reached the limit of %lld editors" |
| `%d` | Integer | "Pin limit reached: %d pinned spaces" |
| `%@` | String | "Hello %@" |
| `%f` | Float/Double | "Progress: %.2f%%" |

### Example

**Input** (Workspace.xcstrings):
```json
"You've reached the limit of %lld editors": {
  "localizations": {
    "en": {
      "stringUnit": {
        "state": "translated",
        "value": "You've reached the limit of %lld editors"
      }
    }
  }
}
```

**Generated** (Strings.swift):
```swift
static func youVeReachedTheLimitOfEditors(_ value: Int) -> String {
    return String(format: "You've reached the limit of %lld editors", value)
}
```

**Usage**:

✅ **CORRECT** - Use generated function:
```swift
Text(Loc.youVeReachedTheLimitOfEditors(4))
```

❌ **WRONG** - Don't use String(format:):
```swift
String(format: Loc.youVeReachedTheLimitOfEditors, 4)  // Compile error!
```

**Why**: SwiftGen generates type-safe functions. Always use the generated function directly.

## 🗑️ Removing Unused Localization Keys

When removing code that uses localization keys, clean up the .xcstrings files:

### Workflow

**1. Search for usage**:
```bash
rg "keyName" --type swift
```

**2. If only found in Generated/Strings.swift**, the key is unused:
- Remove the entire key entry from the source `.xcstrings` file
- Run `make generate` to regenerate Strings.swift

**3. Example**:
- Removed `MembershipParticipantUpgradeReason.numberOfSpaceReaders` from code
- Search: `rg "noMoreMembers" --type swift` → only in Strings.swift
- Remove `"Membership.Upgrade.NoMoreMembers"` from Workspace.xcstrings
- Run `make generate`

**Important**: Never leave orphaned localization keys in .xcstrings files - they bloat the codebase and confuse translators.

## 📁 File Locations

- **Source .xcstrings files**: `Modules/Loc/Sources/Loc/Resources/`
  - Auth.xcstrings
  - Workspace.xcstrings
  - UI.xcstrings
- **Generated constants**: `Modules/Loc/Sources/Loc/Generated/Strings.swift`
- **SwiftGen config**: `Modules/Loc/swiftgen.yml`

## 🎓 Common Mistakes

### ❌ Using String(format:)

```swift
// WRONG
String(format: Loc.someKey, value)

// CORRECT
Loc.someKey(value)
```

### ❌ Hardcoded Strings

```swift
// WRONG
Text("Add Member")

// CORRECT
Text(Loc.addMember)
```

### ❌ Duplicate Keys Across Files

```swift
// If "Settings.Title" exists in both UI.xcstrings and Workspace.xcstrings
// → make generate will fail
```

**Solution**: Keys must be globally unique across all 3 files.

### ❌ Forgetting to Generate

```bash
# After adding key to .xcstrings
# WRONG: Try to use immediately
Text(Loc.myNewKey)  // Error: unresolved identifier

# CORRECT: Generate first
make generate
Text(Loc.myNewKey)  // Success!
```

### ❌ Editing Non-English Translations

```json
// WRONG - Don't edit other languages
"localizations": {
  "en": { ... },
  "de": { "value": "Meine Übersetzung" }  // Don't do this!
}

// CORRECT - Only edit English
"localizations": {
  "en": { "value": "My translation" }
  // Crowdin handles other languages
}
```

## 🔍 Troubleshooting

### Issue: Key not generating

**Symptom**: Added key to .xcstrings but `Loc.myKey` doesn't exist

**Solution**:
1. Check JSON syntax is valid: `jq . Modules/Loc/Sources/Loc/Resources/UI.xcstrings`
2. Verify key doesn't exist in other files (duplicate keys break generation)
3. Run `make generate`
4. Check for errors in generation output

### Issue: Duplicate key error

**Symptom**: `make generate` fails with duplicate key error

**Solution**:
```bash
# Find duplicates across all files
rg "\"My Key\"" Modules/Loc/Sources/Loc/Resources/*.xcstrings

# Should appear only once total across all 3 files
```

### Issue: Format specifier not working

**Symptom**: `Loc.myKey(value)` doesn't exist, only `Loc.myKey` (string)

**Solution**: Check the .xcstrings value includes format specifier:
- With `%lld` or `%d` → generates function with Int parameter
- Without format specifier → generates plain string constant

## 📚 Additional Resources

- **Quick Reference**: See CLAUDE.md for condensed workflow
- **Skills System**: `.claude/skills/localization-developer/` for auto-activation
- **SwiftGen Docs**: https://github.com/SwiftGen/SwiftGen

## 💡 Best Practices

1. **Search before adding** - Reuse existing keys when possible
2. **Use hierarchical naming** - `Feature.Section.Item` for organization
3. **Keep keys short** - Full text goes in value, not key name
4. **Clean up unused keys** - Prevents bloat and translator confusion
5. **Only edit English** - Let Crowdin handle other languages
6. **Always generate** - Run `make generate` after any .xcstrings change

---

*This guide is the single source of truth for localization. For quick reference, see CLAUDE.md.*