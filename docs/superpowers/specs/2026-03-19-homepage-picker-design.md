# Homepage Picker Screen — Technical Spec

**Linear issue:** IOS-5903
**Parent:** IOS-5856 (Create Channel Flow)
**Date:** 2026-03-19

## Summary

Bottom sheet for selecting channel homepage. Four options: Chat, Widgets, Page, Collection. Used in channel creation flow, "Create Home" widget, and potentially Space Settings. Creates the selected object, sets it as homepage, and returns the result to the coordinator for navigation.

## Design References

- Picker: `figma.com/design/AIsUjTc2FGKlCcNgIlIuue/-M--Navigation---Vault?node-id=12066-13143`
- Light theme thumbnails: `node-id=12084-12221`
- Dark theme thumbnails: `node-id=12084-12393`

## Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Build new vs adapt existing | New module alongside existing `HomePagePickerView` | Completely different UI (4 fixed cards vs search list). Old one stays behind `FeatureFlags.homePage` for Settings use |
| Naming | `Homepage` (not `HomePage`) | New module, distinct from existing `HomePagePicker*`. Consistent internally |
| Presentation | System `.sheet()` with `fitPresentationDetents` | iOS 17 target supports all needed APIs. Native feel, accessibility |
| Thumbnails | SwiftUI-drawn shapes | Simple geometric shapes. Auto theme adaptation. No asset management |
| Avatar in Chat thumbnail | Gray circle placeholder | Simple, clean. Easy to replace later |
| Module output | Minimal enum: `homepageSet(homepageId:)` or `later` | Internal details (option type, object creation) stay encapsulated |
| Service stub | Only `SetHomepage` is stubbed. Object creation uses existing services | Middleware dependency (#2) not ready yet |

## Architecture

### File Structure

```
Anytype/Sources/PresentationLayer/Modules/HomepagePicker/
├── HomepagePickerView.swift              # SwiftUI view
├── HomepagePickerViewModel.swift         # @Observable ViewModel
├── HomepagePickerOption.swift            # Internal enum + result types
├── HomepagePickerThumbnail.swift         # SwiftUI-drawn thumbnail cards
├── HomepagePickerService.swift           # Protocol + implementation
└── HomepagePickerModuleResult.swift      # Public output enum
```

### Module Boundary

**Public (exposed to coordinator):**

```swift
// The only type coordinator sees
enum HomepagePickerResult {
    case homepageSet(homepageId: String)  // objectId or "widgets"
    case later
}

// View initializer
HomepagePickerView(spaceId: String, onFinish: @escaping (HomepagePickerResult) async throws -> Void)
```

**Internal (encapsulated):**

```swift
// Not exported — internal to module
enum HomepagePickerOption: String, CaseIterable, Identifiable {
    case chat
    case widgets
    case page
    case collection

    var id: String { rawValue }
    var title: String { ... }  // Localized via Loc
}
```

### Data Flow

```
User selects option + taps "Create"
  → ViewModel.onCreate()
    → HomepagePickerService.createHomepage(spaceId, option)
      → For Chat/Page/Collection:
          1. Create object via existing ObjectActionsService
          2. Call SetHomepage(spaceId, objectId) — STUB
          3. Return objectId
      → For Widgets:
          1. Call SetHomepage(spaceId, "widgets") — STUB
          2. Return "widgets"
    → onFinish(.homepageSet(homepageId: result))
    → dismiss = true

User taps "Later"
  → ViewModel.onLater()
    → onFinish(.later)
    → dismiss = true
```

### Service Layer

```swift
protocol HomepagePickerServiceProtocol: Sendable {
    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> String
}
```

`HomepagePickerService` implementation:
- Injects existing object creation service for Chat/Page/Collection
- Contains stub for `SetHomepage` (logs + returns) — to be replaced when middleware #2 is ready
- Returns `homepageId` (objectId for Chat/Page/Collection, `"widgets"` for Widgets)

Registered in DI container via `@Injected`.

### Dismiss Pattern

Following codebase convention:
1. ViewModel sets `dismiss = true`
2. View's `onChange(of: model.dismiss)` calls `@Environment(\.dismiss)`
3. Coordinator receives result via `onFinish` closure **before** dismiss

### Coordinator Integration

```swift
// In coordinator view
.sheet(item: $model.homepagePickerData) { data in
    HomepagePickerView(spaceId: data.spaceId) { result in
        switch result {
        case .homepageSet(let homepageId):
            // Navigate to homepage object or widgets
        case .later:
            // Handle temp widgets (separate task)
        }
    }
    .interactiveDismissDisabled(true)
}
```

## UI Specification

### Sheet Presentation

- System `.sheet()` with `.fitPresentationDetents()` (auto-size to content)
- `.presentationDragIndicator(.hidden)` — no drag indicator per design
- `.interactiveDismissDisabled(true)` — only "Create" or "Later" dismiss
- Note: `fitPresentationDetents()` already applies `.presentationCornerRadius(16)` internally
- Background: `Color.Background.secondary`

### Layout

```
VStack(spacing: 0)
├── Spacer.fixedHeight(31)
├── Title: "Create Home"
│   Font: .heading (Inter Bold 22, leading 26, tracking -0.36)
│   Color: Color.Text.primary
│   Alignment: center
├── Spacer.fixedHeight(8)
├── Description text
│   Font: .uxTitle2Regular (Inter Regular 15, leading 20, tracking -0.24)
│   Color: Color.Text.primary
│   Alignment: center
│   Padding: horizontal 37 (to match ~321pt width)
├── Spacer.fixedHeight(24)
├── ScrollView(.horizontal, showsIndicators: false)
│   └── HStack(spacing: 24)
│       └── ForEach(options) → ThumbnailCard
│       Padding: horizontal 24
├── Spacer.fixedHeight(24)
├── AsyncStandardButton("Create", style: .primaryLarge)
│   Padding: horizontal 16
│   Shows loading dots during async, error toast on failure
├── Spacer.fixedHeight(8)
├── StandardButton("Later", style: .secondaryLarge)
│   Padding: horizontal 16
│   Synchronous — just calls onFinish(.later) + dismiss
└── Spacer.fixedHeight(16)
```

### Thumbnail Cards

Each card: 88pt wide x 176pt tall + 18pt label below (total ~201pt height with spacing)

**Structure:**
```
VStack(spacing: 7)
├── RoundedRectangle card (88 x 176, cornerRadius: 14)
│   ├── Border: 1.5pt selected / 1pt unselected
│   ├── Content: SwiftUI-drawn shapes specific to each option
│   └── ClipShape: RoundedRectangle(cornerRadius: 14)
└── Label text
    Font: .caption1Medium (Inter Medium 13, leading 18, tracking -0.08)
```

**Selected state:**
- Border: 1.5pt, `Color.Control.accent50`
- Shapes inside: `Color.Control.accent50` (lines/dots), `Color.Control.accent25` (card backgrounds)
- Label: `Color.Control.accent100`

**Unselected state:**
- Border: 1pt, `Color.Shape.tertiary`
- Shapes inside: `Color.Shape.tertiary` (lines/dots), `Color.Shape.transparentTertiary` (card backgrounds)
- Label: `Color.Control.secondary`

**Default selection:** first option (Chat) is pre-selected.

### Thumbnail Content (SwiftUI shapes)

**Chat:** Message bubbles (rounded rects) — left-aligned with gray fill, right-aligned with tinted fill. Two circle placeholders for avatars (left side).

**Widgets:** Two card sections (rounded rect backgrounds) with bullet-point rows (small circles + horizontal lines).

**Page:** Document emoji icon placeholder + "Idea" text (small rounded rect) + horizontal text lines.

**Collection:** Header with "Tasks" text + toggle circle + list rows with horizontal lines.

All shapes use `Color.Shape.tertiary` / `Color.Shape.transparentTertiary` when unselected, and `Color.Control.accent50` / `accent25` when selected. Light/dark theme adaptation is automatic via design system colors.

### Error Handling

- `AsyncStandardButton` handles errors automatically: shows loading dots during async call, displays error toast on failure
- On error, sheet stays open — user can retry or tap "Later"
- No custom error handling needed beyond what `AsyncStandardButton` provides

## Dependencies

- **Existing services:** Object creation (Chat, Page, Collection objects)
- **Stub:** `SetHomepage(spaceId, homepageId)` — wired when middleware #2 is ready
- **Design system:** `StandardButton`, `AsyncStandardButton`, `AnytypeText`, `Color.*`, `Spacer.fixedHeight`
- **DI:** `@Injected` pattern for service injection

## Out of Scope

- Wiring real `Rpc.Workspace.SetHomepage` middleware (dependency #2)
- Replacing existing `HomePagePickerView` (separate cleanup)
- Temporary "Create Home" widget logic (separate task)
- Analytics events
- Coordinator-level navigation after result

## Acceptance Criteria

- [ ] Bottom sheet shows 4 options with SwiftUI-drawn thumbnails
- [ ] Horizontal scroll works for thumbnail list
- [ ] Selected state shows blue border + accent colors + blue label
- [ ] Light and dark theme support
- [ ] Chat/Page/Collection creates object then sets homepage (SetHomepage stubbed)
- [ ] Widgets sets homepage to "widgets" (stubbed)
- [ ] "Later" dismisses without action, returns `.later` result
- [ ] "Create" button triggers service, returns `.homepageSet(homepageId:)` result
- [ ] Screen is reusable — no coupling to specific coordinator
- [ ] Interactive dismiss disabled (only buttons dismiss)
