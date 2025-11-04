# Code Generation Guide

Complete guide to code generation workflows in the Anytype iOS app: SwiftGen, Sourcery, Feature Flags, and Protobuf.

*Last updated: 2025-01-30*

## Overview

The Anytype iOS app uses multiple code generation tools to reduce boilerplate and ensure type safety:

- **SwiftGen**: Generates constants for assets (icons, colors) and localization strings
- **Sourcery**: Generates Swift code from templates based on source file annotations
- **Feature Flags**: Boolean toggles for safe feature rollouts (Sourcery-generated)
- **Protobuf**: Middleware message definitions

## ⚠️ CRITICAL RULES

1. **NEVER edit generated files** - Files marked with `// Generated using Sourcery/SwiftGen` are auto-generated
2. **ALWAYS run `make generate` after changes** - Updates templates, flags, assets, or localization
3. **Feature flags for all new features** - Wrap experimental features for safe rollouts
4. **Update source, not generated code** - Edit templates/configurations, then regenerate

## 📋 Essential Commands

```bash
make generate        # Run all generators (SwiftGen, Sourcery, assets, localization)
make generate-middle # Regenerate middleware and protobuf (when dependencies change)
make setup-middle    # Initial middleware setup
```

### When to Run `make generate`

| You Did This | Run This | Why |
|--------------|----------|-----|
| Added/updated .xcstrings | `make generate` | Regenerate Loc constants |
| Added feature flag | `make generate` | Generate FeatureFlags enum |
| Added icon to Assets.xcassets | `make generate` | Generate Image asset constants |
| Modified Sourcery template | `make generate` | Regenerate code from templates |
| Updated middleware version | `make generate-middle` | Regenerate protobuf bindings |

## 🚩 Feature Flags System

Feature flags enable safe rollout of new features by wrapping them in boolean toggles.

### Quick Workflow

**1. Define the flag** in `/Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift`:

```swift
extension FeatureDescription {
    static let newChatInterface = FeatureDescription(
        title: "New Chat Interface",
        type: .feature(author: "Your Name", releaseVersion: "0.42.0"),
        defaultValue: false,  // Off in production
        debugValue: true      // On in debug builds for testing
    )
}
```

**2. Generate**:

```bash
make generate
```

This generates `Modules/AnytypeCore/AnytypeCore/Generated/FeatureFlags.swift`:

```swift
// Generated using Sourcery
enum FeatureFlags {
    static let newChatInterface: Bool = /* value based on build config */
}
```

**3. Use in code**:

```swift
import AnytypeCore

if FeatureFlags.newChatInterface {
    NewChatView()
} else {
    LegacyChatView()
}
```

### Feature Flag Types

```swift
// Debug-only (not available in production builds)
type: .debug

// Production feature with metadata
type: .feature(author: "Dev Name", releaseVersion: "0.42.0")
```

### Best Practices

✅ **DO**:
- Set `defaultValue: false` for unreleased features
- Set `debugValue: true` for easier developer testing
- Include author and release version metadata
- Remove flags after feature is fully rolled out

❌ **DON'T**:
- Deploy features without feature flags
- Forget to run `make generate` after adding flags
- Leave old flags in codebase indefinitely

### Feature Flag Lifecycle

**1. Development** (defaultValue: false, debugValue: true)
- Flag off in production
- Flag on in debug builds for testing

**2. Beta** (defaultValue: false, debugValue: true)
- Still off in production
- Enable for beta testers via remote config (if available)

**3. Rollout** (defaultValue: true, debugValue: true)
- Change defaultValue to true
- Deploy - feature now enabled for all users

**4. Cleanup**
- Feature stable and enabled everywhere
- Remove FeatureDescription
- Remove all `if FeatureFlags.x` checks
- Make new behavior the default
- Run `make generate`

## 🎨 SwiftGen - Assets & Localization

SwiftGen generates type-safe constants for resources.

### Configuration Files

- Assets: `/Modules/Assets/swiftgen.yml`
- Localization: `/Modules/Loc/swiftgen.yml`

### Icon Generation

**Input** (Assets.xcassets):
```
DesignSystem/
└── x32/
    └── QRCode.imageset/
        ├── QRCode.svg
        └── Contents.json
```

**Generated** (after `make generate`):
```swift
enum ImageAsset {
    enum X32 {
        static let qrCode = ImageAsset(name: "DesignSystem/x32/QRCode")
    }
}
```

**Usage**:
```swift
Image(asset: .X32.qrCode)
```

### Adding Icons

1. Export SVG from Figma (e.g., "32/qr code" → `QRCode.svg`)
2. Add to `/Modules/Assets/.../Assets.xcassets/DesignSystem/x32/QRCode.imageset/`
3. Run `make generate`
4. Use: `Image(asset: .X32.qrCode)`

**Icon Sizes**:
- `x18` - 18pt icons (small UI)
- `x24` - 24pt icons (medium UI)
- `x32` - 32pt icons (large UI, most common)
- `x40` - 40pt icons (extra large)

### Localization Generation

SwiftGen also generates constants for localization keys from .xcstrings files.

**See**: `LOCALIZATION_GUIDE.md` for complete localization workflow.

## 🔧 Sourcery - Template-Based Generation

Sourcery generates Swift code from templates based on source file annotations.

### Configuration

Multiple `sourcery.yml` files across modules:
- `/Modules/AnytypeCore/sourcery.yml`
- `/Modules/Services/sourcery.yml`
- etc.

### Generated File Markers

All Sourcery-generated files include:
```swift
// Generated using Sourcery X.X.X — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
```

### Common Use Cases

