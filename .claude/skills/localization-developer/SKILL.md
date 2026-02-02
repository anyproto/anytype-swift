---
name: localization-developer
description: Context-aware routing to the Anytype iOS localization system. Use when working with .xcstrings files, Loc constants, hardcoded strings, or user-facing text.
---

# Localization Developer (Smart Router)

## Purpose
Context-aware routing to the Anytype iOS localization system. Helps you navigate the 3-file .xcstrings structure and use Loc constants correctly.

## When Auto-Activated
- Working with `.xcstrings` files
- Using `Loc` constants
- Discussing hardcoded strings or user-facing text
- Keywords: localization, strings, text, Loc., .xcstrings

## 🚨 CRITICAL RULES (NEVER VIOLATE)

1. **NEVER use hardcoded strings in UI** - Always use `Loc` constants
2. **NEVER create duplicate keys** across the 3 .xcstrings files - Breaks code generation
3. **NEVER edit non-English translations** - Only update English (`en`), Crowdin handles others
4. **ALWAYS search for existing keys first** - Reuse before creating new
5. **ALWAYS run `make generate`** after editing .xcstrings files

## 📋 Quick Workflow

1. **Search existing**: `rg "yourSearchTerm" Modules/Loc/Sources/Loc/Generated/Strings.swift`
2. **If found**: Reuse existing key
3. **If not found**: Add to appropriate .xcstrings file (see decision tree below)
4. **Generate**: `make generate`
5. **Use**: `AnytypeText(Loc.yourKey, style: .uxCalloutMedium)`

## 🗂️ The 3-File System

### Decision Tree

```
Is this text for authentication/login/vault?
    YES → Auth.xcstrings (86 keys)
    NO  → Continue

Is this text for spaces/objects/collaboration?
    YES → Workspace.xcstrings (493 keys)
    NO  → Continue

Is this text for settings/widgets/general UI?
    YES → UI.xcstrings (667 keys)
```

### File Locations

- **Auth.xcstrings**: `Modules/Loc/Sources/Loc/Resources/Auth.xcstrings`
- **Workspace.xcstrings**: `Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings`
- **UI.xcstrings**: `Modules/Loc/Sources/Loc/Resources/UI.xcstrings`

**Generated output**: All 3 files → single `Strings.swift` (~5,000 lines, 1,246 total keys)

## 🎯 Adding Keys

### Format (add to appropriate .xcstrings file)

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

**Key naming**:
- Short keys: `"No properties yet"` ✅
- Not full sentences: `"No properties yet. Add some."` ❌
- Hierarchical: `"QR.join.title"` → `Loc.Qr.Join.title`

## 🔢 Dynamic Localization (Parameters)

### ✅ CORRECT - Use generated functions

```swift
// String: "You've reached the limit of %lld editors"
Loc.SpaceLimit.Editors.title(4)

// String: "Welcome, %@!"
Loc.welcomeMessage("John")
```

### ❌ WRONG - Never use String(format:)

```swift
String(format: Loc.limitReached, 10)  // DON'T DO THIS
```

**Why**: SwiftGen auto-generates parameterized functions for format specifiers (%lld, %d, %@).

**Format specifiers**:
- `%lld` → Int parameter
- `%d` → Int parameter
- `%@` → String parameter
- `%.1f` → Double parameter

## 🗑️ Removing Unused Keys

1. **Search**: `rg "keyName" --type swift`
2. **If only in Strings.swift**: Key is orphaned
3. **Remove** from source .xcstrings file
4. **Generate**: `make generate`

## ⚠️ Common Mistakes

### Hardcoded Strings
```swift
// ❌ WRONG
Text("Delete")

// ✅ CORRECT
Text(Loc.delete)
```

### Duplicate Keys Across Files
```json
// In Auth.xcstrings
"Settings" : { ... }

// In UI.xcstrings
"Settings" : { ... }  // ❌ DUPLICATE! Breaks generation
```

### Using String(format:)
```swift
// ❌ WRONG
String(format: Loc.limitReached, 10)

// ✅ CORRECT
Loc.limitReached(10)
```

### Editing Non-English
```json
// ❌ WRONG - Crowdin will overwrite
"de" : { "value" : "Meine Übersetzung" }

// ✅ CORRECT - Only edit English
"en" : { "value" : "My translation" }
```

## 📚 Complete Documentation

**Full Guide**: `Anytype/Sources/PresentationLayer/Common/LOCALIZATION_GUIDE.md`

For comprehensive coverage of:
- Detailed 3-file system explanation
- Key naming patterns and conventions
- Dynamic localization with all format specifiers
- Translation workflow with Crowdin
- Removing orphaned keys
- Generated file structure
- Complete examples and troubleshooting

## ✅ Workflow Checklist

- [ ] Searched for existing keys (`rg` in Strings.swift)
- [ ] Added to correct .xcstrings file (Auth/Workspace/UI)
- [ ] No duplicate keys across files
- [ ] Only updated English (`en`)
- [ ] Ran `make generate`
- [ ] Used generated key: `Loc.yourKey`
- [ ] No hardcoded strings in UI

## 🔗 Related Skills & Docs

- **ios-dev-guidelines** → `IOS_DEVELOPMENT_GUIDE.md` - Never use hardcoded strings
- **code-generation-developer** → `CODE_GENERATION_GUIDE.md` - Understanding make generate
- **design-system-developer** → Using Loc constants in UI components

---

**Navigation**: This is a smart router. For deep details, always refer to `LOCALIZATION_GUIDE.md`.
