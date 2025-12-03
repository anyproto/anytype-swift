# SpaceUXType Guide

This guide documents all logic forks in the codebase that depend on `SpaceUxType`. Use this as a reference when implementing features that behave differently based on space type.

## Overview

`SpaceUxType` defines the user experience paradigm for a space. Different types have different initial screens, capabilities, and UI treatments.

**Enum Definition:** `Modules/ProtobufMessages/Sources/Protocol/Models/Anytype_Model_SpaceUxType.swift`

### Types

| Type | Value | Description |
|------|-------|-------------|
| `.none` | 0 | Deprecated (old chat value) |
| `.data` | 1 | Objects-first UX - traditional space with widgets |
| `.stream` | 2 | Stream UX - chat with limited amount of owners |
| `.chat` | 3 | Chat UX - chat-first experience |
| `.oneToOne` | 4 | 1-1 space with immutable ACL between two participants |

## Quick Reference

| Type | Initial Screen | Multi-Chat | Icon | Chat Type Visible |
|------|----------------|------------|------|-------------------|
| `.data` | Widgets | Yes | Space | Yes |
| `.chat` | Chat | No | Chat | No |
| `.stream` | Chat | No | Space | No |
| `.oneToOne` | Chat | No | Chat | No |
| `.none` | Widgets | No | Space | No |

## Detailed Logic Forks

### 1. Initial Screen Navigation

**What it controls:** Whether a space opens to chat or home widgets.

**File:** `Anytype/Sources/ServiceLayer/SpaceStorage/Models/SpaceView.swift`

```swift
var initialScreenIsChat: Bool {
    switch uxType {
    case .chat, .stream, .oneToOne:
        return true
    case .data, .none, .UNRECOGNIZED:
        return false
    }
}
```

**Impact locations:**
- `SpaceHubCoordinatorViewModel.swift` - Opens space with `SpaceChatCoordinatorData` or `HomeWidgetData`
- `ChatHeaderViewModel.swift` - Determines if widgets button shows in chat header
- `HomeBottomNavigationPanelViewModel.swift` - Shows/hides "Add to Space Level Chat" button

---

### 2. Multi-Chat Support

**What it controls:** Whether a space can contain multiple chat objects.

**File:** `Modules/Services/Sources/Models/Space/SpaceUxType+Extensions.swift`

```swift
var supportsMultiChats: Bool {
    switch self {
    case .chat, .stream, .none, .oneToOne, .UNRECOGNIZED:
        return false
    case .data:
        return true
    }
}
```

**Impact locations:**
- `SearchFiltersBuilder.swift` - Filters out chat type from object creation in non-data spaces
- `DetailsLayoutExtension.swift` - Hides `.chatDerived` layout in non-data spaces
- `SharingExtensionViewModel.swift` - Different UX flow for sharing content
- `ObjectTypeSearchViewModel.swift` - Controls chat type visibility during creation
- `SpaceCardModelBuilder.swift` - Passes flag for UI rendering
- `NewSpaceCardLastMessageView.swift` - Only shows chat metadata in data spaces

---

### 3. Layout/Type Filtering

**What it controls:** Which object layouts are available for creation.

**File:** `Modules/Services/Sources/Models/Extensions/DetailsLayoutExtension.swift`

```swift
static func visibleLayouts(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
    guard !spaceUxType.supportsMultiChats else { return visibleLayoutsBase }
    return visibleLayoutsBase.filter { $0 != .chatDerived }
}
```

**File:** `Modules/Services/Sources/Services/SearchService/SearchFiltersBuilder.swift`

```swift
if !spaceUxType.supportsMultiChats {
    filters.append(SearchHelper.filterOutChatType())
}
```

---

### 4. UI Display (Icons & Names)

**What it controls:** Visual representation in settings and UI.

**File:** `Anytype/Sources/PresentationLayer/SpaceSettings/SpaceSettings/Models/SpaceUxTypeSettingsData.swift`

```swift
init(uxType: SpaceUxType) {
    switch uxType {
    case .chat, .oneToOne:
        icon = .X24.chat
    case .data, .stream, .none, .UNRECOGNIZED:
        icon = .X24.space
    }
    typeName = uxType.name
}
```

**File:** `Anytype/Sources/ServiceLayer/SpaceStorage/Models/SpaceUxType+Localize.swift`

```swift
var name: String {
    switch self {
    case .chat: return Loc.Spaces.UxType.Chat.title
    case .data: return Loc.Spaces.UxType.Space.title
    case .stream: return Loc.Spaces.UxType.Stream.title
    case .oneToOne: return Loc.Spaces.UxType.OneToOne.title
    case .UNRECOGNIZED, .none: return ""
    }
}
```

---

### 5. Widget Display

**What it controls:** Chat metadata visibility in space cards.

**File:** `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/NewSpaceCardLastMessageView.swift`

```swift
// Only shows chat name in data spaces (multi-chat)
if supportsMultiChats, let chatName = model.chatName { ... }

// Only shows creator info in data spaces
if supportsMultiChats, let creatorTitle = model.creatorTitle { ... }
```

---

### 6. Sharing Extension Behavior

**What it controls:** Flow when sharing content to a space.

