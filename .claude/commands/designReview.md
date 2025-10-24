USE EXTENDED THINKING

# Design Review Command

## Purpose
This command performs a two-way validation between SwiftUI implementation and Figma designs:
1. **Implementation → Design**: Verify code matches design specs (colors, fonts, spacing, components)
2. **Design → Implementation**: Validate design provides complete specifications for implementation

This helps developers ensure accuracy AND helps designers improve their handoff quality.

## Required Inputs
When running `/designReview`, provide:
1. **Linear issue ID or URL** - To fetch design context and Figma references
2. **SwiftUI view file paths** - Files to review (e.g., `Anytype/Sources/PresentationLayer/.../*.swift`)
3. **[Optional] Screenshot paths** - Rendered design screenshots for visual comparison

Example usage:
```
/designReview
Linear: IOS-5123
Files: Anytype/Sources/PresentationLayer/Spaces/SpaceHub/*.swift
Screenshots: /Users/.../Desktop/space_hub_design.png
```

## What Gets Validated

### Implementation Checks (Code → Design)
Verify the following elements match the Figma design:

#### Colors
- Text colors match design tokens
- Background colors match design tokens
- Border colors match design tokens
- Gradient definitions (if any)
- Color usage in all states (normal, hover, pressed, disabled)

#### Typography
- Font family (SF Pro, custom fonts)
- Font size (in points)
- Font weight (ultraLight, thin, light, regular, medium, semibold, bold, heavy, black)
- Line height / line spacing
- Letter spacing (if specified)
- Text alignment

#### Spacing
- Margins (leading, trailing, top, bottom)
- Padding (internal spacing within components)
- Gaps between elements (VStack/HStack spacing)
- Component sizes (height, width)
- Values should be in points (pt)

#### Components & Styles
- Button styles: primary, secondary, tertiary, warning, etc.
- Input field styles
- Card styles
- List item styles
- Component variants match design system

#### Icons & Images
- SF Symbol names match Figma asset names
- Icon sizes match design specs
- Icon colors match design tokens
- Custom image assets named correctly

#### Layout & Hierarchy
- Component arrangement matches design
- Z-index / layer ordering
- Alignment (leading, center, trailing)
- Fixed vs flexible sizing

#### States & Interactions
- Hover states (if applicable)
- Pressed/active states
- Disabled states
- Loading states
- Error states
- Empty states
- Animations/transitions (if specified)

### Design Completeness Checks (Design → Code)
Identify missing or unclear specifications in the design:

#### Missing Color Specifications
- Colors not defined in design tokens
- Inconsistent color usage
- Colors shown visually but no token name provided

#### Missing Typography Specifications
- Font weight not specified (just says "medium" without numeric value)
- Line height not provided
- Unclear font hierarchy

#### Missing Spacing Specifications
- Spacing shown visually but no numeric values
- Inconsistent spacing patterns
- No specification for responsive behavior

#### Missing Component Specifications
- Button states not designed (hover, pressed, disabled)
- Input field states incomplete
- No error state designs
- No empty state designs
- No loading state designs

#### Missing Icon/Asset Information
- SF Symbol names not provided (just icon screenshots)
- Icon sizes unclear
- Custom asset naming not specified

#### Missing Interaction Specifications
- Animation timing/easing not specified
- Transition behavior unclear
- No specification for edge cases

## Review Workflow

### Step 0: Load Design System Documentation
**FIRST STEP: Load project design documentation before starting the review**

1. Reference the **Quick Reference** section in `CLAUDE.md` which lists all design system documentation paths
2. Read all design documentation files listed there (Typography Mapping, Design System Mapping, etc.)
3. Use this documentation throughout the review as the source of truth for:
   - Figma text style names → Swift typography constants
   - Figma color names → Swift color tokens
   - Icon naming conventions
   - Spacing calculation formulas
   - Component style guidelines

**Why this matters:** The project maintains comprehensive mappings between Figma design system and Swift code. Using these documented mappings ensures accurate validation and provides educational references in the report.

**Future-proof:** When new documentation is added to CLAUDE.md Quick Reference, this command automatically uses it without needing updates.

### Step 1: Fetch Linear Context
- Use `mcp__linear__get_issue` to fetch issue details
- Extract Figma URLs from issue description or attachments
- Capture acceptance criteria and design requirements
- Note any design-specific comments

### Step 2: Read Implementation Files
- Use `Read` tool to load SwiftUI files
- Parse and extract:
  - Color usage (`.anytypeColor`, design system colors)
  - Font usage (`.uxTitle`, `.uxBody`, custom fonts)
  - Spacing values (padding, spacing, frame sizes)
  - Component styles (ButtonStyle, ViewModifier)
  - SF Symbol names
  - Layout structure (VStack, HStack, ZStack)
