USE EXTENDED THINKING

# iOS Release Impact Analysis & Release Notes Generator

## Purpose
This document combines Linear context and Git changes to produce comprehensive impact analysis and release notes.

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

## Output 2: Release Notes

```markdown
# iOS App Release [NUMBER] - Release Notes

## Version [X.Y.Z] - [DATE]

### 🎉 What's New

#### [Feature Name 1]
[User-friendly description of the feature, derived from Linear description and code implementation]
- [Benefit 1]
- [Benefit 2]

#### [Feature Name 2]
[Description]

### 🔧 Improvements
- **[Area]**: [Improvement description]
- **[Area]**: [Improvement description]

### 🐛 Bug Fixes
- Fixed an issue where [description from commit/Linear]
- Resolved [description]
- Corrected [description]

### 🔒 Security Updates
- [Any security-related changes, if applicable]

### 📱 Compatibility
- Requires iOS [version] or later
- Optimized for [devices]

### 💡 Known Issues
- [Issue 1] - Workaround: [if any]
- [Issue 2] - Fix planned for next release

---

### Internal Release Notes (For QA/Dev Team)

#### Technical Changes
- [Technical change 1]
- [Technical change 2]

#### API Updates
- [Endpoint changes]

#### Configuration Changes
- [Config updates]

#### Dependencies Updated
- [Library updates]
```

## Usage Instructions
1. Load both context files from Parts 1 & 2
2. Cross-reference Linear stories with Git changes
3. Calculate impact scores for each change
4. Generate comprehensive testing recommendations
5. Create both QA impact analysis and release notes
6. Save outputs:
   - `impact_analysis_release_[NUMBER].md`
   - `release_notes_[NUMBER].md`

## Tips for Analysis
- Always verify Linear story completion against actual code
- Look for implicit changes (e.g., a UI change might affect accessibility)
- Consider cascade effects of data model changes
- Check for performance implications of new features
- Validate that all acceptance criteria have corresponding code