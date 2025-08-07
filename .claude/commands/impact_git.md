USE EXTENDED THINKING

# Git Changes Gathering for iOS Release

## Purpose
This document guides the process of gathering all code changes between branches/commits for iOS release analysis.

## Process

### Step 1: Identify Comparison Points
Ask the user:
- "Which two commits or branches would you like to compare?"
- If no response, use defaults:
  - Base: `origin/main` (latest)
  - Target: `origin/develop` (latest)

Get exact commit hashes:
```bash
git rev-parse origin/main    # For main branch
git rev-parse origin/develop # For develop branch
```

### Step 2: Gather Basic Statistics

#### A. File Change Summary
```bash
# Get file statistics
git diff --stat [BASE]..[TARGET]

# Count total files changed
git diff --name-only [BASE]..[TARGET] | wc -l

# List all changed files
git diff --name-only [BASE]..[TARGET] > changed_files.txt
```

#### B. Categorize Files by Type
```bash
# UI/View files
git diff --name-only [BASE]..[TARGET] | grep -E '\.(storyboard|xib|swift)' | grep -E '(View|ViewController|Cell|UI)'

# Model/Data files  
git diff --name-only [BASE]..[TARGET] | grep -E '(Model|Entity|Core.*Data|Realm)'

# Networking files
git diff --name-only [BASE]..[TARGET] | grep -E '(API|Service|Network|Request|Response)'

# Configuration files
git diff --name-only [BASE]..[TARGET] | grep -E '(Config|Constants|Environment|\.plist|\.json)'

# Test files
git diff --name-only [BASE]..[TARGET] | grep -E '(Test|Spec|Mock)'
```

### Step 3: Extract Detailed Changes

#### A. Commit History
```bash
# Get all commits with messages
git log --oneline [BASE]..[TARGET] > commits.txt

# Get detailed commit messages
git log --format="==== %h ====\n%an - %ad\n%s\n%b\n" [BASE]..[TARGET] > detailed_commits.txt

# Find merge commits
git log --merges --oneline [BASE]..[TARGET]
```

#### B. Code Diff Analysis
```bash
# Full diff (be careful with large diffs)
git diff [BASE]..[TARGET] > full_diff.patch

# Diff for specific file types
git diff [BASE]..[TARGET] -- "*.swift" > swift_changes.diff
git diff [BASE]..[TARGET] -- "*.storyboard" > ui_changes.diff
```

### Step 4: Analyze Specific Change Types

#### A. Project Configuration
```bash
# Check for dependency changes
git diff [BASE]..[TARGET] -- "*.xcodeproj" "*.xcworkspace" "**/Package.swift" "**/Podfile"

# Info.plist changes (permissions, capabilities)
git diff [BASE]..[TARGET] -- "**/Info.plist"

# Build configuration changes
git diff [BASE]..[TARGET] -- "*.xcconfig"
```

#### B. API/Network Changes
```bash
# Find endpoint changes
git diff [BASE]..[TARGET] | grep -E "(endpoint|url|baseURL|API)" -A 3 -B 3

# Find new network calls
git diff [BASE]..[TARGET] | grep -E "(URLSession|Alamofire|fetch|request)" -A 3 -B 3
```

#### C. UI/UX Changes
```bash
# Animation changes
git diff [BASE]..[TARGET] | grep -E "(animate|transition|duration)" -A 2 -B 2

# Color/Theme changes
git diff [BASE]..[TARGET] | grep -E "(Color|Theme|Appearance|tint)" -A 2 -B 2

# Accessibility changes
git diff [BASE]..[TARGET] | grep -E "(accessibility|VoiceOver|Dynamic Type)" -A 2 -B 2
```

### Step 5: Extract Key Information

#### A. New Features (from commit messages)
```bash
# Look for feature commits
git log --grep="feat\|feature\|add\|implement" --oneline [BASE]..[TARGET]
```

#### B. Bug Fixes
```bash
# Look for fix commits
git log --grep="fix\|bug\|issue\|resolve" --oneline [BASE]..[TARGET]
```

#### C. Breaking Changes
```bash
# Look for breaking changes
git log --grep="BREAKING\|breaking\|deprecated" --oneline [BASE]..[TARGET]
```

## Output Format

```markdown
# Git Changes Summary for Release [NUMBER]

## Comparison Details
- **Base Branch/Commit**: [BASE] ([HASH])
- **Target Branch/Commit**: [TARGET] ([HASH])
- **Total Commits**: [COUNT]
- **Total Files Changed**: [COUNT]
- **Lines Added**: [COUNT]
- **Lines Deleted**: [COUNT]

## File Changes by Category

### UI/View Layer ([COUNT] files)
- `Path/To/File1.swift` - [Brief change description]
- `Path/To/File2.storyboard` - [Brief change description]

### Business Logic ([COUNT] files)
- `Path/To/Model.swift` - [Brief change description]
- `Path/To/Service.swift` - [Brief change description]

### Networking Layer ([COUNT] files)
- `Path/To/APIClient.swift` - [Brief change description]
- `Path/To/Endpoint.swift` - [Brief change description]

### Configuration ([COUNT] files)
- `Info.plist` - [Changes: permissions, version, etc.]
- `Config.swift` - [Brief change description]

### Tests ([COUNT] files)
- `Path/To/Test.swift` - [Brief change description]

## Commit Analysis

### Feature Commits ([COUNT])
1. `[HASH]` - [Commit message]
   - Files affected: [List]
   - Key changes: [Summary]

2. `[HASH]` - [Commit message]
   [Continue pattern...]

### Bug Fix Commits ([COUNT])
1. `[HASH]` - [Commit message]
   - Issue fixed: [Description]
   - Files affected: [List]

### Infrastructure/Config Commits ([COUNT])
1. `[HASH]` - [Commit message]
   - Changes: [Description]

## Key Code Changes

### New/Modified Endpoints
- `GET /api/v2/users` - New endpoint for user data
- `POST /api/v2/auth` - Modified authentication flow

### Permission Changes
- Added: Camera permission for profile photos
- Modified: Location permission description

### UI/UX Updates
- New animations in: [Screen names]
- Theme changes: [Description]
- Accessibility improvements: [List]

### Dependencies
- Added: [Library name] v[version]
- Updated: [Library name] from v[old] to v[new]
- Removed: [Library name]

## Potential Risk Areas
Based on code analysis:
1. [Risk area 1] - [Reason]
2. [Risk area 2] - [Reason]
3. [Risk area 3] - [Reason]

## Merge Commits
- [List of merge commits indicating feature branches merged]
```

## Usage Instructions
1. Get branch/commit information from user
2. Run git commands to gather all data
3. Organize changes by category
4. Analyze commit messages for context
5. Create comprehensive change summary
6. Save as: `git_changes_release_[NUMBER].md`