USE EXTENDED THINKING

# Linear Context Gathering for iOS Release (Enhanced for Changelog)

## Purpose
This document guides the process of gathering comprehensive context from Linear for iOS release impact analysis and changelog generation, with emphasis on capturing all links and relationships.

## Process

### Step 1: Get Release Information
Ask the user:
- "What is the release task id"
- Example responses: "IOS-4626",

### Step 2: Use Linear MCP for Release Initiative
1. Search in Linear for the release project
2. Get the main release issue details including:
   - Full Linear URL for the release
   - Project name and URL
   - Release version number

### Step 3: Comprehensive Epic Discovery
**CRITICAL**: Use ALL of these search approaches to ensure complete coverage:

#### A. Direct Parent-Child Relationships
1. List all issues with parentId of the main release task
2. List all issues with parentId of any discovered epics (recursive search)
3. **Capture the Linear URL for each epic and issue**

#### B. Project-Based Search
1. Get all issues in the Release project filtered by iOS team
2. Search for issues with "Release 12" AND "iOS" in title
3. Search for issues with "[epic]" AND "Release 12" AND "iOS" in title or description
4. **Record project URLs and relationships**

#### C. Pattern-Based Search
1. Search for all issues containing "Release 12 | iOS" in title
2. Search for all issues containing "[epic] Release 12" in title
3. Search for all issues with labels or tags related to the release

#### D. Team-Based Comprehensive Search
1. List ALL iOS team issues in the Release project (not just direct children)
2. Filter by date range around release creation date
3. Look for issues with release version numbers (e.g., "0.39.0")

### Step 4: Detailed Information Gathering with Links
For EACH discovered epic/issue:

#### A. Basic Information with URLs
- Issue ID and Title
- **Full Linear URL** (e.g., https://linear.app/company/issue/IOS-1234)
- **Parent Project URL** and name
- **Parent Epic URL** (if applicable)
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
- **Related epics/stories URLs** (even if not direct parent-child)

#### D. Risk Assessment with References
- Implementation complexity
- Dependencies on other teams/systems (with Linear issue links)
- Migration requirements (with documentation links)
- Backward compatibility concerns
- Testing coverage needs (with test plan links if available)

#### E. Sub-task Analysis with Full Hierarchy
For each epic, recursively find and analyze ALL sub-tasks:
- Use parentId search to find direct children
- **Capture full parent-child URL relationships**
- Search for issues mentioning the epic ID in title/description
- Look for related implementation tasks
- **Create a URL hierarchy map**

### Step 5: Cross-Platform Context with Links
- Find related Desktop/Web releases (with Linear URLs)
- Identify shared middleware dependencies (with issue links)
- Note platform-specific variations
- **Link to cross-platform coordination issues**

### Step 6: Create Comprehensive Context Summary with Full References

## Output Format

```markdown
# Linear Context for iOS Release [NUMBER]

## Release Overview
- **Release**: [Name] ([ID])
- **Linear URL**: [Full URL to release issue]
- **Project**: [Project Name] ([Project URL])
- **Version**: [X.Y.Z]
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

## Project Structure & Links

### Release Hierarchy
```
Release [NUMBER] - [URL]
├── Project: [Name] - [URL]
├── Epic: [Name] ([ID]) - [URL]
│   ├── Story: [Name] ([ID]) - [URL]
│   └── Story: [Name] ([ID]) - [URL]
└── Epic: [Name] ([ID]) - [URL]
    └── Story: [Name] ([ID]) - [URL]
```

## Major Feature Categories

### [Category 1: e.g., Chat & Communication]
1. **[Epic Name]** ([Epic ID])
   - **Linear URL**: [Full URL]
   - **Project**: [Project Name] ([Project URL])
   - **Status**: [Status]
   - **Priority**: [Priority]  
   - **Description**: [Brief description]
   - **Key Features**:
     - [Feature 1] ([Sub-task ID]) - [Status] - [URL]
     - [Feature 2] ([Sub-task ID]) - [Status] - [URL]
   - **Related Links**:
     - PR: [GitHub PR URL]
     - Design: [Figma URL]
     - Docs: [Documentation URL]
   - **Technical Notes**: [Implementation details]
   - **Risk Level**: [High/Medium/Low]
   - **Testing Focus**: [Specific areas]
   - **Related Issues**: 
     - Blocks: [Issue ID] - [URL]
     - Related to: [Issue ID] - [URL]

### [Category 2: e.g., Notifications]
[Continue pattern for all categories...]

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
- **Epic Completion**: [X/Y] ([Z%])
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

## Complete Issue List with URLs
### Done
- [ID]: [Title] - [URL] - Epic: [Epic ID]
- [ID]: [Title] - [URL] - Epic: [Epic ID]

### In Progress
- [ID]: [Title] - [URL] - Epic: [Epic ID]
- [ID]: [Title] - [URL] - Epic: [Epic ID]

### Pending
- [ID]: [Title] - [URL] - Epic: [Epic ID]
- [ID]: [Title] - [URL] - Epic: [Epic ID]

## Recommendations
1. **[Recommendation 1]** - Related: [URL]
2. **[Recommendation 2]** - Related: [URL]
3. **[Recommendation 3]** - Related: [URL]
```

## Critical Success Factors
1. **Comprehensive Search**: Must use ALL search approaches to avoid missing epics
2. **URL Capture**: Record full Linear URLs for every issue, project, and relationship
3. **Relationship Mapping**: Document all parent-child and related issue connections
4. **External Links**: Capture all GitHub, documentation, and design URLs
5. **Recursive Discovery**: Follow parent-child relationships completely
6. **Cross-Reference Validation**: Verify epic counts against Linear UI
7. **Technical Deep Dive**: Don't just list features, understand implementation impact
8. **Risk-First Analysis**: Lead with what could go wrong, not just what's planned

## Usage Instructions
1. Start by asking for the release ID
2. **Execute ALL search approaches** - don't skip any
3. **Capture full URLs for everything** - issues, projects, PRs, docs
4. Create hierarchy maps showing relationships
5. Cross-reference results with Linear UI to verify completeness
6. Include all external references (GitHub, Figma, docs)
7. Save as: `linear_context_release_[NUMBER].md`

## URL Formats to Capture
- Linear Issues: `https://linear.app/[workspace]/issue/[ID]`
- Linear Projects: `https://linear.app/[workspace]/project/[ID]`
- GitHub PRs: `https://github.com/[org]/[repo]/pull/[number]`
- GitHub Issues: `https://github.com/[org]/[repo]/issues/[number]`
- Figma: `https://www.figma.com/file/[ID]/[name]`
- Documentation: Various formats

## Validation Checklist
Before finalizing analysis:
- [ ] Epic count matches Linear UI display
- [ ] All major feature categories identified
- [ ] **Every issue has a Linear URL**
- [ ] **All parent-child relationships have URLs**
- [ ] **External links captured (GitHub, Figma, docs)**
- [ ] **Project URLs included**
- [ ] Technical dependencies mapped
- [ ] Risk assessment completed
- [ ] Testing recommendations provided
- [ ] Cross-platform impacts noted with links
- [ ] Complete hierarchy visualization included