- Identify design system pattern usage
- **Cross-reference with design documentation** loaded in Step 0 to understand what each constant means

### Step 3: Fetch Figma Design Context
- Use `mcp__figma__get_design_context` to fetch design structure
- Use `mcp__figma__get_screenshot` to get visual reference
- Use `mcp__figma__get_code` (if available) for design specs
- Extract:
  - Color tokens and values
  - Typography specs
  - Spacing measurements
  - Component definitions
  - Asset names

### Step 4: Side-by-Side Comparison
Compare implementation against design systematically:
- Match each SwiftUI element to corresponding Figma element
- **Use design documentation from Step 0** to validate mappings (e.g., "Content/Body/Semibold" in Figma should map to `.bodySemibold` in Swift)
- Flag mismatches (wrong color, incorrect font, spacing off)
- Flag assumptions made in code (where design was unclear)
- Flag missing specifications in design
- Calculate match score based on critical elements
- **Reference specific documentation** when identifying issues (e.g., "per TYPOGRAPHY_MAPPING.md")

### Step 5: Generate Structured Report & Save to File
**CRITICAL: Save the complete report to a file FIRST before presenting to user**

Create comprehensive markdown report with:
- Executive summary with match score
- Implementation issues (for developers to fix)
- Design gaps (for designers to address)
- Action items for both teams
- Specific file paths and line numbers

**Save to:** `design_review_[feature_name].md`

### Step 6: Present Report in Stages (Interactive Workflow)
**DO NOT dump the entire report at once.** Present sections incrementally:

**Stage 1: Overview**
- Show Summary + Quick Assessment
- Let user understand the scope
- Ask: "Ready to review implementation mismatches?"

**Stage 2: Critical Implementation Fixes**
- Show only HIGH priority mismatches from "Action Items for Developers"
- User fixes these issues
- Verify fixes before moving on
- Ask: "Critical issues fixed? Ready for medium/low priority items?"

**Stage 3: Other Implementation Fixes**
- Show MEDIUM and LOW priority mismatches
- User fixes these issues
- Verify fixes before moving on
- Ask: "Implementation fixes complete? Ready to review design gaps?"

**Stage 4: Design Gaps Documentation**
- Show "Design Gaps" and "Action Items for Designers"
- Discuss what feedback to give designers
- Ask: "Design feedback documented? Ready for workflow improvements?"

**Stage 5: Workflow Improvements**
- Show "Workflow & Process Improvements" section
- Discuss how to improve the design review process
- Capture suggestions for command improvements

**Between each stage:** Pause and wait for user confirmation before proceeding.

### Step 7: Workflow Improvement Reflection
After completing the staged review, reflect on:
- What made this review difficult?
- What information was hard to find?
- What's missing from the design handoff?
- What tools/process could improve efficiency?
- How can we make this command better?

## Output Report Format

**NOTE:** This comprehensive format is for the file that gets saved (`design_review_[feature_name].md`).
DO NOT present this entire report to the user at once. Use the Staged Workflow (Step 6) to present sections incrementally.

Generate a markdown report with the following structure:

