USE EXTENDED THINKING

# iOS Release Impact Analysis & Comprehensive Changelog Generator

## Purpose
This document combines Linear context and Git changes to produce comprehensive impact analysis and detailed changelog for professional writers.

## Required Inputs
1. `linear_context_release_[NUMBER].md` - From Part 1
2. `git_changes_release_[NUMBER].md` - From Part 2
3. Release number

## Analysis Process

### Step 1: Cross-Reference Linear and Git Data
For each Linear project/feature:
1. Find corresponding code changes in Git data
2. Match commit messages to Linear story IDs
3. Identify gaps (Linear stories without code changes, or vice versa)
4. Note any discrepancies

### Step 2: Calculate Impact Scores
For each change:
- **High Impact**: Core functionality, authentication, data model, critical UI
- **Medium Impact**: Feature additions, non-critical UI, configuration
- **Low Impact**: Minor fixes, documentation, tests

Consider:
- Number of files changed
- Type of files (core vs peripheral)
- Linear priority
- Risk areas identified

### Step 3: Generate Testing Recommendations
Based on:
- Linear acceptance criteria
- Code change scope
- Risk assessment
- Dependencies

## Output 1: Impact Analysis Report

```markdown
# iOS Release [NUMBER] - QA Impact Analysis

## EXECUTIVE SUMMARY
- **Release**: [NUMBER]
- **LINEAR Initiative**: [Name] ([ID])
- **Comparison**: [BASE] to [TARGET]
- **Analysis Date**: [DATE]
- **Total Impact Score**: [HIGH/MEDIUM/LOW]
- **Critical Changes**: [COUNT]
- **Must-Test Features**: 
  1. [Feature] (LINEAR: [ID]) - [Reason]
  2. [Feature] (LINEAR: [ID]) - [Reason]
  3. [Feature] (LINEAR: [ID]) - [Reason]
- **Estimated Testing Effort**: [X] person-days
- **Risk Level**: [HIGH/MEDIUM/LOW]
- **Recommended Testing Strategy**: [Regression/Targeted/Full]

## LINEAR vs CODE ALIGNMENT
### ✅ Implemented Features (Linear → Code)
- [Feature 1] ([LINEAR ID]) → [Related commits/files]
- [Feature 2] ([LINEAR ID]) → [Related commits/files]

### ⚠️ Gaps Identified
- Linear stories without code changes: [List]
- Code changes without Linear stories: [List]

## DETAILED IMPACT ANALYSIS

### 1. Critical Impact Areas (P0 - Must Test)

#### [Feature/Area Name]
- **LINEAR Reference**: [Story IDs]
- **Code Changes**: 
  - [File 1]: [Change description]
  - [File 2]: [Change description]
- **Impact**: [Description of user impact]
- **Test Scenarios**:
  1. [Scenario from Linear AC]
  2. [Additional scenario from code analysis]
  3. [Edge case identified]
- **Regression Scope**: [Related features to verify]
- **Risk**: [HIGH/MEDIUM/LOW] - [Reason]

### 2. High Impact Areas (P1)
[Continue same structure]

### 3. Medium Impact Areas (P2)
[Continue same structure]

### 4. Low Impact Areas (P3)
[Continue same structure]

## TECHNICAL CHANGES SUMMARY

### API/Backend Integration
- **New Endpoints**: [List with methods]
- **Modified Endpoints**: [List with changes]
- **Breaking Changes**: [Any?]
- **Testing Required**: [API test scenarios]

### UI/UX Changes
- **New Screens/Flows**: [List]
- **Modified Screens**: [List with changes]
- **Animation/Transitions**: [Changes]
- **Dark Mode Impact**: [Any specific changes]
- **Accessibility**: [Changes affecting VoiceOver, Dynamic Type]

### Data/Storage
- **Model Changes**: [List]
- **Migration Required**: [Yes/No - Details]
- **Cache Impact**: [Changes]

### Configuration/Permissions
- **New Permissions**: [List with justification]
- **Build Settings**: [Changes]
- **Feature Flags**: [New/Modified flags]

## TESTING STRATEGY

### Regression Test Suite
Based on changes, full regression needed for:
- [Area 1]
- [Area 2]

### New Test Scenarios
From Linear acceptance criteria and code changes:
1. [Scenario 1]
2. [Scenario 2]

### Performance Testing
Areas requiring performance validation:
- [Area 1]: [Metrics to measure]
- [Area 2]: [Metrics to measure]

### Device/OS Matrix
Critical combinations based on changes:
- [Device/OS combinations]

## RISK MITIGATION

### High Risk Items
1. **[Risk]**
   - Mitigation: [Steps]
   - Testing focus: [Specific scenarios]

### Dependencies
- External: [List]
- Internal: [List]

## TESTING TIMELINE RECOMMENDATION
- **Setup & Environment Prep**: [X] days
- **Feature Testing**: [X] days
- **Integration Testing**: [X] days
- **Regression Testing**: [X] days
- **Performance Testing**: [X] days
- **Total**: [X] days

## APPENDIX
### Useful Commands for QA
```bash
# Check specific feature branch
git checkout [branch]

# View specific file history
git log -p -- [filepath]

# Test specific commit
git checkout [commit_hash]
```
```

## Output 2: Clean Changelog for Product Communication

