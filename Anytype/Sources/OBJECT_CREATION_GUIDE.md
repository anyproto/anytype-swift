# Object Creation Entry Points

This document lists all places in the app where objects can be created.

## Core Creation Services

| Service | Method | Purpose |
|---------|--------|---------|
| `ObjectActionsServiceProtocol` | `createObject()` | Primary object creation with full control |
| `DefaultObjectCreationService` | `createDefaultObject()` | Creates default type for space (usually Page) |
| `BookmarkServiceProtocol` | `createBookmarkObject()` | Creates bookmark objects from URLs |
| `DataviewService` | `addRecord()` | Creates objects in Sets/Collections |

---

## UI Entry Points

### 1. Bottom Navigation Plus Button

**File:** `HomeBottomNavigationPanelViewModel.swift`

**Methods:**
- `onTapNewObject()` - Creates default object
- `onTapCreateObject(type:)` - Creates specific type

**Types:** Page, Note, Task, Chat, or any pinned type

**Special handling:**
- Chat types → `ScreenData.alert(.chatCreate(...))` → Shows ChatCreateView

---

### 2. Home Widgets

#### 2a. Pinned Widget
**File:** `PinnedWidgetInternalViewModel.swift`
- Creates default object and pins it

#### 2b. Object Widget (Linked Documents)
**File:** `ObjectWidgetInternalViewModel.swift`
- Creates default object and links to parent

#### 2c. ObjectType Widget
**File:** `ObjectTypeWidgetViewModel.swift`
- Creates object of the widget's specific type

#### 2d. Set/Collection Widget
**File:** `SetObjectWidgetInternalViewModel.swift`
- Delegates to `SetObjectCreationCoordinator`
- Supports chat and bookmark creation flows

---

### 3. Set/Collection Plus Button

**Files:**
- `SetObjectCreationCoordinator.swift`
- `SetObjectCreationHelper.swift`

**Creates based on set type:**
- Regular objects (default type for set)
- Bookmarks (for bookmark sets) → Shows URL input
- Chats (for chat collections) → Shows ChatCreateView
- Collection items (any type)

---

### 4. Type Search (Long Tap on Plus)

**File:** `TypeSearchForNewObjectCoordinatorViewModel.swift`

**Triggers:**
- Long tap on plus button
- "New Object" from various locations

**Special handling:**
- Chat types → Shows ChatCreateView
- URL in clipboard → Creates Bookmark
- Text in clipboard → Creates default with pasted content

---

### 5. Quick Actions (3D Touch / App Shortcuts)

**Files:**
- `QuickActionShortcutBuilder.swift`
- `SpaceHubCoordinatorViewModel.swift`

**Flow:** App shortcut → `AppAction.createObjectFromQuickAction` → Creates specific type

**Special handling:**
- Chat types → Shows ChatCreateView

---

### 6. Deep Links

**File:** `SpaceHubCoordinatorViewModel.swift`

**Link:** `anytype://create-object-widget`

**Creates:** Default object type

---

### 7. Sharing Extension

**File:** `SharingExtensionActionService.swift`

**Creates:**
- Notes (for text content)
- Bookmarks (for URLs)
- Files (for media)

**Can add to:** Collections or Chats

---

### 8. Slash Menu (In-Editor)

**File:** `SlashMenuActionHandler.swift`

**Trigger:** Type `/` then select object type

**Creates:** New page/list and links it inline

---

### 9. Link-To-Object Search

**File:** `LinkToObjectSearchViewModel.swift`

**Trigger:** Search doesn't match → "Create [name]" suggestion

**Creates:** Default object with search text as name

---

### 10. Mentions

**File:** `MentionsViewModel.swift`

**Trigger:** Type `@` then new name → "Create [name]"

**Creates:** Default object to mention

---

### 11. Object Search

**File:** `BlockObjectsSearchInteractor.swift`

**Trigger:** Search new name → "Create [name]" suggestion

**Creates:** Default object

---

### 12. Chat Input

**File:** `ChatActionService.swift`

**Trigger:** Sending message with URL attachment

**Creates:** Bookmark object automatically

---

## Analytics Routes

Each creation path uses an analytics route:

| Route | Source |
|-------|--------|
| `.navigation` | Bottom nav, type search |
| `.widget` | Home widgets, deep link |
| `.homeScreen` | Quick actions |
| `.set` / `.collection` | Set/Collection plus button |
| `.slashMenu` | Slash menu in editor |
| `.clipboard` | Paste from clipboard |
| `.sharingExtension` | Share extension |
| `.mention` | Mention creation |
| `.search` | Search creation |

---

## Special Type Handling

### Chat Objects
Must show `ChatCreateView` for name/icon input before creation.

**Entry points with chat support:**
- Bottom navigation plus menu
- Type search (long tap)
- Quick actions
- Set/Collection (chat collections)
- Widget (via SetObjectCreationCoordinator)

**Pattern:**
```swift
if type.isChatType {
    // Route to ChatCreateView via AlertScreenData
    let screenData = ScreenData.alert(.chatCreate(ChatCreateScreenData(...)))
    output?.onCreateObjectSelected(screenData: screenData)
}
```

### Bookmark Objects
Must show URL input before creation.

**Entry points with bookmark support:**
- Set/Collection (bookmark sets)
- Type search (URL in clipboard)
- Sharing extension
- Chat input (auto-created)

---

## Adding New Special Type Handling

To add special creation UI for a new type:

1. Create screen data in `AlertScreenData.swift`:
```swift
struct MyTypeCreateScreenData: Hashable, Identifiable {
    let spaceId: String
    // ... other properties
}

enum AlertScreenData {
    case myTypeCreate(MyTypeCreateScreenData)
}
```

2. Handle in `SpaceHubCoordinatorViewModel.showAlert()`:
```swift
case .myTypeCreate(let data):
    myTypeCreateData = MyTypeCreateData(...)
```

3. Update entry points to check type and route:
```swift
if type.isMyType {
    let screenData = ScreenData.alert(.myTypeCreate(...))
    output?.onCreateObjectSelected(screenData: screenData)
}
```