```markdown
# Design Review: [Feature Name] ([LINEAR_ID])

## Summary
- **Match Score**: [X/10] ([Explanation of scoring])
- **Critical Issues**: [Count] issues blocking accurate implementation
- **Design Gaps**: [Count] missing specifications
- **Reviewed Files**: [Number] files
  - [File path 1]
  - [File path 2]
- **Figma References**:
  - [Figma URL 1]
  - [Figma URL 2]
- **Review Date**: [Date]

## Quick Assessment
**Overall**: [Brief 1-2 sentence assessment]
**Priority Actions**:
1. [Most critical issue to address]
2. [Second most critical]

---

## Implementation vs Design Analysis

### ✅ Correct Implementations
Elements that correctly match the design:
- **[Element name]**: Correctly implements [spec detail]
  - Location: `[file path]:[line number]`
  - Value: [actual implementation]

### ❌ Implementation Mismatches
Elements that don't match the design:
- **[Element name]**: Mismatch found
  - **Found**: [actual value in code]
  - **Expected**: [value from design]
  - **Location**: `[file path]:[line number]`
  - **Reference**: According to [TYPOGRAPHY_MAPPING.md or DESIGN_SYSTEM_MAPPING.md], "[Figma style]" maps to `[correct Swift constant]`
  - **Impact**: [user-visible impact]
  - **Fix**: [specific correction needed]

### ⚠️ Design Gaps (Unclear/Missing Specifications)
Elements where design doesn't provide enough information:
- **[Element name]**: Missing specification
  - **What's missing**: [specific detail needed]
  - **Current implementation**: [what we did as best guess]
  - **Question for designer**: [what we need clarified]
  - **Location**: `[file path]:[line number]`

---

## Detailed Element Analysis

### Colors
#### Implementation
- Primary text: `[token name]` ([hex value])
- Background: `[token name]` ([hex value])
- Accent: `[token name]` ([hex value])
- [Other colors...]

#### Design
- Primary text: `[design token]` ([hex value])
- Background: `[design token]` ([hex value])
- Accent: `[design token]` ([hex value])
- [Other colors...]

#### Issues
- [ ] [Color issue 1]
- [ ] [Color issue 2]

### Typography
#### Implementation
- Title: `[style name]` (SF Pro [weight] [size]pt)
- Body: `[style name]` (SF Pro [weight] [size]pt)
- Caption: `[style name]` (SF Pro [weight] [size]pt)
- [Other typography...]

#### Design
- Title: [Figma spec]
- Body: [Figma spec]
- Caption: [Figma spec]
- [Other typography...]

#### Issues
- [ ] [Typography issue 1]
- [ ] [Typography issue 2]

### Spacing
#### Implementation
- Top margin: [value]pt
- Side padding: [value]pt
- Element gaps: [value]pt
- [Other spacing...]

#### Design
- Top margin: [value]pt
- Side padding: [value]pt
- Element gaps: [value]pt
- [Other spacing...]

#### Issues
- [ ] [Spacing issue 1]
- [ ] [Spacing issue 2]

### Components
#### Buttons
- **Implementation**: [button styles used]
- **Design**: [button styles specified]
- **Issues**: [list any mismatches]

#### Icons & Images
- **Implementation**: [SF Symbols/assets used]
- **Design**: [icons specified in Figma]
- **Issues**: [naming mismatches, size issues, etc.]

#### Other Components
- [Component type]: [findings]

### States & Edge Cases
#### Implemented States
- Normal: ✅/❌
- Hover: ✅/❌
- Pressed: ✅/❌
- Disabled: ✅/❌
- Loading: ✅/❌
- Error: ✅/❌
- Empty: ✅/❌

#### Design Provided States
- Normal: ✅/❌
- Hover: ✅/❌
- Pressed: ✅/❌
- Disabled: ✅/❌
- Loading: ✅/❌
- Error: ✅/❌
- Empty: ✅/❌

#### Issues
- [ ] [State/edge case issue 1]
- [ ] [State/edge case issue 2]

---

## Action Items

### For Developers (Implementation Fixes)
Priority order:
1. **[High Priority]** [Specific fix needed]
   - File: `[path]:[line]`
   - Change: [old value] → [new value]
   - Reason: [why this matters]

2. **[Medium Priority]** [Specific fix needed]
   - File: `[path]:[line]`
   - Change: [description]

3. **[Low Priority]** [Specific fix needed]
   - File: `[path]:[line]`
   - Change: [description]

### For Designers (Specification Improvements)
Priority order:
1. **[High Priority]** [Specific spec needed]
   - Element: [which element]
   - Missing: [what information]
   - Impact: [why this blocks accurate implementation]

2. **[Medium Priority]** [Specific spec needed]
   - Element: [which element]
   - Missing: [what information]

3. **[Low Priority]** [Nice to have improvement]
   - Element: [which element]
   - Suggestion: [how to improve clarity]

---

## Workflow & Process Improvements

### What Made This Review Difficult?
- [Challenge 1]
- [Challenge 2]

### What Information Was Hard to Find?
- [Issue 1]
- [Issue 2]

### Design Handoff Recommendations
- [Recommendation 1: e.g., "Include design token names in Figma layers"]
- [Recommendation 2: e.g., "Provide SF Symbol names in icon documentation"]
- [Recommendation 3: e.g., "Design all button states in a single frame"]

### Command Improvement Suggestions
How can we make `/designReview` better?
- [Suggestion 1]
- [Suggestion 2]
- [Suggestion 3]

---

## Appendix

### Files Reviewed
```
[Full path 1]
[Full path 2]
[Full path 3]
```

### Figma References
- [Figma link 1 with description]
- [Figma link 2 with description]

### Linear References
- Issue: [LINEAR_ID] - [URL]
- Related issues: [if any]

---

*This command is iterative. Please share feedback to improve the review process.*
```

## Implementation Guidelines

