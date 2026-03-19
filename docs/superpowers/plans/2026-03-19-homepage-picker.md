# Homepage Picker Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a bottom sheet picker with 4 homepage options (Chat, Widgets, Page, Collection), SwiftUI-drawn thumbnails, object creation, and coordinator output.

**Architecture:** New module at `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/` following MVVM pattern. Service layer creates objects and stubs SetHomepage. View uses system `.sheet()` with `fitPresentationDetents`. Module exposes only `HomepagePickerResult` enum and `HomepagePickerView` initializer.

**Tech Stack:** SwiftUI, @Observable, Factory DI, AsyncStandardButton, AnytypeText

**Spec:** `docs/superpowers/specs/2026-03-19-homepage-picker-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerOption.swift` | Create | Internal enum (chat/widgets/page/collection) + localized titles |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerResult.swift` | Create | Public output enum (`homepageSet`/`later`) |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerServiceProtocol.swift` | Create | Service protocol |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerService.swift` | Create | Service impl: object creation + SetHomepage stub |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerViewModel.swift` | Create | @Observable ViewModel: selection state, button actions |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerView.swift` | Create | Main SwiftUI view: layout, scroll, buttons |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/HomepagePickerThumbnailCard.swift` | Create | Thumbnail card wrapper (border, selection, label) |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/ChatThumbnail.swift` | Create | Chat option drawing |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/WidgetsThumbnail.swift` | Create | Widgets option drawing |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/PageThumbnail.swift` | Create | Page option drawing |
| `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/CollectionThumbnail.swift` | Create | Collection option drawing |
| `Anytype/Sources/ServiceLayer/ServicesDI.swift` | Modify | Register `homepagePickerService` |
| `Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings` | Modify | Add 3 new strings |
| `Modules/Loc/Sources/Loc/Generated/Strings.swift` | Auto-generated | After `make generate` |
| `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/Coordinator/SpaceCreateCoordinatorView.swift` | Modify | Wire picker sheet |
| `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/Coordinator/SpaceCreateCoordinatorViewModel.swift` | Modify | Handle picker result |

---

## Task 1: Localization Strings

**Files:**
- Modify: `Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings`

Existing strings we'll reuse: `Loc.create`, `Loc.chat`, `Loc.page`, `Loc.collection`, `Loc.SpaceSettings.HomePage.widgets`.

New strings needed:

- [ ] **Step 1: Add localization keys to Workspace.xcstrings**

Open `Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings` and add these 3 entries to the `"strings"` object (alphabetical order):

```json
"HomepagePicker.title" : {
  "extractionState" : "manual",
  "localizations" : {
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Create Home"
      }
    }
  }
},
"HomepagePicker.description" : {
  "extractionState" : "manual",
  "localizations" : {
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Select what you and channel members see when they open the channel. You can always change it in settings."
      }
    }
  }
},
"Later" : {
  "extractionState" : "manual",
  "localizations" : {
    "en" : {
      "stringUnit" : {
        "state" : "translated",
        "value" : "Later"
      }
    }
  }
}
```

- [ ] **Step 2: Run code generation**

Run: `make generate`

This generates `Modules/Loc/Sources/Loc/Generated/Strings.swift` with:
- `Loc.HomepagePicker.title` → "Create Home"
- `Loc.HomepagePicker.description` → "Select what you and channel members see..."
- `Loc.later` → "Later"

- [ ] **Step 3: Verify generated code**

Run: `grep -A1 "HomepagePicker" Modules/Loc/Sources/Loc/Generated/Strings.swift`
Expected: Should show the new `HomepagePicker` namespace with `title` and `description`.

- [ ] **Step 4: Commit**

```bash
git add Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings Modules/Loc/Sources/Loc/Generated/Strings.swift
git commit -m "IOS-5903: Add localization strings for homepage picker"
```

---

## Task 2: Model Types

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerOption.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerResult.swift`

- [ ] **Step 1: Create HomepagePickerResult (public output)**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerResult.swift`:

```swift
import Foundation

enum HomepagePickerResult {
    case homepageSet(homepageId: String)
    case later
}
```

- [ ] **Step 2: Create HomepagePickerOption (internal)**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerOption.swift`:

