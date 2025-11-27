# Figma to Code Design System Mapping

*Last updated: 2025-07-14*

This document provides a comprehensive mapping between Figma design system elements and their corresponding code implementations in the Anytype iOS app.

## Color Mapping

### How to Read Figma Colors
In Figma, colors are displayed in the format: `Category/Subcategory/Name`

Example: `Shapes/Transparent Secondary` maps to `Color.Shape.transparentSecondary`

### Color Categories

#### Shape Colors
| Figma Name | Code Implementation | Usage |
|------------|-------------------|--------|
| `Shapes/Primary` | `Color.Shape.primary` | Primary shape backgrounds |
| `Shapes/Secondary` | `Color.Shape.secondary` | Secondary shape backgrounds |
| `Shapes/Tertiary` | `Color.Shape.tertiary` | Tertiary shape backgrounds |
| `Shapes/Transparent Primary` | `Color.Shape.transparentPrimary` | Semi-transparent overlays |
| `Shapes/Transparent Secondary` | `Color.Shape.transparentSecondary` | Search bars, subtle backgrounds |
| `Shapes/Transparent Tertiary` | `Color.Shape.transparentTertiary` | Light overlays |

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
.background(Color.Shape.transparentSecondary)

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

### How to Extract Spacing from Figma

Spacing is the **gap between elements**, not the distance between their starting positions. This is a critical distinction that's easy to get wrong.

#### The Correct Method

**Formula:**
```
Spacing = NextElement.Y - (CurrentElement.Y + CurrentElement.Height)
```

**Step-by-Step Process:**

1. **Select the first element** in Figma
   - Note the **Y position** (top edge)
   - Note the **Height**
   - Calculate **bottom edge**: Y + Height

2. **Select the second element** in Figma
   - Note the **Y position** (top edge)

3. **Calculate the spacing**:
   - Spacing = Second.Y - First.BottomEdge

#### ❌ Common Mistake: Top-to-Top Calculation

**WRONG APPROACH:**
```
Spacing = SecondElement.Y - FirstElement.Y  // This is WRONG!
```

**Why this is wrong:** This calculates the distance between the *starting positions* of both elements, not the actual gap between them. You're including the height of the first element in your spacing value, which doubles the spacing.

**Example of the mistake:**
- Title Y: 326px, Height: 24px
- Feature Y: 374px
- Wrong calculation: 374 - 326 = 48px ❌
- This includes the title's 24px height in the "spacing"!

#### ✅ Correct Example: Chat Empty State Spacing

Let's extract the spacing between the title and first feature in the Chat Empty State:

**Title Element:** "You just created a chat"
- Y position: 326px
- Height: 24px (visible in Figma inspector or annotation)
- **Bottom edge: 326 + 24 = 350px**

**First Feature:** "Yours forever"
- Y position: 374px

**Correct Spacing Calculation:**
```
Spacing = 374 - 350 = 24px ✅
```

This 24px is the actual gap between the bottom of the title and the top of the feature text.

**In SwiftUI:**
```swift
Text(title)
    .anytypeStyle(.bodySemibold)
Spacer.fixedHeight(24)  // ✅ Correct spacing
Text(featureText)
    .anytypeStyle(.previewTitle2Regular)
```

#### Reading Figma Spacing Annotations

When designers add spacing annotations in Figma (e.g., the orange "24" badge in the screenshot), these show the actual gap between elements. Always trust these annotations over manual calculations.

**If annotations are present:**
- Look for orange/red badges showing spacing values
- These are already calculated correctly
- Use the annotated value directly

**If annotations are missing:**
- Use the formula: `NextElement.Y - (CurrentElement.Y + CurrentElement.Height)`
- Double-check your math
- Consider asking the designer to add spacing annotations

#### Common Pitfalls to Avoid

1. **Forgetting element height**
   - Always account for the first element's height
   - Height information is in Figma's inspector panel (right side)

2. **Confusing line-height with element height**
   - Text elements have both font size and line height
   - Use the actual bounding box height, not just font size

3. **Ignoring padding**
   - Some elements have internal padding
   - The Y position is the outer edge, but visible content may be inset