### Staged Workflow (Critical)
**MOST IMPORTANT**:
1. Generate the complete report FIRST
2. Save it to `design_review_[feature_name].md`
3. Present only Stage 1 (Summary) to the user
4. Wait for confirmation before showing Stage 2
5. Continue stage-by-stage, waiting for user to fix issues between stages
6. NEVER dump the entire report at once

### Tone & Approach
- **Constructive, not critical**: Frame as collaborative improvement
- **Specific, not vague**: Always include file paths, line numbers, exact values
- **Actionable**: Every issue should have a clear fix or question
- **Balanced**: Acknowledge both good matches and mismatches
- **Blame-free**: Don't blame developer or designer - focus on process improvement

### Technical Notes
- Use ONLY read-only tools during review (Read, Grep, Glob, Figma MCP, Linear MCP)
- No file modifications during the review process
- **Always load design documentation from CLAUDE.md Quick Reference first** (Step 0)
- Use typography/color mappings as source of truth for Figma → Swift validation
- When identifying mismatches, cite specific documentation (e.g., "According to TYPOGRAPHY_MAPPING.md, 'UX/Body/Regular' maps to `.uxBodyRegular`")
- Parse SwiftUI files carefully (look for design system usage patterns)
- Include context from Linear acceptance criteria

### Scoring Guidance
Match score (X/10) based on:
- **10**: Perfect match, all elements correct, design fully specified
- **8-9**: Minor issues, mostly correct with small adjustments needed
- **6-7**: Several mismatches or significant design gaps
- **4-5**: Major mismatches or many missing specs
- **1-3**: Significant rework needed, design unclear or implementation way off
- **0**: Implementation doesn't resemble design at all

### Prioritization
Focus on essential visual elements first:
1. **Critical**: Colors, fonts, spacing (users notice immediately)
2. **Important**: Components, icons, states (affects functionality)
3. **Nice-to-have**: Subtle animations, micro-interactions (polish)

Start lean, expand over time based on what's most valuable.

## Staged Presentation Guide

When presenting the review in stages, keep each section concise and actionable:

### Stage 1: Overview (Present First)
```markdown
# Design Review: [Feature Name] ([LINEAR_ID])
Saved to: design_review_[feature_name].md

## Summary
- Match Score: [X/10]
- Critical Issues: [Count]
- Design Gaps: [Count]

## Quick Assessment
[1-2 sentence overview]

Priority Actions:
1. [Most critical]
2. [Second most critical]

---
Ready to review critical implementation issues?
```

### Stage 2: Critical Fixes (Present After User Confirms)
```markdown
## Critical Implementation Issues (High Priority)

Fix these first:

1. [Issue name]
   - File: [path:line]
   - Found: [actual]
   - Expected: [design spec] (per [doc name])
   - Fix: [specific action]

2. [Issue name]
   - File: [path:line]
   - Found: [actual]
   - Expected: [design spec] (per [doc name])
   - Fix: [specific action]

---
Once fixed, let me know and we'll move to medium/low priority items.
```

### Stage 3: Other Fixes (Present After Critical Fixed)
```markdown
## Other Implementation Issues (Medium/Low Priority)

When you're ready, address these:

[List medium and low priority items in same format]

---
Implementation fixes complete? Ready to document design gaps?
```

### Stage 4: Design Gaps (Present After Implementation Fixed)
```markdown
## Design Gaps to Report

Questions for designers:

1. [Element]: [What's missing]
   - Current implementation: [what we did]
   - Need: [specific spec needed]

2. [Element]: [What's missing]
   - Current implementation: [what we did]
   - Need: [specific spec needed]

Summary for designer feedback:
[Bullet list of all missing specs]

---
Design feedback ready? Let's discuss workflow improvements.
```

### Stage 5: Workflow (Present Last)
```markdown
## Workflow Improvements

What made this review difficult:
- [Challenge 1]
- [Challenge 2]

Design handoff recommendations:
- [Recommendation 1]
- [Recommendation 2]

Command improvements:
- [Suggestion 1]
- [Suggestion 2]

---
Review complete! Full report saved in design_review_[feature_name].md
```

### Key Principles for Staged Presentation
- **Concise**: Show only what's needed for current stage
- **Actionable**: Each stage has clear next steps
- **Interactive**: Always end with a question/prompt
- **Progressive**: Don't move forward until current stage is complete
- **Reference**: Always mention the full report file for details

## Iterative Improvement

This command will evolve based on usage. After each review:
1. Note what was difficult or time-consuming
2. Identify repetitive checks that could be automated
3. Suggest additional validation criteria if needed
4. Propose better report formatting if current format isn't helpful
5. Share any discoveries about effective design review practices

---

**Remember**: The goal is to make both implementation AND design better. This is a two-way conversation, not a one-way audit.
