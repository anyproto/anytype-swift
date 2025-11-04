# Code Generation Developer (Smart Router)

## Purpose
Context-aware routing to code generation workflows: SwiftGen, Sourcery, Feature Flags, and Protobuf. Helps you navigate when and how to run generators.

## When Auto-Activated
- Running or discussing `make generate`
- Adding feature flags
- Working with generated files
- Keywords: swiftgen, sourcery, feature flags, FeatureFlags, make generate

## 🚨 CRITICAL RULES (NEVER VIOLATE)

1. **NEVER edit generated files** - Files marked with `// Generated using Sourcery/SwiftGen` are auto-generated
2. **ALWAYS run `make generate` after changes** - When updating templates, flags, assets, or localization
3. **Feature flags for all new features** - Wrap experimental code for safe rollouts
4. **Update source, not generated code** - Edit templates/configurations, then regenerate

## 📋 Essential Commands

```bash
make generate        # Run all generators (SwiftGen, Sourcery, assets, localization)
make generate-middle # Regenerate middleware and protobuf (when dependencies change)
make setup-middle    # Initial middleware setup
```

## 🚩 Feature Flags Quick Workflow

### 1. Define Flag

**File**: `/Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift`

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

### 2. Generate

```bash
make generate
```

This creates: `Modules/AnytypeCore/AnytypeCore/Generated/FeatureFlags.swift`

### 3. Use in Code

```swift
import AnytypeCore

if FeatureFlags.newChatInterface {
    NewChatView()
} else {
    LegacyChatView()
}
```

### Flag Types

- **`.debug`**: Debug-only (not available in production)
- **`.feature(author:releaseVersion:)`**: Production feature with metadata

### Best Practices

- `defaultValue: false` for unreleased features
- `debugValue: true` for easier developer testing
- Remove flags after full rollout

## 🎯 When to Run `make generate`

| You Did This | Run This | Why |
|--------------|----------|-----|
| Added/updated .xcstrings | `make generate` | Regenerate Loc constants |
| Added feature flag | `make generate` | Generate FeatureFlags enum |
| Added icon to Assets.xcassets | `make generate` | Generate Image asset constants |
| Modified Sourcery template | `make generate` | Regenerate code from templates |
| Updated middleware version | `make generate-middle` | Regenerate protobuf bindings |

## 🎨 SwiftGen - Assets & Localization

### Adding Icons

1. Export SVG from Figma (e.g., "32/qr code" → `QRCode.svg`)
2. Add to `/Modules/Assets/.../Assets.xcassets/DesignSystem/x32/QRCode.imageset/`
3. Run `make generate`
4. Use: `Image(asset: .X32.qrCode)`

**Icon Sizes**: x18, x24, x32, x40 (pt)

### Localization

SwiftGen generates Loc constants from .xcstrings files.

See **localization-developer** skill for complete workflow.

## 🔧 Sourcery - Template-Based Generation

Sourcery generates Swift code from templates based on source file annotations.

**Common uses**:
- Protocol conformance
- Mock implementations
- Dependency injection
- Enum helpers

**Workflow**:
1. Add annotation to source file: `// sourcery: AutoEquatable`
2. Run `make generate`
3. Use generated code (don't edit generated files!)

## 🔌 Middleware & Protobuf

### When to Regenerate

- Middleware version updated
- `Dependencies/Middleware/Lib.xcframework` missing binaries
- Build errors related to middleware symbols

### Commands

```bash
make setup-middle    # Initial setup
make generate-middle # Regenerate middleware + protobuf
```

## ⚠️ Common Mistakes

### Editing Generated Files

```swift
// In FeatureFlags.swift (GENERATED)
static let myFlag: Bool = true  // ❌ DON'T DO THIS
// Your changes will be overwritten
```

**✅ Correct**: Edit `FeatureDescription+Flags.swift`, then `make generate`

### Forgetting to Generate

```swift
// Added FeatureDescription but didn't generate
if FeatureFlags.myNewFlag {  // ❌ Error: unresolved identifier
    ...
}
```

**✅ Correct**: Run `make generate` first

### Missing Middleware Binaries

**Symptoms**: "Lib.xcframework missing binaries"

**Solution**: `make setup-middle` or `make generate`

## 📚 Complete Documentation

**Full Guide**: `Modules/AnytypeCore/CODE_GENERATION_GUIDE.md`

For comprehensive coverage of:
- Feature Flags lifecycle (Development → Beta → Rollout → Cleanup)
- SwiftGen configuration files and workflows
- Sourcery templates and annotations
- Protobuf splitting configuration
- Complete troubleshooting guide
- Generated file locations

## ✅ Checklist: Before Committing

- [ ] Ran `make generate` if you added/updated:
  - [ ] Feature flags
  - [ ] Icons/assets
  - [ ] Localization strings
  - [ ] Sourcery annotations
- [ ] Did NOT manually edit files with "// Generated using" header
- [ ] Committed both source AND generated files
- [ ] Verified build succeeds

## 🔗 Related Skills & Docs

- **localization-developer** → `LOCALIZATION_GUIDE.md` - Localization keys generated by SwiftGen
- **ios-dev-guidelines** → `IOS_DEVELOPMENT_GUIDE.md` - Never edit generated files
- **design-system-developer** → Icons generated by SwiftGen

---

**Navigation**: This is a smart router. For deep technical details, always refer to `CODE_GENERATION_GUIDE.md`.