**File:** `Anytype/Sources/PresentationLayer/Modules/SharingExtension/SharingExtensionViewModel.swift`

```swift
func onTapSpace(_ space: SpaceView) {
    if !space.uxType.supportsMultiChats {
        // Non-data: select space directly
        selectedSpace = space == selectedSpace ? nil : space
    } else {
        // Data space: route to object selection
        selectedSpace = nil
        output?.onSelectDataSpace(spaceId: space.targetSpaceId)
    }
}
```

---

### 7. Navigation Path Management

**What it controls:** Navigation stack structure when opening a space.

**File:** `Anytype/Sources/PresentationLayer/Flows/SpaceHub/Support/SpaceHubPathManager.swift`

```swift
switch spaceView.uxType {
case .chat, .oneToOne, .stream:
    // Path: SpaceHubNavigationItem → SpaceChatCoordinatorData
    let chatItem = SpaceChatCoordinatorData(spaceId: spaceView.targetSpaceId)
    path.remove(chatItem)
    path.insert(chatItem, at: 1)
case .data:
    // Path: SpaceHubNavigationItem → HomeWidgetData
    let homeItem = HomeWidgetData(spaceId: spaceView.targetSpaceId)
    path.remove(chatItem)
    path.remove(homeItem)
    path.insert(homeItem, at: 1)
case .none, .UNRECOGNIZED:
    break
}
```

---

### 8. Chat Widget Addition

**What it controls:** Whether a chat widget can be added to home.

**File:** `Anytype/Sources/ServiceLayer/SpaceStorage/Models/SpaceView.swift`

```swift
var canAddChatWidget: Bool {
    !initialScreenIsChat && isShared && hasChat
}
```

Only data spaces (where `initialScreenIsChat` is false) that are shared and have a chat can add the chat widget.

---

### 9. Mention Counter Display

**What it controls:** Whether mention counters (@) are shown in space cards.

**File:** `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpaceHubSpacesStorage.swift`

```swift
// TODO: IOS-5561 - Temporary client-side fix. Should be handled by middleware.
let totalMentions = space.spaceView.uxType.isOneToOne
    ? 0
    : spacePreviews.reduce(0) { $0 + $1.mentionCounter }
```

**Behavior:**
- **1-1 spaces**: Mention counter is always hidden (set to 0 at data construction). In 1-1 chats, replies and mentions are implicit since you're always talking to one person.
- **All other spaces**: Mention counter displayed as reported by middleware.

**Note:** This is a temporary client-side workaround. The proper fix should be implemented in the middleware.

**Related:** IOS-5561

---

### 10. Chat Mentions

**What it controls:** Whether the @ mention popup appears in chat.

**File:** `Anytype/Sources/PresentationLayer/Modules/Chat/ChatViewModel.swift`

```swift
func updateMentionState() async throws {
    guard !spaceUxType.isOneToOne else {
        mentionObjectsModels = []
        return
    }
    // ... search for mentions
}
```

**Behavior:**
- **1-1 spaces**: Mention popup is disabled. Typing `@` inserts the character but shows no suggestions.
- **All other spaces**: Mention popup shows matching participants.

**Rationale:** In 1-1 chats there's only one other participant, making mentions redundant.

**Related:** IOS-5560

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `Modules/ProtobufMessages/.../Anytype_Model_SpaceUxType.swift` | Enum definition |
| `Modules/Services/.../SpaceUxType+Extensions.swift` | Helper properties (`isChat`, `supportsMultiChats`, etc.) |
| `Anytype/.../SpaceStorage/Models/SpaceView.swift` | Computed properties (`initialScreenIsChat`, `canAddChatWidget`) |
| `Anytype/.../SpaceStorage/Models/SpaceUxType+Localize.swift` | Localized display names |
| `Anytype/.../SpaceHub/Support/SpaceHubPathManager.swift` | Navigation path management |
| `Anytype/.../SpaceSettings/Models/SpaceUxTypeSettingsData.swift` | UI icons and type name |
| `Modules/Services/.../SearchFiltersBuilder.swift` | Search/creation filtering |
| `Modules/Services/.../DetailsLayoutExtension.swift` | Layout visibility |
| `Anytype/.../SharingExtension/SharingExtensionViewModel.swift` | Share extension flow |
| `Anytype/.../SpaceCard/NewSpaceCardLastMessageView.swift` | Card metadata display |

---

## Adding New Type-Dependent Behavior

When adding new behavior that depends on space type:

1. **Determine the grouping:** Does your feature align with existing patterns?
   - Chat-first spaces (`.chat`, `.stream`, `.oneToOne`) vs data spaces (`.data`)
   - Multi-chat capable (`.data` only) vs single-chat

2. **Use existing helpers when possible:**
   ```swift
   // Preferred - uses existing abstraction
   if spaceView.initialScreenIsChat { ... }
   if spaceUxType.supportsMultiChats { ... }

   // Avoid - raw enum checks unless truly needed
   if spaceUxType == .chat { ... }
   ```

3. **Add new helpers for new groupings:**
   - Add to `SpaceUxType+Extensions.swift` for type-level helpers
   - Add to `SpaceView.swift` for space-level computed properties

4. **Update this guide** when adding significant new logic forks.
