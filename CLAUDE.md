# Anytype iOS App

Privacy-focused, local-first workspace for iOS. Swift + SwiftUI + Custom Middleware (Protobuf).

## ⚠️ CRITICAL RULES - NEVER VIOLATE
1. **NEVER commit/stage without explicit user request**
2. **NEVER add AI signatures in code**
3. **NEVER run destructive git operations** without explicit approval
4. **Always present action plan** before implementing multi-step changes

## 🚀 Quick Start
```bash
make setup-env && make setup-tools && make setup-middle  # First time
make generate                                             # After any asset/flag/localization change
```
**Requirements**: Xcode 16.1+, Swift Package Manager
**Compilation**: Report changes to user — they verify in Xcode (faster with caches).

## 📚 Knowledge Map

This file is a **table of contents**, not an encyclopedia. Deeper docs live in-repo.

### Architecture & Patterns
| Topic | Location |
|-------|----------|
| MVVM, Coordinator, DI, code style | `Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md` |
| Taste invariants (mechanical rules) | `TASTE_INVARIANTS.md` |

### Design System
| Topic | Location |
|-------|----------|
| Colors, typography, icons, spacing | `Anytype/Sources/PresentationLayer/Common/DESIGN_SYSTEM_MAPPING.md` |
| Typography reference | `Anytype/Sources/PresentationLayer/Common/TYPOGRAPHY_MAPPING.md` |

### Localization
| Topic | Location |
|-------|----------|
| Full guide | `Anytype/Sources/PresentationLayer/Common/LOCALIZATION_GUIDE.md` |
| Quick search | `rg "term" Modules/Loc/Sources/Loc/Generated/Strings.swift` |

### Code Generation
| Topic | Location |
|-------|----------|
| Feature flags, SwiftGen, Sourcery | `Modules/AnytypeCore/CODE_GENERATION_GUIDE.md` |
| Feature flags source | `Modules/AnytypeCore/.../FeatureDescription+Flags.swift` |

### Code Review & Quality
| Topic | Location |
|-------|----------|
| Review guidelines | `.claude/CODE_REVIEW_GUIDE.md` |
| Self-review checklist | `.claude/skills/self-review/SKILL.md` |
| CI workflows | `.github/WORKFLOWS_REFERENCE.md` |

### Skills (Auto-Activate)
Skills in `.claude/skills/` auto-activate based on prompt keywords.
See `.claude/skills/README.md` for full list and tuning guide.

| Skill | Triggers On |
|-------|-------------|
| `ios-dev-guidelines` | `.swift` files, architecture |
| `localization-developer` | Localization work |
| `design-system-developer` | UI/design work |
| `code-generation-developer` | Code generation |
| `code-review-developer` | PR reviews |
| `self-review` | Post-implementation quality check |
| `confidence-check` | Implementation tasks |
| `linear-developer` | Linear issues/CLI |
| `ios-simulator-skill` | Simulator/build/test |
| `swift-concurrency-developer` | Concurrency/actors |
| `swiftui-patterns-developer` | View structure |
| `swiftui-performance-developer` | Performance issues |
| `liquid-glass-developer` | iOS 26 glass effects |
| `analytics-developer` | Analytics events |
| `feature-toggle-developer` | Feature flags |
| `tests-developer` | Unit tests, mocks |

## 🔒 Pre-Implementation Gate
When `confidence-check` activates, run 5-check assessment before writing code:
```
[ ] No duplicates found (25%)    [ ] Follows MVVM/Coordinator/DI (25%)
[ ] Verified existing code (20%) [ ] Uses Loc/Color/Image system (15%)
[ ] Root cause understood (15%)  → PROCEED ≥90% | PAUSE 70-89% | STOP <70%
```

## 🏗️ Project Structure
```
Anytype/Sources/
├── ApplicationLayer/    # App lifecycle, coordinators
├── PresentationLayer/   # UI components, ViewModels
├── ServiceLayer/        # Business logic, data services
└── Models/              # Data models, entities
Modules/                 # Swift packages (AnytypeCore, Loc, Assets, Services)
```

## 🔄 Git Workflow
- **Main branch**: `develop` | **Feature branches**: `ios-XXXX-description`
- **Task start**: `linctl issue get IOS-XXXX --json` → extract `gitBranchName` → checkout
- **Commits**: Single line, direct, technical
- **PRs**: `## Summary` + 1-3 bullets. Trivial PRs get "🧠 No brainer" label.
- **GitHub**: `gh pr view <N> --repo anyproto/anytype-swift`

## ⚠️ Common Mistakes
- **Autonomous Committing**: NEVER commit unless user explicitly asks
- **Wildcard Deletion**: Always `ls` first, delete individually
- **Incomplete Mock Updates**: `rg "oldName" --type swift` → update ALL references
- **Over-Engineering**: Three similar lines > premature abstraction
- **Guessing Before Reading**: Always read the file before suggesting changes

## 💡 Quick Reference
- `Loc` is pre-imported; import `AnytypeCore` for feature flags
- Icons: `Image(asset: .X32.qrCode)`, `Image(asset: .X24.search)`
- Colors: `Color.Text.primary`, `Color.Shape.transparentSecondary`
- When stuck after 2-3 attempts, step back and try a different approach
