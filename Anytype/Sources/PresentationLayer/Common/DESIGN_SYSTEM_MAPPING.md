# Figma to Code Design System Mapping

*Last updated: 2025-07-14*

This document provides a comprehensive mapping between Figma design system elements and their corresponding code implementations in the Anytype iOS app.

## Color Mapping

### How to Read Figma Colors
In Figma, colors are displayed in the format: `Category/Subcategory/Name`

Example: `Shapes/Transparent Secondary` maps to `Color.Shape.transperentSecondary`

### Color Categories

#### Shape Colors
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Shapes/Primary` | `Color.Shape.primary` | Primary shape backgrounds |
| `Shapes/Secondary` | `Color.Shape.secondary` | Secondary shape backgrounds |
| `Shapes/Tertiary` | `Color.Shape.tertiary` | Tertiary shape backgrounds |
| `Shapes/Transparent Primary` | `Color.Shape.transperentPrimary` | Semi-transparent overlays |
| `Shapes/Transparent Secondary` | `Color.Shape.transperentSecondary` | Search bars, subtle backgrounds |
| `Shapes/Transparent Tertiary` | `Color.Shape.transperentTertiary` | Light overlays |

#### Text Colors
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Text/Primary` | `Color.Text.primary` | Main text content |
| `Text/Secondary` | `Color.Text.secondary` | Secondary text, captions |
| `Text/Tertiary` | `Color.Text.tertiary` | Placeholder text, disabled text |
| `Text/Inversion` | `Color.Text.inversion` | Text on dark backgrounds |
| `Text/White` | `Color.Text.white` | White text |

#### Background Colors
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Background/Primary` | `Color.Background.primary` | Main background |
| `Background/Secondary` | `Color.Background.secondary` | Card backgrounds |
| `Background/Highlighted Medium` | `Color.Background.highlightedMedium` | Search bar backgrounds |

#### Control Colors
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Control/Button` | `Color.Control.primary` | Primary control color (renamed from button) |
| `Control/Active` | `Color.Control.secondary` | Secondary control state (renamed from active) |
| `Control/Inactive` | `Color.Control.tertiary` | Tertiary/disabled control state (renamed from inactive) |
| `Control/Accent 25` | `Color.Control.accent25` | Accent color with 25% opacity |
| `Control/Accent 50` | `Color.Control.accent50` | Accent color with 50% opacity |
| `Control/Accent 80` | `Color.Control.accent80` | Accent color with 80% opacity |
| `Control/Accent 100` | `Color.Control.accent100` | Full accent color |
| `Control/Accent 125` | `Color.Control.accent125` | Accent color with 125% intensity |


#### Pure Colors
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Pure/Red` | `Color.Pure.red` | Error states, alerts |
| `Pure/Blue` | `Color.Pure.blue` | Links, primary actions |
| `Pure/Green` | `Color.Pure.green` | Success states |
| `Pure/Orange` | `Color.Pure.orange` | Warning states |
| `Pure/Yellow` | `Color.Pure.yellow` | Highlights |

### Usage in SwiftUI
```swift
// Background color
.background(Color.Shape.transperentSecondary)

// Text color
.foregroundColor(Color.Text.primary)

// Border color
.border(Color.Control.active)
```

### Gradient Colors

**Location**: `Modules/Assets/Sources/Assets/Resources/SystemColors.xcassets/Custom/Gradients/`

**Code Access**:
```swift
Color.Gradients.HeaderAlert.redStart
Color.Gradients.HeaderAlert.violetStart
```

**Available Categories**:
- `HeaderAlert/` - Alert/banner gradients (violet, red/peach tones)
- `UpdateAlert/` - App update notification gradients
- `fadingXXX` - Fading background gradients (Blue, Green, Ice, Pink, Purple, Red, Sky, Teal, Yellow)

**Design Principle**: Keep gradient count minimal. When Figma design shows similar gradient colors, coordinate with design team to unify rather than creating duplicates.

**Usage in SwiftUI**:
```swift
// Linear gradient background
LinearGradient(
    gradient: Gradient(colors: [
        Color.Gradients.HeaderAlert.redStart,
        Color.Gradients.HeaderAlert.redEnd
    ]),
    startPoint: .top,
    endPoint: .bottom
)
```

## Typography Mapping

### Figma Typography Reference
- Figma file: https://www.figma.com/file/vgXV7x2v20vJajc7clYJ7a/Typography-Mobile

### How to Read Figma Typography
Figma typography follows the pattern: `Category/Size/Weight`

Example: `UX/Title 1/Semibold` maps to `.uxTitle1Semibold`

### Typography Categories

#### UX Fonts (Interface Elements)
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `UX/Title 1/Semibold` | `.uxTitle1Semibold` | Main screen titles |
| `UX/Title 2/Semibold` | `.uxTitle2Semibold` | Section headers |
| `UX/Title 2/Regular` | `.uxTitle2Regular` | Subtitle text |
| `UX/Title 2/Medium` | `.uxTitle2Medium` | Medium weight subtitles |
| `UX/Body/Regular` | `.uxBodyRegular` | Regular body text |
| `UX/Callout/Regular` | `.uxCalloutRegular` | Callout text |
| `UX/Callout/Medium` | `.uxCalloutMedium` | Medium callouts |

#### Content Fonts (Document Text)
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Title` | `.title` | Document titles |
| `Heading` | `.heading` | Document headings |
| `Subheading` | `.subheading` | Document subheadings |
| `Body/Regular` | `.bodyRegular` | Document body text |
| `Body/Semibold` | `.bodySemibold` | Bold body text |
| `Callout/Regular` | `.calloutRegular` | Document callouts |