4. **Mixing units**
   - Figma shows pixels (px)
   - SwiftUI uses points (pt)
   - On @1x screens: 1px = 1pt (but verify for your target device)

5. **Not verifying with annotations**
   - If your calculation differs significantly from a designer's annotation, you're probably wrong
   - Ask for clarification rather than assuming

#### Quick Reference Checklist

When extracting spacing from Figma:

- [ ] Note the **Y position** of the first element
- [ ] Note the **Height** of the first element
- [ ] Calculate **bottom edge**: Y + Height
- [ ] Note the **Y position** of the second element
- [ ] Calculate spacing: Second.Y - First.BottomEdge
- [ ] Verify against any spacing annotations in Figma
- [ ] Convert units if necessary (px → pt)

#### Visual Debugging

If spacing looks wrong after implementation:

1. **Check if text is clipping** - Your spacing may be too small
2. **Check if gap is too large** - You may have calculated top-to-top
3. **Compare side-by-side** - Take a Figma screenshot and compare with simulator
4. **Measure in simulator** - Use Xcode's View Hierarchy Debugger to measure actual spacing

### Dimension Standards

All dimensions in Figma designs should be **whole numbers (integers)**, not decimals.

#### ✅ Correct Dimensions
- Y: 326px, Height: 24px
- Y: 374px, Width: 179px
- Spacing: 12px, 24px

#### ❌ Incorrect Dimensions (Report to Design)
- Y: 484.5px ← Decimal position
- Width: 123.7px ← Fractional width
- Spacing: 18.3px ← Non-integer spacing

#### When You Encounter Decimal Dimensions

**What to do:**
1. **Round to the nearest integer**
   - 26.5px → 27px
   - 18.3px → 18px
   - 484.5px → 485px

2. **Document in implementation**
   ```swift
   Spacer.fixedHeight(27)  // Rounded from 26.5px in Figma
   ```

3. **Report to design team** (see section below)

**Why this matters:**
- iOS renders on pixel-aligned boundaries
- Decimal positions can cause blurry rendering
- Indicates design inconsistency or misalignment in Figma
- Makes implementation ambiguous (should 26.5 be 26 or 27?)

**Common causes of decimal dimensions:**
- Elements not snapped to pixel grid in Figma
- Manual positioning without grid constraints
- Rotated or transformed elements
- Copy-paste from other designs without alignment

### Report to Design Team

When you encounter issues during implementation, report them to the design team for improvement. This creates a feedback loop that improves design quality over time.

#### Issues That Should Be Reported

##### 1. Decimal/Fractional Dimensions ⚠️
**Issue:** Element positioned at Y: 484.5px or width: 123.7px

**Why report:** Non-integer dimensions cause ambiguity in implementation and can result in blurry rendering on iOS.

**Example:**
> "The button group (node 8858:18734) is positioned at Y: 484.5px. Could this be aligned to Y: 485px (or 484px) for cleaner implementation?"

##### 2. Missing Spacing Annotations
**Issue:** No spacing annotations between elements

**Why report:** Forces developers to manually calculate spacing, which is error-prone.

**Example:**
> "The Chat Empty State (node 8918:18622) is missing spacing annotations between the title and features. Could you add spacing badges to clarify the intended gaps?"

##### 3. Outdated Text Content
**Issue:** Figma shows "You just created a chat" but localization file has "Chat without the cloud"

**Why report:** Indicates design and implementation are out of sync.

**Example:**
> "The title text in Figma shows 'You just created a chat' but our localization key `Chat.Empty.Title` contains 'Chat without the cloud'. Which is the intended final text? Should Figma or localization be updated?"

##### 4. Missing Typography Specifications
**Issue:** Text element doesn't have a named style (e.g., "Content/Body/Semibold")

**Why report:** Developer must guess which font style to use.

**Example:**
> "The feature description text (nodes 8858:18739-18741) doesn't show a typography style name in the inspector. Could you apply the 'Content/Preview Title 2/Regular' style to make this explicit?"

##### 5. Missing Color Token Names
**Issue:** Colors shown visually but no design token specified

**Why report:** Developer must guess which color constant to use.

**Example:**
> "The icon color appears to be light gray but doesn't specify a color token. Should this use `Color.Control.transparentSecondary` or a different token?"

