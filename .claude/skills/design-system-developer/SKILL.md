# Design System Developer (Smart Router)

## Purpose
Context-aware routing to the Anytype iOS design system: icons, typography, colors, spacing. Helps you navigate Figma-to-code translation.

## When Auto-Activated
- Working with icons or typography
- Keywords: icon, typography, design system, figma, color, spacing
- Editing files in DesignSystem/ or Assets.xcassets
- Discussing colors or UI components

## 🚨 CRITICAL RULES (NEVER VIOLATE)

1. **ALWAYS use design system constants** - Never hardcode hex colors, font sizes, or asset names
2. **ALWAYS run `make generate` after adding assets** - Icons and assets must be code-generated
3. **Icons are organized by size** - x18, x24, x32, x40 (use correct size for context)
4. **Typography follows strict mapping** - Figma style names map to specific Swift enum cases
5. **Spacing formula** - `NextElement.Y - (CurrentElement.Y + CurrentElement.Height)`

## 📋 Quick Reference

### Icon Usage

```swift
// 18pt - Toolbar/nav bar icons
Image(asset: .X18.search)

// 24pt - List row icons
Image(asset: .X24.camera)

// 32pt - Buttons, main UI (most common)
Image(asset: .X32.qrCode)

// 40pt - Large features
Image(asset: .X40.profile)
```

### Adding Icons

1. Export SVG from Figma ("32/qr code" → `QRCode.svg`)
2. Add to `/Modules/Assets/.../Assets.xcassets/DesignSystem/x32/QRCode.imageset/`
3. Run `make generate`
4. Use: `Image(asset: .X32.qrCode)`

### Typography Usage

```swift
// Screen titles
AnytypeText("Settings", style: .uxTitle1Semibold)

// Section headers
AnytypeText("Recent", style: .uxTitle2Semibold)

// Body text
Text("Description").anytypeStyle(.bodyRegular)

// Small labels
Text("Add Member").anytypeStyle(.caption1Medium)  // Note: no "ux" prefix!
```

### Typography Mapping (Figma → Swift)

**Content Styles** (remove "Content/" prefix):
- "Content/Body/Semibold" → `.bodySemibold`
- "Content/Preview Title 2/Regular" → `.previewTitle2Regular`

**UX Styles - Title/Body/Callout** (keep "ux" prefix lowercase):
- "UX/Title 1/Semibold" → `.uxTitle1Semibold`
- "UX/Body/Regular" → `.uxBodyRegular`

**UX Styles - Captions** (DROP "ux" prefix - EXCEPTION!):
- "UX/Caption 1/Medium" → `.caption1Medium` (no "ux")
- "UX/Caption 2/Regular" → `.caption2Regular` (no "ux")

### Common Typography Styles

| Use Case | Figma Style | Swift Constant | Size |
|----------|-------------|----------------|------|
| Screen titles | UX/Title 1/Semibold | `.uxTitle1Semibold` | 28pt |
| Section headers | UX/Title 2/Semibold | `.uxTitle2Semibold` | 17pt |
| Body text | Content/Body/Regular | `.bodyRegular` | 17pt |
| Small labels | UX/Caption 1/Medium | `.caption1Medium` | 13pt |

### Color Usage

```swift
// Backgrounds
.background(Color.Shape.transperentSecondary)
.background(Color.Background.primary)

// Text colors
.foregroundColor(Color.Text.primary)
.foregroundColor(Color.Text.secondary)

// Control colors
.foregroundColor(Color.Control.active)
```

## 📏 Spacing from Figma (CRITICAL FORMULA)

**CRITICAL**: Spacing is the GAP between elements, not top-to-top distance.

**Formula**:
```
Spacing = NextElement.Y - (CurrentElement.Y + CurrentElement.Height)
```

**Example**:
1. First element: Y=326px, Height=24px → Bottom edge = 350px
2. Second element: Y=374px
3. **Spacing = 374 - 350 = 24px** ✅

**Common mistake**:
```
❌ WRONG: 374 - 326 = 48px  (includes first element's height!)
✅ CORRECT: 374 - (326 + 24) = 24px  (actual gap)
```

**SwiftUI usage**:
```swift
Text("Title")
Spacer.fixedHeight(24)  // ✅ Correct spacing
Text("Feature")
```

## ⚠️ Common Mistakes

### Typography Style Doesn't Exist

```swift
// ❌ WRONG
Text("Button").anytypeStyle(.uxCaption1Medium)  // Doesn't exist!

// ✅ CORRECT
Text("Button").anytypeStyle(.caption1Medium)  // Captions drop "ux" prefix
```

### Hardcoded Colors

```swift
// ❌ WRONG
.background(Color(hex: "#FF0000"))

// ✅ CORRECT
.background(Color.Pure.red)
```

### Wrong Icon Size

```swift
// ❌ WRONG - Upscaling looks bad
Image(asset: .X18.qrCode)
    .frame(width: 32, height: 32)

// ✅ CORRECT - Use native size
Image(asset: .X32.qrCode)
    .frame(width: 32, height: 32)
```

### Spacing Calculation

```swift
// ❌ WRONG - Top-to-top (includes height)
Spacing = NextElement.Y - CurrentElement.Y

// ✅ CORRECT - Actual gap
Spacing = NextElement.Y - (CurrentElement.Y + CurrentElement.Height)
```

## 📚 Complete Documentation

**Full Guides**:
- **Design System**: `Anytype/Sources/PresentationLayer/Common/DESIGN_SYSTEM_MAPPING.md`
- **Typography**: `Anytype/Sources/PresentationLayer/Common/TYPOGRAPHY_MAPPING.md`

For comprehensive coverage of:
- Complete typography mapping table
- All color categories and constants
- Icon organization and workflows
- Corner radius standards
- Dimension standards (whole numbers only)
- Design verification workflow
- Dark/light mode considerations

**Figma References**:
- Typography: https://www.figma.com/file/vgXV7x2v20vJajc7clYJ7a/Typography-Mobile

## ✅ Design Implementation Checklist

- [ ] All icons use `.X*` constants, no hardcoded asset names
- [ ] All typography uses `.anytypeStyle()` or `AnytypeText`
- [ ] All colors use `Color.*` constants, no hex values
- [ ] Spacing extracted from Figma using correct formula
- [ ] All dimensions are whole numbers (or documented if rounded)
- [ ] Ran `make generate` after adding new assets
- [ ] Verified against Figma design visually
- [ ] Checked dark/light mode appearance

## 🔗 Related Skills & Docs

- **code-generation-developer** → `CODE_GENERATION_GUIDE.md` - Run make generate after adding icons
- **ios-dev-guidelines** → `IOS_DEVELOPMENT_GUIDE.md` - SwiftUI patterns for design system
- **localization-developer** → Combine typography with localized text

---

**Navigation**: This is a smart router. For deep technical details, always refer to `DESIGN_SYSTEM_MAPPING.md` and `TYPOGRAPHY_MAPPING.md`.