#### Caption Fonts
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Caption 1/Regular` | `.caption1Regular` | Small labels |
| `Caption 1/Medium` | `.caption1Medium` | Medium small labels |
| `Caption 1/Semibold` | `.caption1Semibold` | Bold small labels |
| `Caption 2/Regular` | `.caption2Regular` | Tiny labels |
| `Caption 2/Medium` | `.caption2Medium` | Medium tiny labels |
| `Caption 2/Semibold` | `.caption2Semibold` | Bold tiny labels |

#### Button Fonts
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Button 1/Regular` | `.button1Regular` | Button text |
| `Button 1/Medium` | `.button1Medium` | Medium button text |

### Usage in SwiftUI
```swift
// Using AnytypeText (recommended)
AnytypeText("Hello World", style: .uxTitle1Semibold)

// Using Text with font modifier
Text("Hello World")
    .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
```

**Note**: `.foregroundColor(.Text.primary)` is the default text color and does not need to be explicitly set. Only specify foreground color when using non-primary text colors.

## Icon Mapping

### Icon Size Convention
Icons are organized by size categories:
- `x18` - 18pt icons (small UI elements)
- `x24` - 24pt icons (medium UI elements)  
- `x32` - 32pt icons (large UI elements)
- `x40` - 40pt icons (extra large elements)

### How to Read Figma Icons
Figma icons follow the pattern: `Size/Icon Name`

Example: `32/qr code` maps to `Image(asset: .X32.qrCode)`

### Common Icon Mappings
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `18/search` | `Image(asset: .X18.search)` | Small search icons |
| `24/search` | `Image(asset: .X24.search)` | Medium search icons |
| `32/plus` | `Image(asset: .X32.plus)` | Add buttons |
| `32/add-filled` | `Image(asset: .X32.addFilled)` | Filled add buttons |
| `multiply-circle-fill` | `Image(asset: .multiplyCircleFill)` | Clear/close buttons |

### Usage in SwiftUI
```swift
// Standard icon usage
Image(asset: .X24.search)
    .foregroundColor(Color.Control.active)

// With frame
Image(asset: .X32.plus)
    .frame(width: 32, height: 32)
```

## Layout & Spacing

### Common Spacing Values
- `4pt` - Minimal spacing
- `8pt` - Small spacing (internal padding)
- `12pt` - Medium spacing
- `16pt` - Standard spacing (margins)
- `20pt` - Large spacing
- `24pt` - Extra large spacing

### Corner Radius Standards
- `10pt` - Standard corner radius (search bars, cards)
- `20pt` - Large corner radius (buttons, major UI elements)

## Best Practices

### Color Usage
1. Always use design system colors, never hardcoded hex values
2. Use semantic color names (`.primary`, `.secondary`) over specific color names
3. Respect dark/light mode variations built into the color system

### Typography Usage
1. Use `AnytypeText` component for consistency
2. Choose appropriate font categories (UX for interface, Content for documents)
3. Maintain typography hierarchy (Title > Heading > Body > Caption)

### Icon Usage
1. Use appropriate icon sizes for the context
2. Apply consistent foreground colors using design system
3. Consider icon semantic meaning and accessibility

### Code Generation
- Colors are generated from Assets.xcassets using SwiftGen
- Icons are generated from Assets.xcassets using SwiftGen  
- Typography is manually maintained in AnytypeFont.swift
- Always run `make generate` after asset changes

## File Locations
- **Colors**: `/Modules/Assets/Sources/Assets/Generated/Color+Assets.swift`
- **Typography**: `/Modules/DesignKit/Sources/DesignKit/Fonts/Config/AnytypeFont.swift`
- **Icons**: Generated in various Asset enums
- **Assets Source**: `/Modules/Assets/.../Assets.xcassets/`

## Reference Material

### Color System Documentation
- **[COLOR_SYSTEM.md](../../DesignSystem/COLOR_SYSTEM.md)** - Complete guide to color system architecture, renaming process, and code generation

### Key Workflows
- **Color Renaming**: Never rename colors in code - update assets, run `make generate`, then update usages
- **Asset Generation**: Run `make generate` after any asset changes
- **Design System Updates**: Update both asset catalogs and this mapping document