```markdown
# iOS Release [NUMBER] - What's New

**Version**: [X.Y.Z]  
**Theme**: [One-line description of the release focus]

## 🆕 New Features

### 💬 Chat & Collaboration

#### [Chat-related Feature Name] ([LINEAR_ID])
**What it does**: [Simple, user-focused explanation in 1-2 sentences]

**How to use it**: [Brief steps or where to find it]

**Why we built it**: [User benefit or problem it solves]

### 📱 Mobile Experience

#### [Mobile Feature Name] ([LINEAR_ID])
[Continue same simple structure]

### [Other category if needed]

#### [Feature Name] ([LINEAR_ID])
[Continue same simple structure]

## 💫 Improvements

### 💬 Chat & Collaboration

#### [Chat Improvement Name] ([LINEAR_ID])
**What changed**: [Brief before/after comparison]

**Why we improved it**: [User feedback or benefit]

### 📱 Mobile Experience

#### [Mobile Improvement Name] ([LINEAR_ID])
[Continue same structure]

### 🏠 Space Management

#### [Space Improvement Name] ([LINEAR_ID])
[Continue same structure]

## 🐛 Bug Fixes

### General Fixes
- **[Bug area]** ([LINEAR_ID]): [What was broken] → [Now it works properly]
- **[Bug area 2]** ([LINEAR_ID]): [What was broken] → [Now it works properly]
- **[Bug area 3]** ([LINEAR_ID]): [What was broken] → [Now it works properly]

## 📱 Compatibility
- **iOS Support**: [Minimum version required]
- **What's needed**: [Any special requirements in simple terms]

---

*Questions? Contact [support channel]*
```

## Instructions for Clean Changelog Generation

When creating the changelog from Linear and Git data:

1. **Focus on USER VALUE, not technical details**
   - NO component names, file names, or implementation details
   - NO technical jargon unless absolutely necessary
   - NO repetition of the same information

2. **Include LINEAR IDs for reference**
   - Add Linear story/bug IDs in parentheses after feature names
   - Use format: (IOS-XXXX) or (PROJECT-NAME) as appropriate
   - Keep them subtle - they're for reference, not the main focus

3. **Group by THEMES when logical**
   - Use emoji + category headers to group related features/improvements
   - Common categories:
     - 💬 Chat & Collaboration
     - 📱 Mobile Experience  
     - 🏠 Space Management
     - 🔐 Security & Privacy
     - ⚡ Performance
   - If a major new feature has related improvements, group them together
   - Don't force grouping if items don't naturally fit

4. **Keep it CONCISE**
   - Each feature/improvement gets 3-5 lines maximum
   - Bug fixes are one-liners
   - No lengthy explanations

5. **Structure Requirements**:
   - **New Features**: Only truly NEW functionality (not improvements to existing features)
   - **Improvements**: Changes to existing features that users will notice
   - **Bug Fixes**: Simple list of what was broken and now works

6. **Language Guidelines**:
   - Write as if explaining to a non-technical friend
   - Use active voice ("You can now..." instead of "Users are able to...")
   - Focus on benefits, not features ("Share files instantly" not "File sharing system implemented")

7. **What to EXCLUDE**:
   - Technical architecture changes (unless they directly impact users)
   - Internal improvements that users won't notice
   - Feature flags and configuration changes
   - Code statistics and commit counts
   - API details
   - Performance metrics (unless dramatic and user-facing)

## Output 3: Team Message

Generate a concise, realistic message for team communication (Slack, etc.)

**Requirements:**
- Keep under 12 lines total (medium Slack message size)
- No emojis or excessive hype
- Plain text, professional tone
- Balance user-facing and technical work
- Humble and honest about the release scope

**Template Structure:**
```
Release [NUMBER] - [Descriptive Theme]

What users see: [2-3 sentence summary of user-visible features]

What we actually did: [2-3 sentence summary of technical work - refactoring, cleanup, infrastructure]

[Key stats]: [X] files, [X] commits, net [+/-X] lines.

Linear said [X] projects. Git says [X+] initiatives. The gap is [explanation of additional work].

[Honest assessment]. [Simple close].
```

**Content Guidelines:**
- Lead with honest characterization (e.g., "The Cleanup Release", "The Stability Release")
- **What users see** vs **What we actually did** contrast
- Include raw numbers without hyperbole
- Acknowledge gap between planned scope and actual work
- End with realistic assessment (not sexy but necessary, codebase healthier, etc.)
- Simple close: "Onward." or "Shipping it." - no forced enthusiasm
- Avoid: "basically rewrote", "wizards", "HERO", excessive emojis, marketing speak

## Usage Instructions
1. Load both context files from Parts 1 & 2
2. Cross-reference Linear stories with Git changes
3. Calculate impact scores for each change
4. Generate comprehensive testing recommendations
5. Create clean changelog focused on user value (not technical details)
6. Create team message
7. Save outputs:
   - `impact_analysis_release_[NUMBER].md`
   - `clean_changelog_release_[NUMBER].md`
   - `team_message_release_[NUMBER].txt`

## Tips for Creating Clean Changelog
- Focus on WHAT users can do, not HOW it was built
- Use simple, everyday language - no technical jargon
- Keep descriptions brief (3-5 lines per feature maximum)
- Group similar changes together to avoid repetition
- Lead with the user benefit, not the feature name
- For bugs, just say what was broken and that it now works
- Skip any technical details unless they directly affect users
- Write as if explaining to a friend who uses the app