```swift
import Foundation
import Services

enum HomepagePickerOption: String, CaseIterable, Identifiable {
    case chat
    case widgets
    case page
    case collection

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chat: return Loc.chat
        case .widgets: return Loc.SpaceSettings.HomePage.widgets
        case .page: return Loc.page
        case .collection: return Loc.collection
        }
    }

    /// Returns the ObjectTypeUniqueKey for options that create objects.
    /// Widgets does not create an object.
    var objectTypeKey: ObjectTypeUniqueKey? {
        switch self {
        case .chat: return .chatDerived
        case .widgets: return nil
        case .page: return .page
        case .collection: return .collection
        }
    }
}
```

Note: `Loc` is pre-imported. `ObjectTypeUniqueKey` comes from `Services` module. Check `Modules/Services/Sources/Generated/ObjectTypeUniqueKey+Bundled.swift` for available keys.

- [ ] **Step 3: Commit**

```bash
git add Anytype/Sources/PresentationLayer/Modules/HomepagePicker/
git commit -m "IOS-5903: Add HomepagePickerOption and HomepagePickerResult types"
```

---

## Task 3: Service Layer

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerServiceProtocol.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerService.swift`
- Modify: `Anytype/Sources/ServiceLayer/ServicesDI.swift`

**Context:** The service creates objects via existing `ObjectActionsServiceProtocol.createObject()` and stubs the SetHomepage call. Reference `Modules/Services/Sources/Services/ObjectActions/ObjectActionsServiceProtocol.swift` for the `createObject` signature.

- [ ] **Step 1: Create the protocol**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerServiceProtocol.swift`:

```swift
import Foundation

protocol HomepagePickerServiceProtocol {
    /// Creates the homepage object (if needed) and sets it as homepage.
    /// Returns the homepageId (objectId for Chat/Page/Collection, "widgets" for Widgets).
    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> String
}
```

- [ ] **Step 2: Create the implementation**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerService.swift`:

```swift
import Foundation
import Services
import AnytypeCore

final class HomepagePickerService: HomepagePickerServiceProtocol {

    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol

    func createHomepage(spaceId: String, option: HomepagePickerOption) async throws -> String {
        switch option {
        case .widgets:
            try await setHomepage(spaceId: spaceId, homepageId: "widgets")
            return "widgets"
        case .chat, .page, .collection:
            guard let typeKey = option.objectTypeKey else {
                anytypeAssertionFailure("Option \(option) should have objectTypeKey")
                throw HomepagePickerServiceError.missingObjectType
            }
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: typeKey,
                shouldDeleteEmptyObject: false,
                shouldSelectType: false,
                shouldSelectTemplate: false,
                spaceId: spaceId,
                origin: .none,
                templateId: nil,
                createdInContext: "",
                createdInContextRef: ""
            )
            try await setHomepage(spaceId: spaceId, homepageId: details.id)
            return details.id
        }
    }

    // MARK: - Stub

    /// TODO: Replace with Rpc.Workspace.SetHomepage when middleware #2 is ready
    private func setHomepage(spaceId: String, homepageId: String) async throws {
        anytypeAssertionFailure("SetHomepage stub called: spaceId=\(spaceId), homepageId=\(homepageId)")
    }
}

enum HomepagePickerServiceError: Error {
    case missingObjectType
}
```

Note: `anytypeAssertionFailure` is used for debug-only assertions (logs in debug, no-op in release). Check `Modules/AnytypeCore/Sources/AnytypeCore` for usage.

- [ ] **Step 3: Register in DI container**

Open `Anytype/Sources/ServiceLayer/ServicesDI.swift` and add inside the `extension Container` block:

```swift
var homepagePickerService: Factory<any HomepagePickerServiceProtocol> {
    self { HomepagePickerService() }.shared
}
```

Add it alphabetically near other service registrations.

- [ ] **Step 4: Verify compilation**

The project should compile. Report to user for Xcode verification.

- [ ] **Step 5: Commit**

```bash
git add Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerService*.swift
git add Anytype/Sources/ServiceLayer/ServicesDI.swift
git commit -m "IOS-5903: Add HomepagePickerService with object creation and SetHomepage stub"
```

---

## Task 4: Thumbnail Views

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/HomepagePickerThumbnailCard.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/ChatThumbnail.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/WidgetsThumbnail.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/PageThumbnail.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/CollectionThumbnail.swift`

**Design reference:** See Figma screenshots in spec. Light theme: `node-id=12084-12221`, dark theme: `node-id=12084-12393`. The thumbnails are 88x176 rounded cards with geometric shapes inside. Each thumbnail takes an `isSelected: Bool` to switch between accent (blue) and gray colors.

- [ ] **Step 1: Create the card wrapper**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/HomepagePickerThumbnailCard.swift`:

```swift
import SwiftUI

