USE EXTENDED THINKING

# Linear Context Gathering for iOS Release (View-Based Approach)

## Purpose
This document guides the process of gathering comprehensive context from Linear for iOS release impact analysis and changelog generation, using a pre-configured Linear view to simplify project discovery.

## Process

### Step 1: Get Release Information
Ask the user:
- "What is the release task id"
- "What is the Linear view URL/name for the release projects?"
- Example responses: 
  - Release ID: "IOS-4626"
  - View: "Release 12 iOS Projects" or direct view URL

### Step 2: Get Projects from Linear View (SYSTEMATIC APPROACH)
1. **Look at the Linear view screenshot/URL provided**
2. **List every single project name visible in the view systematically**
3. **Use `mcp__linear__get_project` for each project name to get full details**
4. **Capture project descriptions, status, priority, and completion % for each**
5. **Capture the Linear URL for each project/epic in the view**
6. **Count total projects to validate completeness** - ensure no projects are missed

### Step 3: Detailed Information Gathering with Links
For EACH project/epic from the view:

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

#### E. Sub-task Analysis with Full Hierarchy
For each project/epic, find and analyze ALL sub-tasks:
- Use parentId search to find direct children
- **Capture full parent-child URL relationships**
- Look for related implementation tasks
- **Create a URL hierarchy map**

### Step 4: Cross-Platform Context with Links
- Find related Desktop/Web releases (with Linear URLs)
- Identify shared middleware dependencies (with issue links)
- Note platform-specific variations
- **Link to cross-platform coordination issues**

### Step 5: Extract Linear Issue IDs for Changelog
**CRITICAL**: For changelog generation, we need Linear ISSUE IDs (IOS-XXXX format), not project hash IDs.

### ID Format Distinction
1. **Project IDs** (hash format like `9f4625be498e`):
   - Used internally by Linear for project URLs
   - Good for reference and URLs
   - **DO NOT use these in changelogs**

2. **Issue IDs** (format like `IOS-4913`, `IOS-5149`):
   - Human-readable task/story identifiers
   - Found in git commit messages
   - Found in sub-tasks of projects
   - **USE THESE in changelogs and impact reports**

### How to Extract Issue IDs
For each project in the view:
1. **Check sub-tasks** - Each sub-task has an issue ID (IOS-XXXX)
2. **Look at project description** - Often lists related issue IDs
3. **Review linked PRs** - GitHub PRs reference issue IDs
4. **Note implementation issues** - Main work is done in issue tasks, not project containers

### Issue ID Mapping Example
```
Project: "Chat (Public Release)" (9f4625be498e)
└── Associated Issue IDs:
    ├── IOS-4913: Chat system implementation
    ├── IOS-4915: Sharing extension with chat support
    ├── IOS-5033: Chat space creation
    └── IOS-5200: Remove chat editor limits
```

**For changelog**: Use "Chat Spaces (IOS-4913)" NOT "Chat Spaces (9f4625be498e)"

## Step 6: Create Comprehensive Context Summary with Full References
**CRITICAL: Always save the analysis as a file immediately after completion**

## Output Format

```markdown
# Linear Context for iOS Release [NUMBER]

## Release Overview
- **Release**: [Name] ([ID])
- **Linear URL**: [Full URL to release issue]
- **View Used**: [View Name/URL]
- **Version**: [X.Y.Z]
- **Status**: [Status]
- **Timeline**: [Start] - [End]
- **Description**: [Release description]

## Project Summary from View
**Total Projects**: [Count from view]
**Status Breakdown**:
- Done: [Count]  
- In Progress: [Count]
- Waiting for Testing: [Count]
- Code Review: [Count]
- Backlog: [Count]

## Projects & Links

### Project Hierarchy
```
Release [NUMBER] - [URL]
├── Project: [Name] ([ID]) - [URL]
│   ├── Task: [Name] ([ID]) - [URL]
│   └── Task: [Name] ([ID]) - [URL]
├── Project: [Name] ([ID]) - [URL]
│   └── Task: [Name] ([ID]) - [URL]
└── Project: [Name] ([ID]) - [URL]
    └── Task: [Name] ([ID]) - [URL]
```

## Major Feature Categories

### [Category 1: e.g., Chat & Communication]
1. **[Project/Epic Name]** (Project ID: [project-hash-id])
   - **Linear URL**: [Full URL]
   - **Status**: [Status]
   - **Priority**: [Priority]
   - **Description**: [Brief description]
   - **Implementation Issue IDs**: [IOS-XXXX, IOS-YYYY] (for changelog use)
   - **Key Features**:
     - [Feature 1] (IOS-XXXX) - [Status] - [URL]
     - [Feature 2] (IOS-YYYY) - [Status] - [URL]
   - **Related Links**:
     - PR: [GitHub PR URL] (mentions IOS-XXXX)
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
1. **View Validation**: Ensure all projects from the Linear view are captured
2. **URL Capture**: Record full Linear URLs for every issue, project, and relationship
3. **Relationship Mapping**: Document all parent-child and related issue connections
4. **External Links**: Capture all GitHub, documentation, and design URLs
5. **Sub-task Discovery**: For each project, find all child tasks
6. **Technical Deep Dive**: Don't just list features, understand implementation impact
7. **Risk-First Analysis**: Lead with what could go wrong, not just what's planned

## Usage Instructions
1. Start by asking for:
   - The release ID
   - The Linear view URL or name containing all release projects
2. **SYSTEMATIC PROJECT EXTRACTION:**
   - Look at the Linear view screenshot/URL provided
   - List every single project name visible in the view
   - Use `mcp__linear__get_project` for each project name
   - Get full project descriptions, status, priority, completion %
3. For each project in the view:
   - Gather comprehensive details from project description
   - Find all sub-tasks using parentId search
   - Capture all URLs and relationships
   - Document technical dependencies
4. Create hierarchy maps showing relationships
5. Include all external references (GitHub, Figma, docs)
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
- [ ] **Project count matches Linear view display exactly**
- [ ] **All projects from view analyzed using mcp__linear__get_project**
- [ ] **Every project has description, status, priority, completion %**
- [ ] **Every issue has a Linear URL**
- [ ] **All parent-child relationships have URLs**
- [ ] **External links captured (GitHub, Figma, docs)**
- [ ] Technical dependencies mapped
- [ ] Risk assessment completed
- [ ] Testing recommendations provided
- [ ] Cross-platform impacts noted with links
- [ ] Complete hierarchy visualization included
- [ ] **File artifact created as linear_context_release_[NUMBER].md**