**1. Protocol conformance** (Equatable, Hashable)
```swift
// sourcery: AutoEquatable
struct User {
    let id: String
    let name: String
}

// After make generate:
// User conforms to Equatable automatically
```

**2. Mock implementations for testing**
```swift
// sourcery: AutoMockable
protocol UserService {
    func fetchUser(id: String) async throws -> User
}

// After make generate:
// UserServiceMock class created automatically
```

**3. Enum helpers**
```swift
// sourcery: AutoCases
enum UserRole {
    case admin, editor, viewer
}

// After make generate:
// CaseIterable conformance added
```

### Workflow

1. Add annotation to source file: `// sourcery: AutoEquatable`
2. Run: `make generate`
3. Sourcery scans files, applies templates, generates code
4. Use generated code (don't edit generated files!)

### Important

✅ Update source file annotations, not generated files
✅ Run `make generate` after changing templates
✅ Commit both source and generated files to git

❌ Don't manually edit generated files
❌ Don't ignore "DO NOT EDIT" warnings

## 🔌 Middleware & Protobuf

The Anytype middleware is a pre-compiled binary framework communicating via Protobuf.

### Commands

```bash
make setup-middle    # Initial setup (downloads middleware)
make generate-middle # Regenerate middleware + protobuf bindings
```

### When to Regenerate

- Middleware version updated in dependencies
- `Dependencies/Middleware/Lib.xcframework` missing binaries
- Protobuf message definitions changed
- Build errors related to middleware symbols

### Locations

- **Middleware**: `Dependencies/Middleware/Lib.xcframework`
- **Protobuf messages**: `Modules/ProtobufMessages/`
- **Generated code**: `Modules/ProtobufMessages/Generated/`
- **Custom config**: `anytypeGen.yml` (protobuf splitting)

## 📁 Generated File Locations

| Generator | Output Location |
|-----------|-----------------|
| SwiftGen (Localization) | `Modules/Loc/Sources/Loc/Generated/Strings.swift` |
| SwiftGen (Assets) | `Modules/Assets/Generated/ImageAssets.swift` |
| SwiftGen (Colors) | `Modules/Assets/Sources/Assets/Generated/Color+Assets.swift` |
| Sourcery (Feature Flags) | `Modules/AnytypeCore/AnytypeCore/Generated/FeatureFlags.swift` |
| Sourcery (Various) | `Modules/*/Generated/` |
| Protobuf | `Modules/ProtobufMessages/Generated/` |

## 🚨 Common Mistakes

### ❌ Editing Generated Files

```swift
// In Generated/FeatureFlags.swift
static let myFlag: Bool = true  // ❌ Don't edit this!
// Your changes will be overwritten on next make generate
```

**✅ Correct**: Edit source file (`FeatureDescription+Flags.swift`), then regenerate.

### ❌ Forgetting to Generate

```swift
// Added FeatureDescription but didn't generate
if FeatureFlags.myNewFlag {  // ❌ Error: unresolved identifier
    ...
}
```

**✅ Correct**: Run `make generate` first.

### ❌ Not Committing Generated Files

Generated files should be committed to git for reproducibility:

```bash
git add Modules/AnytypeCore/AnytypeCore/Generated/FeatureFlags.swift
git commit -m "Add new feature flag"
```

## 🔍 Troubleshooting

### Issue: `make generate` fails

**Common causes**:
- Malformed JSON in .xcstrings files
- Duplicate keys across localization files
- Invalid Sourcery annotations
- Syntax errors in templates

**Solution**:
```bash
# Validate JSON
jq . Modules/Loc/Sources/Loc/Resources/UI.xcstrings

# Check for duplicate localization keys
rg "\"My Key\"" Modules/Loc/Sources/Loc/Resources/*.xcstrings | wc -l
# Should be 1, not 2+

# Check Sourcery annotations
rg "// sourcery:" --type swift
```

### Issue: Generated constant not found

**Symptom**: `FeatureFlags.myFlag` doesn't exist after adding FeatureDescription

**Solution**:
1. Verify flag definition in `FeatureDescription+Flags.swift`
2. Run `make generate`
3. Check generated file: `rg "myFlag" Modules/AnytypeCore/AnytypeCore/Generated/`
4. Clean build if needed

### Issue: Middleware binaries missing

**Symptom**: Build error: "Lib.xcframework missing binaries"

**Solution**:
```bash
make setup-middle   # Initial setup
# Or
make generate       # May trigger middleware generation
```

## 📚 Integration with Other Systems

- **Localization**: See `LOCALIZATION_GUIDE.md` for complete `.xcstrings` workflow
- **Design System**: Icons generated by SwiftGen after adding to Assets.xcassets
- **iOS Development**: Generated code follows patterns in `IOS_DEVELOPMENT_GUIDE.md`

## 💡 Best Practices

1. **Run `make generate` frequently** - After any asset, localization, or flag changes
2. **Never edit generated files** - Always update source, then regenerate
3. **Commit generated files** - Ensures everyone has same code without requiring generators
4. **Use feature flags for new features** - Safe rollouts, easy rollback
5. **Keep flags temporary** - Remove after full rollout to avoid technical debt
6. **Check generated code into git** - Don't rely on everyone running generators

## 📖 Quick Reference

**Add feature flag**:
```bash
vim Modules/AnytypeCore/.../FeatureDescription+Flags.swift
make generate
# Use FeatureFlags.yourFlag in code
```

**Add icon**:
```bash
cp icon.svg Modules/Assets/.../x32/Icon.imageset/
make generate
# Use Image(asset: .X32.icon)
```

**Add localization**:
```bash
# Edit .xcstrings file
make generate
# Use Loc.yourKey
```

---

*This guide is the single source of truth for code generation. For quick reference, see CLAUDE.md.*