struct HomepagePickerThumbnailCard: View {
    let option: HomepagePickerOption
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 7) {
            thumbnailContent
                .frame(width: 88, height: 176)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.Control.accent50 : Color.Shape.tertiary,
                            lineWidth: isSelected ? 1.5 : 1
                        )
                )

            AnytypeText(option.title, style: .caption1Medium)
                .foregroundStyle(isSelected ? Color.Control.accent100 : Color.Control.secondary)
        }
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        switch option {
        case .chat:
            ChatThumbnail(isSelected: isSelected)
        case .widgets:
            WidgetsThumbnail(isSelected: isSelected)
        case .page:
            PageThumbnail(isSelected: isSelected)
        case .collection:
            CollectionThumbnail(isSelected: isSelected)
        }
    }
}
```

- [ ] **Step 2: Create ChatThumbnail**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/ChatThumbnail.swift`:

Reference Figma: chat shows message bubbles (right-aligned colored, left-aligned gray with avatar circles).

```swift
import SwiftUI

struct ChatThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }
    private var bgColor: Color { isSelected ? Color.Control.accent25 : Color.Shape.secondary }
    private var avatarColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }

    var body: some View {
        ZStack {
            // Right-aligned message bubble (top)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(lineColor)
                .frame(width: 40, height: 12)
                .position(x: 60, y: 30)

            // Left-aligned bubble with avatar
            HStack(spacing: 4) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 12, height: 12)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(bgColor)
                    .frame(width: 40, height: 44)
            }
            .position(x: 40, y: 72)

            // Right-aligned bubble (bottom)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(lineColor)
                .frame(width: 40, height: 32)
                .position(x: 60, y: 126)

            // Left-aligned small bubble + avatar
            HStack(spacing: 4) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 12, height: 12)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(bgColor)
                    .frame(width: 40, height: 12)
            }
            .position(x: 40, y: 158)
        }
    }
}
```

**Important:** These positions are approximate from the Figma layout. After creating the view, visually compare against the Figma screenshots and adjust coordinates as needed. The visual fidelity of these thumbnails is important — they should closely match the design.

- [ ] **Step 3: Create WidgetsThumbnail**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/WidgetsThumbnail.swift`:

Reference Figma: two card sections with bullet rows (small circles + lines).

```swift
import SwiftUI

struct WidgetsThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }
    private var cardBg: Color { isSelected ? Color.Control.accent25 : Color.Shape.transparentTertiary }

    var body: some View {
        VStack(spacing: 6) {
            widgetCard(rows: 3, height: 52)
            statusBar
            widgetCard(rows: 4, height: 64)
        }
        .padding(6)
    }

    private func widgetCard(rows: Int, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<rows, id: \.self) { index in
                HStack(spacing: 4) {
                    Circle()
                        .fill(lineColor)
                        .frame(width: 6, height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(lineColor)
                        .frame(width: index == rows - 1 ? 36 : 54, height: 4)
                }
                .padding(.vertical, 3)
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var statusBar: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(lineColor)
                .frame(width: 6, height: 6)
            RoundedRectangle(cornerRadius: 3)
                .fill(lineColor)
                .frame(width: 36, height: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .frame(height: 16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
```

- [ ] **Step 4: Create PageThumbnail**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/PageThumbnail.swift`:

Reference Figma: document icon + "Idea" title + text lines.

```swift
import SwiftUI

struct PageThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Document icon placeholder
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(lineColor)
                .frame(width: 24, height: 24)
                .padding(.top, 24)

            // "Idea" title
            RoundedRectangle(cornerRadius: 2)
                .fill(lineColor)
                .frame(width: 28, height: 11)
                .padding(.top, 9)

            // Text lines block 1
            textBlock(lines: [68, 68, 68, 51], topPadding: 12)

            // Text lines block 2
            textBlock(lines: [68, 68, 68, 34], topPadding: 8)
        }
        .padding(.horizontal, 10)
    }

    private func textBlock(lines: [CGFloat], topPadding: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, width in
                RoundedRectangle(cornerRadius: 2)
                    .fill(lineColor)
                    .frame(width: width, height: 4)
            }
        }
        .padding(.top, topPadding)
    }
}
```

- [ ] **Step 5: Create CollectionThumbnail**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/CollectionThumbnail.swift`:

Reference Figma: "Tasks" header + toggle + list rows.

```swift
import SwiftUI

struct CollectionThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }
    private var dotColor: Color { isSelected ? Color.Control.accent100 : Color.Shape.tertiary }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: "Tasks" + toggle
            HStack {
                // "Tasks" text placeholder
                RoundedRectangle(cornerRadius: 2)
                    .fill(lineColor)
                    .frame(width: 30, height: 8)
                Spacer()
                // Toggle circle
                Circle()
                    .fill(dotColor)
                    .frame(width: 10, height: 10)
            }
            .padding(.top, 14)

            // List rows
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(lineColor)
                        .frame(width: index % 2 == 0 ? 68 : 48, height: 4)
                }
            }
            .padding(.top, 12)

            Spacer()
        }
        .padding(.horizontal, 10)
    }
}
```

- [ ] **Step 6: Verify compilation and visual output**

Report to user for Xcode verification. The thumbnails should be compared against Figma designs at:
- Light: `figma.com/design/AIsUjTc2FGKlCcNgIlIuue/-M--Navigation---Vault?node-id=12084-12221`
- Dark: `figma.com/design/AIsUjTc2FGKlCcNgIlIuue/-M--Navigation---Vault?node-id=12084-12393`

Positions and sizes are approximations — visual tweaking will be needed.

- [ ] **Step 7: Commit**

```bash
git add Anytype/Sources/PresentationLayer/Modules/HomepagePicker/Thumbnails/
git commit -m "IOS-5903: Add SwiftUI-drawn thumbnail views for homepage picker options"
```

---

## Task 5: ViewModel

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerViewModel.swift`

