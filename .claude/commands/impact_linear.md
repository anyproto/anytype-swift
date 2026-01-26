USE EXTENDED THINKING

# Linear Context Gathering for iOS Release (Task Hierarchy Approach)

## Purpose
This document guides the process of gathering comprehensive context from Linear for iOS release impact analysis and changelog generation, using a hierarchical task structure.

**CRITICAL: Use ONLY Linear MCP tools (`mcp__linear-server__*`). DO NOT use git, bash, or GitHub CLI commands. All information comes from Linear API.**

## Task Hierarchy Structure
Releases are organized as a parent task with nested subtasks:

```
Release Task (IOS-XXXX)
├── Standalone Tasks (direct subtasks)
│   ├── IOS-YYYY: Bump app version
│   ├── IOS-ZZZZ: Enable Feature Toggles
│   └── IOS-AAAA: Release notes
└── Epics (subtasks with "[epic]" in title)
    ├── [epic] Release X | iOS | Platform
    │   ├── IOS-BBBB: Task 1
    │   └── IOS-CCCC: Task 2
    ├── [epic] Release X | iOS | New Navigation
    │   └── IOS-DDDD: Task 3
    └── [epic] Release X | iOS | Basic quality
        └── IOS-EEEE: Task 4
```

## Process

### Step 1: Get Release Task ID
Ask the user:
- "What is the release task ID?"
- Example: "IOS-5467"

### Step 2: Fetch Release Task and Build Hierarchy
1. **Get the release task**: Use `mcp__linear-server__get_issue` with the release task ID
2. **Get all level-1 subtasks**: Use `mcp__linear-server__list_issues` with `parentId` = release task UUID
3. **Identify epics**: Subtasks with `[epic]` in the title contain nested work
4. **Get level-2 subtasks**: For each epic, use `mcp__linear-server__list_issues` with `parentId` = epic UUID
5. **Count total tasks** to validate completeness

### Step 3: Detailed Information Gathering with Links
For EACH task in the hierarchy:

#### A. Basic Information with URLs
- Issue ID and Title
- **Full Linear URL** (e.g., https://linear.app/company/issue/IOS-1234)
- **Parent Project URL** and name (if applicable)
- Description and acceptance criteria
- Status (To Do, In Progress, Done, etc.)
- Priority (Urgent, High, Medium, Low)
- Assignees and reviewers
- Creation and update dates
- **Labels with their URLs**

#### B. Technical Context with References
- **Linked Pull Requests** (capture full GitHub URLs)
- **Related GitHub issues** (full URLs)
- **Linked Linear issues** (full URLs and relationship type)
- **API documentation links**
- **Design/Figma links**
- **Confluence/Notion documentation links**
- Performance benchmarks or dashboard links
- Security assessment links

#### C. Feature Scope with Relationships
- User-facing changes
- New functionality vs. improvements
- Platform-specific implementations
- Integration points with other features
- **Related epics/stories URLs** (even if not in the view)

#### D. Risk Assessment with References
- Implementation complexity
- Dependencies on other teams/systems (with Linear issue links)
- Migration requirements (with documentation links)
- Backward compatibility concerns
- Testing coverage needs (with test plan links if available)

#### E. Sub-task Analysis with Full Hierarchy (RECURSIVE)
The hierarchy is built in Step 2, but **check ALL levels recursively**:
- Level 0: Release task
- Level 1: Direct subtasks (standalone tasks + umbrella groups)
- Level 2: Subtasks of umbrella groups (implementation tasks)
- **Level 3+: Check if ANY task has its own subtasks**

**CRITICAL**: Non-epic umbrella tasks (like "leftovers", "polish", "multi-chat") often contain important feature subtasks. Always recurse into them.

**Example of missed hierarchy**:
```
Release Task (fetched ✓)
├── Platform (subtasks fetched ✓)
├── Navigation (subtasks fetched ✓)
├── Multi chats leftovers (HAS subtasks but wasn't recursed!)
│   ├── IOS-5337 Settings menu for chat ← MISSED!
│   ├── IOS-5556 Unread section ← MISSED!
│   └── IOS-5330 Chat creation ← MISSED!
```

- **Capture full parent-child URL relationships**
- **Create a URL hierarchy map showing full depth**

### Step 4: Cross-Platform Context with Links
- Find related Desktop/Web releases (with Linear URLs)
- Identify shared middleware dependencies (with issue links)
- Note platform-specific variations
- **Link to cross-platform coordination issues**

### Step 5: Extract Linear Issue IDs for Changelog
**CRITICAL**: All tasks in the hierarchy already have Linear ISSUE IDs (IOS-XXXX format).

### ID Format Distinction
1. **Issue UUIDs** (hash format like `cab796c7-b58d-4876-b1a4-cc9f39da1431`):
   - Used internally by Linear API for parentId queries
   - Required for `list_issues` parentId parameter
   - **DO NOT use these in changelogs**

2. **Issue Identifiers** (format like `IOS-5467`, `IOS-5474`):
   - Human-readable task identifiers (the `identifier` field)
   - Present on ALL tasks including release tasks and epics
   - **USE THESE in changelogs and impact reports**

### How to Extract Issue IDs
**The task hierarchy approach automatically captures all issue IDs:**

1. **Release task** has an identifier (e.g., IOS-5467)
2. **Level-1 subtasks** each have identifiers (e.g., IOS-5471, IOS-5474)
3. **Level-2 subtasks** (under epics) each have identifiers (e.g., IOS-5715, IOS-5713)
4. **Attachments field** contains linked PR URLs

### Issue ID Mapping Example
```
Release Task: IOS-5467 "Release 16 iOS 0.44.0"
├── IOS-5717: Bump app version (standalone)
├── IOS-5471: Enable Feature Toggles (standalone)
├── IOS-5474: [epic] Release 16 | iOS | Platform
│   ├── IOS-5715: Upgrade iOS skills
│   ├── IOS-5714: Match skills spec
│   └── IOS-5713: membership tiers degradation
└── IOS-5643: [epic] Release 16 | iOS | New Navigation
    └── IOS-5644: Navigation implementation task
```

**For changelog**: Use all IOS-XXXX identifiers from the hierarchy

## Step 6: Create Comprehensive Context Summary with Full References
**CRITICAL: Always save the analysis as a file immediately after completion**

## Output Format

```markdown
# Linear Context for iOS Release [NUMBER]

## Release Overview
- **Release Task**: [Name] ([ID]) - [URL]
- **Version**: [X.Y.Z]
- **Status**: [Status]
- **Project**: [Project Name]
- **Description**: [Release description]

## Task Summary
**Total Tasks**: [Count]
- **Standalone Tasks**: [Count]
- **Epics**: [Count]
- **Epic Subtasks**: [Count]

**Status Breakdown**:
- Done: [Count]
- In Progress: [Count]
- Waiting for Testing: [Count]
- Code Review: [Count]
- Backlog: [Count]
- Canceled: [Count]

## Complete Task Hierarchy

```
Release: IOS-XXXX "[Title]" - [URL]
├── IOS-YYYY: [Standalone Task 1] - [Status] - [URL]
├── IOS-ZZZZ: [Standalone Task 2] - [Status] - [URL]
├── IOS-AAAA: [epic] [Epic 1 Title] - [Status] - [URL]
│   ├── IOS-BBBB: [Task 1] - [Status] - [URL]
│   └── IOS-CCCC: [Task 2] - [Status] - [URL]
└── IOS-DDDD: [epic] [Epic 2 Title] - [Status] - [URL]
    └── IOS-EEEE: [Task 3] - [Status] - [URL]
```

## Epics Detail

### [Epic 1: e.g., Platform]
**Epic**: IOS-XXXX "[epic] Release X | iOS | Platform"
- **Linear URL**: [Full URL]
- **Status**: [Status]
- **Priority**: [Priority]
- **Description**: [Brief description]

**Subtasks** ([Count]):
| ID | Title | Status | Assignee | PRs |
|----|-------|--------|----------|-----|
| IOS-YYYY | [Title] | [Status] | [Name] | [PR URLs] |
| IOS-ZZZZ | [Title] | [Status] | [Name] | [PR URLs] |

**Related Links**:
- Design: [Figma URL]
- Docs: [Documentation URL]

**Technical Notes**: [Implementation details]
**Risk Level**: [High/Medium/Low]
**Testing Focus**: [Specific areas]

### [Epic 2: e.g., New Navigation]
[Continue pattern for all epics...]

## Standalone Tasks

| ID | Title | Status | Assignee | PRs |
|----|-------|--------|----------|-----|
| IOS-XXXX | [Title] | [Status] | [Name] | [PR URLs] |

## Cross-Platform Dependencies
- **[Dependency 1]**: [Description]
  - Desktop Issue: [ID] - [URL]
  - Web Issue: [ID] - [URL]
  - Middleware Issue: [ID] - [URL]

## Technical Architecture Impact
### New Systems/Components:
- **[Component 1]**: [Description and impact]
  - Implementation Issue: [ID] - [URL]
  - Documentation: [URL]

### Modified Systems:
- **[System 1]**: [Changes and impact]
  - Modification Issue: [ID] - [URL]
  - Related PRs: [GitHub URLs]

### Database/Storage Changes:
- **[Change 1]**: [Impact]
  - Migration Issue: [ID] - [URL]
  - Schema Docs: [URL]

## External References

### GitHub Integration
- **Pull Requests**: 
  - [PR Title] - [GitHub URL] - Linear: [ID]
  - [PR Title] - [GitHub URL] - Linear: [ID]

### Documentation
- **API Docs**: [URL]
- **Architecture Docs**: [URL]
- **User Guides**: [URL]

### Design Assets
- **Figma Files**: 
  - [Design Name] - [Figma URL] - Linear: [ID]

## Testing Strategy Recommendations
### High Priority Areas:
1. **[Area 1]**: [Why critical]
   - Test Plan: [URL if available]
   - Related Issues: [URLs]

### Integration Testing Focus:
- [Integration 1] - Related Issue: [URL]
- [Integration 2] - Related Issue: [URL]

### Performance Testing:
- [Performance area 1] - Benchmark: [URL]
- [Performance area 2] - Dashboard: [URL]

## Risk Analysis

### High Risk Areas:
- **[Risk 1]**: [Description and mitigation]
  - Tracking Issue: [ID] - [URL]
  - Related Discussion: [URL]

### Medium Risk Areas:
- **[Risk 1]**: [Description]
  - Tracking Issue: [ID] - [URL]

### Dependencies & Blockers:
- **[Dependency 1]**: [Status and impact]
  - Blocking Issue: [ID] - [URL]
  - Team Responsible: [Team] - [Team Linear URL]

## Release Readiness Assessment
- **Project Completion**: [X/Y] ([Z%])
- **Critical Path Items**: 
  - [Item 1] - [URL]
  - [Item 2] - [URL]
- **Remaining Blockers**: 
  - [Blocker 1] - [URL]
  - [Blocker 2] - [URL]
- **Testing Status**: [Assessment]
  - Test Suite: [URL if available]
- **Documentation Status**: [Assessment]
  - Docs: [URL]

## Complete Project List with URLs
### Done
- [ID]: [Title] - [URL] - Category: [Category]
- [ID]: [Title] - [URL] - Category: [Category]

### In Progress
- [ID]: [Title] - [URL] - Category: [Category]
- [ID]: [Title] - [URL] - Category: [Category]

### Pending
- [ID]: [Title] - [URL] - Category: [Category]
- [ID]: [Title] - [URL] - Category: [Category]

## Recommendations
1. **[Recommendation 1]** - Related: [URL]
2. **[Recommendation 2]** - Related: [URL]
3. **[Recommendation 3]** - Related: [URL]
```

## Critical Success Factors
1. **Hierarchy Traversal**: Ensure ALL levels are fetched (release → subtasks → epic subtasks)
2. **Epic Detection**: Identify epics by `[epic]` in the title
3. **URL Capture**: Record full Linear URLs for every task
4. **Relationship Mapping**: Document all parent-child relationships via parentId
5. **PR Links**: Extract GitHub PR URLs from the attachments field
6. **External Links**: Capture all documentation and design URLs from descriptions
7. **Technical Deep Dive**: Don't just list features, understand implementation impact
8. **Risk-First Analysis**: Lead with what could go wrong, not just what's planned

## Usage Instructions
1. Start by asking for:
   - The release task ID (e.g., "IOS-5467")
2. **FETCH RELEASE TASK:**
   - Use `mcp__linear-server__get_issue` with the release task ID
   - Extract the UUID (`id` field) for parentId queries
3. **FETCH LEVEL-1 SUBTASKS:**
   - Use `mcp__linear-server__list_issues` with `parentId` = release task UUID
   - Include archived issues (`includeArchived: true`)
   - Identify epics (title contains `[epic]`)
4. **FETCH LEVEL-2 SUBTASKS (for each epic):**
   - Use `mcp__linear-server__list_issues` with `parentId` = epic UUID
   - Capture all implementation tasks
5. **BUILD HIERARCHY:**
   - Organize tasks into the tree structure
   - Count tasks by status
   - Extract PR links from attachments
6. **MANDATORY:** Save as: `linear_context_release_[NUMBER].md` - do not skip this step

## URL Formats to Capture
- Linear Issues: `https://linear.app/[workspace]/issue/[ID]`
- Linear Projects: `https://linear.app/[workspace]/project/[ID]`
- Linear Views: `https://linear.app/[workspace]/view/[ID]`
- GitHub PRs: `https://github.com/[org]/[repo]/pull/[number]`
- GitHub Issues: `https://github.com/[org]/[repo]/issues/[number]`
- Figma: `https://www.figma.com/file/[ID]/[name]`
- Documentation: Various formats

## Validation Checklist
Before finalizing analysis:
- [ ] **Release task fetched with full details**
- [ ] **All level-1 subtasks fetched** (standalone tasks + umbrella groups)
- [ ] **All level-2 subtasks fetched** (for each umbrella group)
- [ ] **RECURSIVE CHECK: Non-epic umbrella tasks checked for children** (e.g., "leftovers", "multi-chat", "polish")
- [ ] **Every task has identifier (IOS-XXXX) and Linear URL**
- [ ] **PR links extracted from attachments field**
- [ ] **External links captured** (Figma, docs from descriptions)
- [ ] **Status breakdown calculated** (Done, In Progress, etc.)
- [ ] Technical dependencies mapped
- [ ] Risk assessment completed
- [ ] Testing recommendations provided
- [ ] Complete hierarchy visualization included
- [ ] **File artifact created as linear_context_release_[NUMBER].md**

