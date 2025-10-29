# Figma to Swift Typography Mapping

This document maps Figma text style names to Swift `AnytypeFont` enum cases.

## Mapping Rules

### Content Styles (ALWAYS remove "Content/" prefix)
- "Content/Body/Semibold" → `.bodySemibold`
- "Content/Preview Title 2/Regular" → `.previewTitle2Regular`
- "Content/Relation 3/Regular" → `.relation3Regular`

### UX Styles - Title, Body, Callout (KEEP "ux" prefix as lowercase)
- "UX/Title 1/Semibold" → `.uxTitle1Semibold`
- "UX/Title 2/Medium" → `.uxTitle2Medium`
- "UX/Body/Regular" → `.uxBodyRegular`
- "UX/Callout/Medium" → `.uxCalloutMedium`

### UX Styles - Captions (DROP "ux" prefix - EXCEPTION!)
- "UX/Caption 1/Medium" → `.caption1Medium` (no "ux")
- "UX/Caption 2/Regular" → `.caption2Regular` (no "ux")

## Complete Mapping Table

| Figma Style Name | Swift Constant | Size | Weight | Line Height | Letter Spacing |
|------------------|----------------|------|--------|-------------|----------------|
| **Content Styles** |
| Content/Title | `.title` | 28pt | Bold | 34pt | -0.36px |
| Content/Heading | `.heading` | 22pt | Semibold | 28pt | -0.26px |
| Content/Subheading | `.subheading` | 20pt | Semibold | 26pt | -0.45px |
| Content/Preview Title 1/Medium | `.previewTitle1Medium` | 17pt | Medium | 22pt | -0.41px |
| Content/Preview Title 1/Regular | `.previewTitle1Regular` | 17pt | Regular | 22pt | -0.41px |
| **Content/Preview Title 2/Regular** | **`.previewTitle2Regular`** | **15pt** | **Regular (400)** | **20pt** | **-0.24px** |
| **Content/Preview Title 2/Medium** | **`.previewTitle2Medium`** | **15pt** | **Medium (500)** | **20pt** | **-0.24px** |
| Content/Body/Regular | `.bodyRegular` | 17pt | Regular | 24pt | -0.41px |
| **Content/Body/Semibold** | **`.bodySemibold`** | **17pt** | **Semibold (600)** | **24pt** | **-0.41px** |
| Content/Callout/Regular | `.calloutRegular` | 16pt | Regular | 21pt | -0.32px |
| Content/Relation 1/Regular | `.relation1Regular` | 13pt | Regular | 18pt | -0.08px |
| Content/Relation 2/Regular | `.relation2Regular` | 13pt | Regular | 16pt | 0px |
| Content/Relation 3/Regular | `.relation3Regular` | 12pt | Regular | 15pt | 0px |
| **UX Styles (with "ux" prefix)** |
| UX/Title 1/Semibold | `.uxTitle1Semibold` | 28pt | Semibold | 34pt | -0.36px |
| UX/Title 2/Semibold | `.uxTitle2Semibold` | 17pt | Semibold | 22pt | -0.43px |
| UX/Title 2/Regular | `.uxTitle2Regular` | 17pt | Regular | 22pt | -0.43px |
| UX/Title 2/Medium | `.uxTitle2Medium` | 17pt | Medium | 22pt | -0.43px |
| UX/Body/Regular | `.uxBodyRegular` | 17pt | Regular | 22pt | -0.43px |
| UX/Callout/Regular | `.uxCalloutRegular` | 16pt | Regular | 21pt | -0.32px |
| UX/Callout/Medium | `.uxCalloutMedium` | 16pt | Medium | 21pt | -0.32px |
| **UX Styles (Captions - NO "ux" prefix)** |
| **UX/Caption 1/Medium** | **`.caption1Medium`** | **13pt** | **Medium (500)** | **18pt** | **-0.08px** |
| UX/Caption 1/Regular | `.caption1Regular` | 13pt | Regular | 18pt | -0.08px |
| UX/Caption 1/Semibold | `.caption1Semibold` | 13pt | Semibold | 18pt | -0.08px |
| UX/Caption 2/Medium | `.caption2Medium` | 11pt | Medium | 13pt | 0.06px |
| UX/Caption 2/Regular | `.caption2Regular` | 11pt | Regular | 13pt | 0.06px |
| UX/Caption 2/Semibold | `.caption2Semibold` | 11pt | Semibold | 13pt | 0.06px |
| **Special Styles** |
| Chat/Text | `.chatText` | 17pt | Regular | 24pt | -0.41px |
| Chat/Preview/Medium | `.chatPreviewMedium` | 15pt | Medium | 20pt | -0.24px |
| Chat/Preview/Regular | `.chatPreviewRegular` | 15pt | Regular | 20pt | -0.24px |
| Content/Code Block | `.codeBlock` | 16pt | Regular | 21pt | -0.32px |

