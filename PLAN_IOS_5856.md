# IOS-5856: Create Channel Flow

## Overview

Replace the current Chat Space / Data Space selection with a unified **Create Channel** flow.
Channels are unified — the only difference is which object opens by default (Homepage).
Homepage is changeable at any time.

**Linear**: https://linear.app/anytype/issue/IOS-5856/create-channel-flow
**Feature Toggle**: `createChannelFlow` (all new behavior gated behind this)

## Key Concepts

- **Channel** = Space. No more Chat Space vs Data Space distinction.
- **Homepage** = what opens when user enters the channel (Chat / Widgets / Page / Collection). Stored as `homepage` relation on spaceView.
- **SpaceType** = new read-only relation on spaceView (derived by middleware). Replaces `SpaceUxType` for distinguishing oneToOne from regular.
- **Personal channel** = private (non-shared) space
- **Group channel** = shared space, always shared even if no members selected

## Middleware Commands

| Command | Purpose | Notes |
|---------|---------|-------|
| `WorkspaceCreate` | Create space | Use `model.SpaceType = SpaceTypeRegular`. `withChat` deprecated. Empty useCase for channels |
| `Rpc.Workspace.SetHomepage(spaceId, homepage)` | Set homepage | Values: `"widgets"`, objectId, `""` (empty). Replaces old `ObjectWorkspaceSetDashboard` |
| `Rpc.Space.ParticipantAdd(spaceId, identities[])` | Add members | Same identity format as `oneToOneIdentity`. Analogous to existing `ParticipantRemove` |

## Flows

### Personal Channel
```
[+] → Menu (Personal) → Name & Icon → Create → Homepage Picker
```

### Group Channel
```
[+] → Menu (Group) → [Limit Check] → Select Members → Name & Icon (with members) → Create → ParticipantAdd → Homepage Picker
```

### Homepage Picker (bottom sheet)
- Options: Chat / Widgets / Page / Collection (with preview thumbnails)
- "Create" — creates object (for Chat/Page/Collection) then calls SetHomepage; for Widgets calls SetHomepage("widgets")
- "Later" — dismisses, homepage stays empty

## Design Links

- Main flow: https://www.figma.com/design/AIsUjTc2FGKlCcNgIlIuue/-M--Navigation---Vault?node-id=11987-10921
- Edge cases: https://www.figma.com/design/AIsUjTc2FGKlCcNgIlIuue/-M--Navigation---Vault?node-id=12435-21923

---

## Decomposition & Progress

### Layer 0: Foundation

#### 1. Feature Toggle + SpaceType Migration — [IOS-5900](https://linear.app/anytype/issue/IOS-5900)
- [ ] Add `createChannelFlow` feature flag
- [ ] Add `spaceType` relation to `SpaceView` model (from middleware)
- [ ] Use `spaceType == .oneToOne` instead of `SpaceUxType` under the toggle
- **Branch**: `ios-5900-feature-toggle-spacetype-migration`
- **Status**: Not started
- **Key files**: `FeatureDescription+Flags.swift`, `SpaceView.swift`, `SpaceUxType+Extensions.swift`

#### 2. SetHomepage Middleware Integration — [IOS-5901](https://linear.app/anytype/issue/IOS-5901)
- [ ] Wrap `Rpc.Workspace.SetHomepage(spaceId, homepage)` in service layer
- [ ] Support values: `"widgets"`, objectId, empty string
- [ ] Stop using old `ObjectWorkspaceSetDashboard`
- **Branch**: `ios-5901-sethomepage-middleware-integration`
- **Status**: Not started
- **Key files**: `WorkspaceService.swift`

#### 3. ParticipantAdd Middleware Integration — [IOS-5902](https://linear.app/anytype/issue/IOS-5902)
- [ ] Wrap `Rpc.Space.ParticipantAdd(spaceId, identities[])` in service layer
- [ ] Model it analogously to existing `ParticipantRemove`
- **Branch**: `ios-5902-participantadd-middleware-integration`
- **Status**: Not started
- **Key files**: `WorkspaceService.swift`

---

### Layer 1: Reusable UI Components

#### 4. Homepage Picker Screen — [IOS-5903](https://linear.app/anytype/issue/IOS-5903)
- [ ] New bottom sheet: Chat / Widgets / Page / Collection with thumbnails
- [ ] "Create" button: create object + SetHomepage
- [ ] "Later" button: dismiss without setting
- [ ] Reusable for both creation flow and settings
- **Depends on**: #2 (SetHomepage)
- **Branch**: `ios-5903-homepage-picker-screen`
- **Status**: Not started
- **Key files**: New `HomePagePicker/` module

#### 5. Select Members Screen — [IOS-5904](https://linear.app/anytype/issue/IOS-5904)
- [ ] List contacts from spaceView subscription filtered by `oneToOneIdentity`
- [ ] Show name, avatar, Anytype ID
- [ ] Search + multi-select
- [ ] "Next" to skip without selecting
- **Depends on**: None
- **Branch**: `ios-5904-select-members-screen`
- **Status**: Not started

---

### Layer 2: Main Flows