##### 6. Incomplete State Designs
**Issue:** Only normal state designed, missing hover/pressed/disabled states

**Why report:** Implementation may not handle all states correctly.

**Example:**
> "The 'Add members' button only shows the normal state. Could you provide designs for pressed and disabled states, or confirm that the standard button states should be used?"

##### 7. Elements Not Following Design System
**Issue:** Custom values instead of design system tokens

**Why report:** Maintains design system consistency.

**Example:**
> "The button uses a 14pt radius instead of the standard 14pt or 16pt from our corner radius system. Is this intentional or should it use a standard value?"

#### How to Report Design Issues

**Format:**
```
Design Feedback: [Feature Name]

Issue: [Brief description]
Location: [Figma file/frame/node ID]
Current State: [What's in Figma now]
Impact: [How this affects implementation]
Suggestion: [Proposed fix]

Screenshots: [If applicable]
```

**Example Report:**
```
Design Feedback: Chat Empty State

Issue: Decimal dimensions causing implementation ambiguity
Location: Figma node 8858:18734 (Button group)
Current State: Positioned at Y: 484.5px, spacing 26.5px
Impact: Must round to nearest integers, causing potential misalignment
Suggestion: Align to Y: 485px and spacing to 27px for pixel-perfect implementation
```

#### When NOT to Report