## How to Use This Mapping

### Step 1: Get Figma Typography Info
In Figma, select the text element and check the "Typography" panel on the right. Look for the "Name" field, which shows the style name (e.g., "Content/Body/Semibold").

### Step 2: Map to Swift Constant
Use the table above to find the corresponding Swift constant:
- "Content/Body/Semibold" → `.bodySemibold`
- "Content/Preview Title 2/Regular" → `.previewTitle2Regular`
- "UX/Caption 1/Medium" → `.caption1Medium` (note: drops "ux")

### Step 3: Apply in SwiftUI
```swift
// Using Text with .anytypeStyle()
Text("Hello World")
    .anytypeStyle(.bodySemibold)

// Using AnytypeText
AnytypeText("Hello World", style: .previewTitle2Regular)
```

## Common Mistakes to Avoid

### ❌ WRONG: Using relation styles for 15pt text
```swift
// Feature descriptions should be 15pt
Text("Yours forever")
    .anytypeStyle(.relation3Regular)  // 12pt - TOO SMALL!
```

### ✅ CORRECT: Using preview title styles for 15pt text
```swift
// Feature descriptions at 15pt
Text("Yours forever")
    .anytypeStyle(.previewTitle2Regular)  // 15pt - CORRECT!
```

### ❌ WRONG: Guessing style names
```swift
// Don't guess or make up style names
.anytypeStyle(.bodyMedium)      // Doesn't exist!
.anytypeStyle(.preview2)         // Incomplete name!
.anytypeStyle(.uxCaption1Medium) // Caption styles don't have "ux" prefix!
```

### ✅ CORRECT: Use exact enum case names
```swift
// Use complete, exact enum case names
.anytypeStyle(.previewTitle2Medium)  // Correct!
.anytypeStyle(.bodySemibold)          // Correct!
.anytypeStyle(.caption1Medium)        // Correct! (no "ux" prefix)
```

### ❌ WRONG: Confusing UX prefix rules
```swift
// Caption styles don't use "ux" prefix
.anytypeStyle(.uxCaption1Medium)  // Doesn't exist!

// But Title/Body/Callout DO use "ux" prefix
.anytypeStyle(.title2Medium)      // Wrong! Should be .uxTitle2Medium
```

### ✅ CORRECT: Understanding UX prefix rules
```swift
// Caption styles: NO "ux" prefix
.anytypeStyle(.caption1Medium)     // Correct!

// Title/Body/Callout: YES "ux" prefix
.anytypeStyle(.uxTitle2Medium)     // Correct!
.anytypeStyle(.uxBodyRegular)      // Correct!
.anytypeStyle(.uxCalloutMedium)    // Correct!
```

## Quick Reference: Most Common Styles

### Content Text
- **Title/Heading**: `.title` (28pt), `.heading` (22pt), `.subheading` (20pt)
- **Body Text**: `.bodyRegular` (17pt), `.bodySemibold` (17pt)
- **Preview/Object Titles**:
  - 17pt: `.previewTitle1Regular`, `.previewTitle1Medium`
  - 15pt: `.previewTitle2Regular`, `.previewTitle2Medium` ⭐
- **Descriptions**:
  - 13pt: `.relation1Regular`, `.relation2Regular`
  - 12pt: `.relation3Regular`