**Context:** Follows the `@MainActor @Observable` pattern used throughout the codebase. See `Anytype/Sources/PresentationLayer/SpaceSettings/HomePage/HomePagePickerViewModel.swift` for the existing pattern.

- [ ] **Step 1: Create the ViewModel**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerViewModel.swift`:

```swift
import Foundation
import Services

@MainActor
@Observable
final class HomepagePickerViewModel {

    @ObservationIgnored @Injected(\.homepagePickerService)
    private var homepagePickerService: any HomepagePickerServiceProtocol

    var selectedOption: HomepagePickerOption = .chat
    var dismiss = false

    let options = HomepagePickerOption.allCases

    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored
    private let onFinish: (HomepagePickerResult) async throws -> Void

    init(spaceId: String, onFinish: @escaping (HomepagePickerResult) async throws -> Void) {
        self.spaceId = spaceId
        self.onFinish = onFinish
    }

    func onCreate() async throws {
        let homepageId = try await homepagePickerService.createHomepage(
            spaceId: spaceId,
            option: selectedOption
        )
        try await onFinish(.homepageSet(homepageId: homepageId))
        dismiss = true
    }

    func onLater() async throws {
        try await onFinish(.later)
        dismiss = true
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerViewModel.swift
git commit -m "IOS-5903: Add HomepagePickerViewModel with selection state and service integration"
```

---

## Task 6: Main View

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerView.swift`

**Context:** Uses `fitPresentationDetents()` from `Anytype/Sources/FrameworkExtensions/SwiftUI/View+Detents.swift`. Uses `AsyncStandardButton` from `Modules/DesignKit/Sources/DesignKit/Components/AsyncButton/AsyncStandardButton.swift`. Uses `AsyncStandardButtonGroup` to coordinate button disable states.

- [ ] **Step 1: Create the View**

Create `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerView.swift`:

```swift
import SwiftUI
import DesignKit

struct HomepagePickerView: View {

    @State private var model: HomepagePickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String, onFinish: @escaping (HomepagePickerResult) async throws -> Void) {
        _model = State(initialValue: HomepagePickerViewModel(spaceId: spaceId, onFinish: onFinish))
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(31)

            titleSection

            Spacer.fixedHeight(24)

            optionsScroll

            Spacer.fixedHeight(24)

            buttons

            Spacer.fixedHeight(16)
        }
        .background(Color.Background.secondary)
        .fitPresentationDetents()
        .presentationDragIndicator(.hidden)
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }

    // MARK: - Sections

    private var titleSection: some View {
        VStack(spacing: 8) {
            AnytypeText(Loc.HomepagePicker.title, style: .heading)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)

            AnytypeText(Loc.HomepagePicker.description, style: .uxTitle2Regular)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 37)
        }
    }

    private var optionsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(model.options) { option in
                    HomepagePickerThumbnailCard(
                        option: option,
                        isSelected: model.selectedOption == option
                    )
                    .onTapGesture {
                        model.selectedOption = option
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var buttons: some View {
        AsyncStandardButtonGroup {
            VStack(spacing: 8) {
                AsyncStandardButton(Loc.create, style: .primaryLarge) {
                    try await model.onCreate()
                }

                AsyncStandardButton(Loc.later, style: .secondaryLarge) {
                    try await model.onLater()
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
```

**Note on `Loc.later`:** After `make generate` in Task 1, verify the exact generated accessor. It should be `Loc.later` (lowercase). If SwiftGen generates it differently (e.g., `Loc.Later`), adjust accordingly.

- [ ] **Step 2: Verify compilation**

Report to user for Xcode verification.

- [ ] **Step 3: Commit**

```bash
git add Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerView.swift
git commit -m "IOS-5903: Add HomepagePickerView with layout, scroll, and button actions"
```

---

## Task 7: Coordinator Integration

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/Coordinator/SpaceCreateCoordinatorView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/Coordinator/SpaceCreateCoordinatorViewModel.swift`

**Context:** The existing coordinator already presents `HomePagePickerView` behind `FeatureFlags.homePage`. We add a parallel path for the new picker. Read both files first:
- `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/Coordinator/SpaceCreateCoordinatorView.swift`
- `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/Coordinator/SpaceCreateCoordinatorViewModel.swift`

- [ ] **Step 1: Add new state property to ViewModel**

In `SpaceCreateCoordinatorViewModel.swift`, reuse the existing `HomePagePickerData` struct (it's identical to what we need — just `spaceId`). Add a new `@Observable` property:

```swift
var newHomepagePickerData: HomePagePickerData?
```

We prefix with `new` to distinguish from the existing `homePagePickerData` property used by the old picker. Both will coexist temporarily until the old picker is removed.

- [ ] **Step 2: Update onSpaceCreated to present new picker**

In `SpaceCreateCoordinatorViewModel.onSpaceCreated()`, update the `FeatureFlags.homePage` branch to present the new picker instead:

```swift
func onSpaceCreated(spaceId: String) async throws {
    if FeatureFlags.homePage {
        pendingSpaceId = spaceId
        newHomepagePickerData = HomePagePickerData(spaceId: spaceId)
    } else {
        try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
    }
}
```

- [ ] **Step 3: Add result handler**

Add a new method to handle the picker result:

```swift
func onHomepagePickerFinished(result: HomepagePickerResult) async throws {
    guard let spaceId = pendingSpaceId else { return }
    pendingSpaceId = nil

    switch result {
    case .homepageSet:
        try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
        // TODO: Navigate to the homepage object (separate task)
    case .later:
        try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
        // TODO: Handle temporary widgets (separate task)
    }
}
```

- [ ] **Step 4: Wire the sheet in CoordinatorView**

In `SpaceCreateCoordinatorView.swift`, replace the existing `.sheet(item: $model.homePagePickerData)` with the new picker:

```swift
.sheet(item: $model.newHomepagePickerData) { data in
    HomepagePickerView(spaceId: data.spaceId) { result in
        try await model.onHomepagePickerFinished(result: result)
    }
    .interactiveDismissDisabled(true)
}
```

Keep the old `.sheet(item: $model.homePagePickerData)` block as-is — it's used by the existing `HomePagePickerView` for Settings flow and will be removed separately.

- [ ] **Step 5: Verify compilation**

Report to user for Xcode verification.

- [ ] **Step 6: Commit**

```bash
git add Anytype/Sources/PresentationLayer/Modules/SpaceCreate/Coordinator/
git commit -m "IOS-5903: Wire HomepagePicker into SpaceCreate coordinator"
```

---

## Post-Implementation Checklist

After all tasks are complete, verify against acceptance criteria:

- [ ] Bottom sheet shows 4 options with SwiftUI-drawn thumbnails
- [ ] Horizontal scroll works for thumbnail list
- [ ] Tapping a thumbnail selects it (blue border + accent colors + blue label)
- [ ] Light and dark theme both look correct
- [ ] "Create" button creates object + calls SetHomepage stub + returns `.homepageSet`
- [ ] "Widgets" option calls SetHomepage stub with "widgets" + returns `.homepageSet`
- [ ] "Later" dismisses without action, returns `.later`
- [ ] Interactive dismiss is disabled (only buttons dismiss)
- [ ] Sheet auto-sizes to content via `fitPresentationDetents`
- [ ] No drag indicator visible
- [ ] AsyncStandardButton shows loading dots during create, error toast on failure
- [ ] Both buttons are disabled while "Create" is in progress
