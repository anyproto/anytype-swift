USE EXTENDED THINKING

# Linear Context Gathering for iOS Release

## Purpose
This document guides the process of gathering context from Linear for an iOS release impact analysis.

## Process

### Step 1: Get Release Information
Ask the user:
- "What is the release task id"
- Example responses: "IOS-4626",

### Step 2: Use Linear MCP for Release Initiative
1. Search in Linear for the release project
2. Get the main release issue details

### Step 3: Comprehensive Epic Discovery
**CRITICAL**: Use ALL of these search approaches to ensure complete coverage:

#### A. Direct Parent-Child Relationships
1. List all issues with parentId of the main release task
2. List all issues with parentId of any discovered epics (recursive search)

#### B. Project-Based Search
1. Get all issues in the Release project filtered by iOS team
2. Search for issues with "Release 12" AND "iOS" in title
3. Search for issues with "[epic]" AND "Release 12" AND "iOS" in title or description

#### C. Pattern-Based Search
1. Search for all issues containing "Release 12 | iOS" in title
2. Search for all issues containing "[epic] Release 12" in title
3. Search for all issues with labels or tags related to the release

#### D. Team-Based Comprehensive Search
1. List ALL iOS team issues in the Release project (not just direct children)
2. Filter by date range around release creation date
3. Look for issues with release version numbers (e.g., "0.39.0")

### Step 4: Detailed Information Gathering
For EACH discovered epic/issue:

#### A. Basic Information
- Issue ID and Title
- Description and acceptance criteria
- Status (To Do, In Progress, Done, etc.)
- Priority (Urgent, High, Medium, Low)
- Assignees and reviewers
- Creation and update dates

#### B. Technical Context
- Linked Pull Requests (from attachments)
- Related GitHub issues or discussions
- API changes or middleware dependencies
- Performance implications
- Security considerations

#### C. Feature Scope
- User-facing changes
- New functionality vs. improvements
- Platform-specific implementations
- Integration points with other features

#### D. Risk Assessment
- Implementation complexity
- Dependencies on other teams/systems
- Migration requirements
- Backward compatibility concerns
- Testing coverage needs

#### E. Sub-task Analysis
For each epic, recursively find and analyze ALL sub-tasks:
- Use parentId search to find direct children
- Search for issues mentioning the epic ID in title/description
- Look for related implementation tasks

### Step 5: Cross-Platform Context
- Find related Desktop/Web releases
- Identify shared middleware dependencies
- Note platform-specific variations

### Step 6: Create Comprehensive Context Summary

## Output Format

```markdown
# Linear Context for iOS Release [NUMBER]

## Release Overview
- **Release**: [Name] ([ID])
- **Status**: [Status]
- **Timeline**: [Start] - [End]
- **Description**: [Release description]

## Epic Summary
**Total Epics**: [Count]
**Status Breakdown**:
- Done: [Count]  
- In Progress: [Count]
- Waiting for Testing: [Count]
- Code Review: [Count]
- Backlog: [Count]

## Major Feature Categories

### [Category 1: e.g., Chat & Communication]
1. **[Epic Name]** ([Epic ID])
   - **Status**: [Status]
   - **Priority**: [Priority]  
   - **Description**: [Brief description]
   - **Key Features**:
     - [Feature 1] ([Sub-task ID]) - [Status]
     - [Feature 2] ([Sub-task ID]) - [Status]
   - **Technical Notes**: [Implementation details]
   - **Risk Level**: [High/Medium/Low]
   - **Testing Focus**: [Specific areas]

### [Category 2: e.g., Notifications]
[Continue pattern for all categories...]

## Cross-Platform Dependencies
- [Dependency 1]: [Description]
- [Dependency 2]: [Description]

## Technical Architecture Impact
### New Systems/Components:
- [Component 1]: [Description and impact]
- [Component 2]: [Description and impact]

### Modified Systems:
- [System 1]: [Changes and impact]
- [System 2]: [Changes and impact]

### Database/Storage Changes:
- [Change 1]: [Impact]
- [Change 2]: [Impact]

## Testing Strategy Recommendations
### High Priority Areas:
1. **[Area 1]**: [Why critical]
2. **[Area 2]**: [Why critical]

### Integration Testing Focus:
- [Integration 1]
- [Integration 2]

### Performance Testing:
- [Performance area 1]
- [Performance area 2]

## Risk Analysis

### High Risk Areas:
- **[Risk 1]**: [Description and mitigation]
- **[Risk 2]**: [Description and mitigation]

### Medium Risk Areas:
- **[Risk 1]**: [Description]  
- **[Risk 2]**: [Description]

### Dependencies & Blockers:
- [Dependency 1]: [Status and impact]
- [Dependency 2]: [Status and impact]

## Release Readiness Assessment
- **Epic Completion**: [X/Y] ([Z%])
- **Critical Path Items**: [List]
- **Remaining Blockers**: [List]
- **Testing Status**: [Assessment]
- **Documentation Status**: [Assessment]

## Recommendations
1. **[Recommendation 1]**
2. **[Recommendation 2]**
3. **[Recommendation 3]**
```

## Critical Success Factors
1. **Comprehensive Search**: Must use ALL search approaches to avoid missing epics
2. **Recursive Discovery**: Follow parent-child relationships completely
3. **Cross-Reference Validation**: Verify epic counts against Linear UI
4. **Technical Deep Dive**: Don't just list features, understand implementation impact
5. **Risk-First Analysis**: Lead with what could go wrong, not just what's planned

## Usage Instructions
1. Start by asking for the release ID
2. **Execute ALL search approaches** - don't skip any
3. Cross-reference results with Linear UI to verify completeness
4. Create comprehensive analysis covering technical, testing, and risk perspectives
5. Save as: `linear_context_release_[NUMBER].md`

## Validation Checklist
Before finalizing analysis:
- [ ] Epic count matches Linear UI display
- [ ] All major feature categories identified
- [ ] Technical dependencies mapped
- [ ] Risk assessment completed
- [ ] Testing recommendations provided
- [ ] Cross-platform impacts noted