Don't report issues that are:
- **Subjective preferences** - "I think the button should be blue"
- **Implementation challenges** - "This is hard to code" (that's our job!)
- **Already discussed** - Check with team first to avoid duplicate reports
- **Within tolerances** - 0.5px differences that are unavoidable due to math

#### Best Practices for Design Feedback

1. **Be specific** - Include exact node IDs, dimensions, and locations
2. **Be constructive** - Suggest fixes, don't just complain
3. **Be collaborative** - Frame as questions, not demands
4. **Batch similar issues** - One report with multiple related items vs. many small reports
5. **Include context** - Explain *why* it matters for implementation
6. **Respect design decisions** - If designer confirms it's intentional, accept it

### Common Verification Mistakes to Avoid

When reviewing designs against implementation, avoid these lazy verification patterns that lead to incorrect assessments.

#### 1. ❌ Assuming Data is Missing Instead of Checking

**The Mistake:**

Claiming that specifications are "missing" or "not provided" without actually verifying the Figma data first.

**Real Examples from Design Reviews:**

**Example 1: Button Spacing**
- ❌ **WRONG**: "Button spacing seems reasonable. Without explicit Figma annotations, this is acceptable."
- ✅ **CORRECT**:
  - Check Figma data: Button 1 at X: 80, Width: 111 → Right edge: 191
  - Button 2 at X: 199 → Left edge: 199
  - Calculate: 199 - 191 = **8px** ✅
  - Verify implementation uses `spacing: 8` ✅

**Example 2: Icon Color**
- ❌ **WRONG**: "Icon color seems appropriate. Without explicit color tokens in design, this is acceptable choice."
- ✅ **CORRECT**:
  - Check Figma inspector panel
  - See "Control/Transparent Secondary" explicitly specified
  - Verify implementation: `Color.Control.transparentSecondary` ✅

**Why This is a Problem:**

- You're making assumptions instead of doing verification
- "Acceptable given missing specs" is often an excuse for laziness
- The data usually EXISTS in Figma - you just didn't look for it
- This leads to incorrect "verified" claims

**Correct Verification Process:**

1. **Check Figma inspector panel first**
   - Look at the right sidebar when element is selected
   - Colors, typography, dimensions are all listed there

2. **Check Figma data structure**
   - Review the design context data you fetched
   - Look for X/Y positions, widths, heights
   - Check for color variable names

3. **Calculate from positions if needed**
   - Horizontal spacing: `NextElement.X - (CurrentElement.X + CurrentElement.Width)`
   - Vertical spacing: `NextElement.Y - (CurrentElement.Y + CurrentElement.Height)`

4. **Only say "missing" if truly absent**
   - After checking inspector
   - After checking design context data
   - After asking designer if still unclear

5. **NEVER use "acceptable given missing specs"**
   - This is a red flag for lazy verification
   - Either verify it's correct OR mark it as needing investigation
   - Don't mark unverified items as "acceptable"

#### 2. ❌ Not Applying Your Own Spacing Formula

**The Mistake:**

You know the correct spacing formula but don't consistently apply it to verify every spacing value.

**Real Example:**

In the same review where I documented the spacing formula, I later:
- Correctly calculated title → feature spacing (24px) ✅
- But then said button spacing was "reasonable without annotations" ❌
- Instead of applying the same X-axis formula to verify it

**Why This is a Problem:**

- Inconsistent methodology
- Some spacing values get verified, others get hand-waved
- Undermines the value of the formula you just documented

**Correct Process:**

For EVERY spacing value in the design review:

1. **Identify the two elements**
2. **Get positions and dimensions** from Figma data
3. **Apply the formula**:
   - Vertical: `NextElement.Y - (CurrentElement.Y + CurrentElement.Height)`
   - Horizontal: `NextElement.X - (CurrentElement.X + CurrentElement.Width)`
4. **Compare to implementation**
5. **Mark as ✅ correct or ❌ mismatch**

Never skip the calculation just because it "looks about right."

#### 3. ❌ Confusing Dimensions vs Spacing

**The Mistake:**

Misinterpreting what Figma annotations are measuring - width/height vs spacing.

**Real Example:**

Figma screenshot shows:
- Orange badge "26" - This is WIDTH (X dimension)
- Orange badge "24" - This is HEIGHT (Y dimension)

Initial confusion:
- ❌ "I calculate 24px but screenshot shows 26"
- Reality: 26 is width, 24 is height - different measurements!
- ✅ Spacing is 24px, title height is 24px, title width is 179px (the "26" was misleading)

**Why This Happens:**

- Multiple orange/red badges in Figma can be confusing
- Some show dimensions (width/height)
- Some show spacing (gaps)
- Some show positions (X/Y coordinates)

**How to Avoid:**

1. **Look at annotation placement**
   - Horizontal badge on element = width
   - Vertical badge on element = height
   - Badge between elements = spacing

2. **Check annotation lines**
   - Solid line to element edges = dimension
   - Dashed line between elements = spacing

3. **Verify with calculation**
   - If annotation doesn't match your calculation, figure out what it's measuring
   - Don't assume it's spacing without checking

4. **When in doubt, ask designer**
   - "The '26' annotation - is this width or spacing?"

#### 4. ❌ Marking Items as "Low Priority" to Avoid Verification

**The Mistake:**

Labeling something "low priority" or "acceptable" to skip proper verification.

**Why This is Wrong:**

- Priority should be based on USER IMPACT, not verification difficulty
- Icon color being wrong is NOT low priority - users see it immediately
- Button spacing being wrong is NOT low priority - affects the entire layout

**Correct Prioritization:**

- **High Priority**: User-facing elements (text, colors, spacing users notice)
- **Medium Priority**: Edge cases, states, less visible elements
- **Low Priority**: Internal implementation details with no visual impact

Don't use priority as an excuse to skip verification work.

#### 5. ❌ Not Using Available Figma Data

**The Mistake:**

Saying "can't verify" when the data is right there in the Figma response.

**What You Have Access To:**

From `get_design_context` and `get_screenshot`:
- Element positions (X, Y)
- Element dimensions (Width, Height)
- Color variables (in inspector)
- Typography styles (in inspector)
- Element hierarchy
- Layer names
- Node IDs

**If You Don't Have It:**

- Call `get_design_context` with specific node ID
- Check the screenshot for inspector panel
- Look at the exported code for color/font details

**Only say "missing" if:**
- You've checked all available Figma data
- You've looked at inspector panels
- You've checked annotations in screenshots
- It's genuinely not specified anywhere

#### Quick Self-Check Before Claiming "Missing" or "Acceptable"

Ask yourself:

- [ ] Did I check the Figma inspector panel?
- [ ] Did I check the design context data?
- [ ] Did I look at annotations in screenshots?
- [ ] Did I calculate using the position/dimension data?
- [ ] Did I apply the spacing formula?
- [ ] Am I being lazy and assuming instead of verifying?

If you answered "no" to any of these, **go back and verify properly** instead of marking it "acceptable."

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