### UI Elements
- **Titles**: `.uxTitle1Semibold` (28pt), `.uxTitle2Medium` (17pt)
- **Body**: `.uxBodyRegular` (17pt)
- **Captions/Labels**: `.caption1Medium` (13pt), `.caption2Regular` (11pt) ⭐

### Chat-Specific
- **Messages**: `.chatText` (17pt)
- **Previews**: `.chatPreviewMedium` (15pt)

⭐ = Commonly confused or misused

## Size Quick Reference

Need to find the right style by size?

| Size | Available Styles |
|------|------------------|
| 28pt | `.title`, `.uxTitle1Semibold` |
| 22pt | `.heading`, `.uxTitle2Semibold/Regular/Medium` |
| 20pt | `.subheading` |
| 17pt | `.previewTitle1*`, `.bodyRegular/Semibold`, `.uxTitle2*`, `.uxBodyRegular`, `.chatText` |
| 16pt | `.calloutRegular`, `.uxCalloutRegular/Medium`, `.codeBlock` |
| **15pt** | **`.previewTitle2Regular/Medium`**, `.chatPreviewMedium/Regular` |
| 13pt | `.relation1Regular`, `.relation2Regular`, `.caption1Semibold/Regular/Medium` |
| 12pt | `.relation3Regular` |
| 11pt | `.caption2Semibold/Regular/Medium` |

## Design Review Checklist

When reviewing Figma designs against implementation:

1. ✅ Check Typography panel for each text element in Figma
2. ✅ Verify the "Name" field shows a style (e.g., "Content/Body/Semibold")
3. ✅ Map Figma style name to Swift constant using this document
4. ✅ Verify size, weight, and line height match between Figma and Swift definition
5. ✅ Watch for caption styles - they drop the "ux" prefix
6. ✅ Update implementation if mismatch found

## Real-World Example: Chat Empty State

### Design Specifications (from Figma)
- **Title**: "You just created a chat" - `Content/Body/Semibold` (17pt, 600, 24pt)
- **Features**: "Yours forever", etc. - `Content/Preview Title 2/Regular` (15pt, 400, 20pt)
- **Buttons**: "Add members" - `UX/Caption 1/Medium` (13pt, 500, 18pt)

### Correct Implementation
```swift
// Title
Text(Loc.Chat.Empty.title)
    .anytypeStyle(.bodySemibold)  // ✅ Correct: 17pt/600/24

// Feature descriptions
Text(Loc.Chat.Empty.Feature.yoursForever)
    .anytypeStyle(.previewTitle2Regular)  // ✅ Correct: 15pt/400/20

// Button text (handled by StandardButton component)
StandardButton(Loc.Chat.Empty.Button.addMembers, style: .primaryXSmall)
// .primaryXSmall uses .caption1Medium internally ✅
```

### Common Mistakes in This Example
```swift
// ❌ WRONG: Using relation style for 15pt text
Text(Loc.Chat.Empty.Feature.yoursForever)
    .anytypeStyle(.relation3Regular)  // 12pt instead of 15pt!

// ❌ WRONG: Adding "ux" to caption style
StandardButton("Add", style: .uxCaption1Medium)  // Doesn't exist!
```

## Source Files

- **Enum definition**: `Modules/DesignKit/Sources/DesignKit/Fonts/Config/AnytypeFont.swift`
- **Font configurations**: `Modules/DesignKit/Sources/DesignKit/Fonts/Config/AnytypeFontConfig.swift`
- **Figma source**: [Typography-Mobile](https://www.figma.com/file/vgXV7x2v20vJajc7clYJ7a/Typography-Mobile?node-id=0%3A12)

## Contributing

Found a missing mapping or incorrect information? Update this document and:
1. Verify against `AnytypeFont.swift` enum
2. Verify specs in `AnytypeFontConfig.swift`
3. Test with actual Figma designs
4. Update examples if needed

---

*Last updated: 2025-10-23*
*This mapping is based on `AnytypeFont` enum and `AnytypeFontConfig` as of this date.*