#### 6. Updated Creation Menu — [IOS-5905](https://linear.app/anytype/issue/IOS-5905)
- [ ] Replace Chat/Space/QR with Personal/Group/Join via QR Code
- [ ] Gate behind `createChannelFlow` toggle
- **Depends on**: #1 (toggle)
- **Branch**: `ios-5905-updated-creation-menu-personal-group-qr`
- **Status**: Not started
- **Key files**: `SpaceTypePickerView.swift`

#### 7. Personal Channel Flow — [IOS-5906](https://linear.app/anytype/issue/IOS-5906)
- [ ] Name & Icon -> Create (SpaceTypeRegular, private, empty useCase, no withChat) -> Homepage Picker
- [ ] No auto `makeSharable`/`generateInvite`
- **Depends on**: #4, #6
- **Branch**: `ios-5906-personal-channel-creation-flow`
- **Status**: Not started

#### 8. SpaceCreate Screen Update for Group — [IOS-5907](https://linear.app/anytype/issue/IOS-5907)
- [ ] Show selected members below name input
- [ ] Accept members list as input parameter
- **Depends on**: #5
- **Branch**: `ios-5907-spacecreate-screen-show-selected-members`
- **Status**: Not started

#### 9. Group Channel Flow (orchestration) — [IOS-5908](https://linear.app/anytype/issue/IOS-5908)
- [ ] Select Members -> Name & Icon (with members) -> Create (shared) -> ParticipantAdd -> Homepage Picker
- [ ] Always shared even if no members selected
- **Depends on**: #3, #4, #5, #6, #8
- **Branch**: `ios-5908-group-channel-creation-flow-orchestration`
- **Status**: Not started

#### 10. Homepage in Space Settings — [IOS-5909](https://linear.app/anytype/issue/IOS-5909)
- [ ] Add "Home" field in Settings -> Preferences
- [ ] Tap opens menu: select existing object or Widgets
- [ ] Uses same SetHomepage command
- **Depends on**: #2
- **Branch**: `ios-5909-homepage-setting-in-space-settings`
- **Status**: Not started

---

### Layer 3: Widgets & Edge Cases

#### 11. Stub Widgets (Create Home + Invite Members) — [IOS-5910](https://linear.app/anytype/issue/IOS-5910)
- [ ] "Create Home" widget: appears when homepage empty, tap opens Homepage Picker, X dismisses permanently, disappears when homepage set
- [ ] "Invite Members" widget: appears in Group with no members, tap opens Invite, X dismisses, disappears when member added
- [ ] Order: Create Home on top, Invite Members below
- **Depends on**: #4 (Homepage Picker)
- **Branch**: `ios-5910-stub-widgets-create-home-invite-members`
- **Status**: Not started

#### 12. Limits Handling — [IOS-5911](https://linear.app/anytype/issue/IOS-5911)
- [ ] Shared space limit: on "Group" tap check limit -> show bottom sheet if reached (don't start flow)
- [ ] Editor seat limit: on Select Members, if too many -> inline message about Editors vs Viewers + upgrade link
- **Depends on**: #5, #9
- **Branch**: `ios-5911-limits-handling-shared-space-editor-seats`
- **Status**: Not started

#### 13. Chat Type Filtering Removal + Offline Handling — [IOS-5912](https://linear.app/anytype/issue/IOS-5912)
- [ ] Remove Chat type filtering for regular channels (keep for oneToOne)
- [ ] Allow multiple chat objects in any regular channel
- [ ] Offline group creation: cache identities, show "pending", call ParticipantAdd on reconnect
- **Depends on**: #1 (SpaceType)
- **Branch**: `ios-5912-chat-type-filtering-removal-offline-group-handling`
- **Status**: Not started

---

## Current Codebase Reference

### Space Creation (current)
- Entry: `SpaceHubCoordinatorViewModel.onSelectCreateObject()` -> `SpaceTypePickerView`
- Creation: `SpaceCreateView` + `SpaceCreateViewModel` -> `WorkspaceService.createSpace()`
- Coordinator: `SpaceCreateCoordinatorViewModel` handles post-creation (homepage, active space)
- RPC: `ClientCommands.workspaceCreate()` with name, iconOption, accessType, uxType, useCase, withChat

### SpaceView Model
- File: `Anytype/Sources/ServiceLayer/SpaceStorage/Models/SpaceView.swift`
- Key fields: `uxType`, `spaceAccessType`, `readersLimit`, `writersLimit`, `oneToOneIdentity`, `chatId`
- New field needed: `spaceType` (from middleware)

### Widget System
- `BlockWidgetInfo` with `autoAdded` flag
- Service: `BlockWidgetService.createWidgetBlock()`
- Container: `HomeWidgets/Container/`

### Limits
- `SpaceView.canAddWriters(participants:)`, `readersLimit`, `writersLimit`
- `SpaceLimitBannerView` for limit UI
- `makeSharable()` throws `limitReached`

### Invite System
- `spaceInviteGenerate()`, `spaceMakeShareable()`
- `InviteType`: member, guest, withoutApprove
- `ParticipantPermissions`: reader, writer, owner

### Existing Homepage (feature-gated)
- `FeatureFlags.homePage`
- `HomePagePickerView` + `HomePagePickerViewModel`
- Stored in `UserDefaultsStorage.homeObjectId(spaceId:)`
- Will be replaced by the new middleware-based SetHomepage approach
