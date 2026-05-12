# IOS-6007: Update Space Icons & Unify Chat/Data Space Behavior

## Overview
After unifying chat spaces and data spaces into "regular" spaces, two things remain:
1. **Icon shape**: Round icons should only be used for one-on-one spaces; all others get square icons
2. **Behavioral differences**: Eliminate UI/behavioral differences between former chat and data spaces. All regular spaces behave like former data spaces. One-on-one special behavior is preserved.

The core change: replace `SpaceUxType`-based branching with `SpaceType`-based checks in UI/behavioral code. The new distinction is simple: `isOneToOne` vs everything else.

## Scope
**In scope**: Icon shape, space card UI, notification controls, message preview, space settings, share suggestions, object menus, navigation — the visible behavioral differences between chat and data spaces.

**Out of scope** (follow-up tasks):
- Full `SpaceUxType` removal from service layer and feature-flagged code (~24 files behind `FeatureFlags.createChannelFlow`)
- Analytics `SpaceUxType` migration
- Stream-specific behavior changes (stream is a separate concept, leave `isStream` checks as-is)

## Context
- `SpaceView` already has `spaceType: SpaceType` and `isOneToOne: Bool` (using `spaceType == .oneToOne`)
- `SpaceView.uxType` is marked `@available(*, deprecated)`
- No extensions exist on `SpaceType` yet; helpers (`supportsMultiChats`, etc.) live only on `SpaceUxType`
- ~50 files reference `SpaceUxType`; this plan covers the ~15 UI/behavioral files

## Development Approach
- **Testing approach**: Regular (code first)
- Complete each task fully before moving to the next
- This is primarily a refactoring task: replacing type checks, not adding new logic
- Verify compilation after each task (user checks in Xcode)
- Stream-specific checks (`isStream`) encountered in files we touch: leave as-is, note them

## Solution Overview
Replace `SpaceUxType`-based checks with `SpaceType`-based checks:
- `supportsMultiChats` (chat=false, data=true) becomes `!isOneToOne` (all regular spaces support multi chats)
- `isData` / `isChat` checks become irrelevant (both are now regular)
- `isOneToOne` checks migrate from `uxType.isOneToOne` to `spaceView.isOneToOne` (already uses `spaceType`)
- Where `SpaceType` is accessed directly (not via SpaceView), use `spaceType == .oneToOne`

## Implementation Steps

### Task 1: Icon shape - round only for one-on-one

**Files:**
- Modify: `Modules/Services/Sources/Models/Details/ObjectIconBuilder.swift`

- [x] Change `circular: !relations.spaceUxTypeValue.supportsMultiChats` to `circular: relations.spaceTypeValue == .oneToOne` (line ~55)

### Task 2: Space card model & notification controls

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/SpaceCardModelBuilder.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/SpaceCard.swift`

- [x] In `SpaceCardModelBuilder`: replace `spaceView.uxType.supportsMultiChats` with `!spaceView.isOneToOne`, replace `spaceView.uxType.isOneToOne` with `spaceView.isOneToOne`
- [x] Verify `SpaceCard.muteButton` works correctly: `NotificationModeMenu` for all regular spaces (supportsMultiChats=true), `MuteToggleMenuButton` only for oneToOne — no change needed, model values drive it

### Task 3: Space card label & message preview

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/NewSpaceCardLabel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/NewSpaceCardLastMessageView.swift`

- [x] In `NewSpaceCardLabel.showMessage`: no change needed — reads from model.supportsMultiChats which is now !isOneToOne
- [x] In `NewSpaceCardLabel`: multichat compact preview now shows for all regular spaces via model
- [x] In `NewSpaceCardLastMessageView`: no change needed — reads supportsMultiChats/showsMessageAuthor from model

### Task 4: Space card counters builder

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpacePreviewCountersBuilder.swift`

- [x] Replace `spaceView.uxType.supportsMultiChats` with `!spaceView.isOneToOne`
- [x] Replace `spaceView.uxType.supportsMentions` with `!spaceView.isOneToOne`
- [x] Leave `spaceView.uxType.showsMessageAuthor` as-is in SpaceCardModelBuilder (stream-specific)
- [x] Multichat compact preview now builds for all non-oneToOne spaces (via SpaceCardModelBuilder Task 2)

### Task 5: Widgets header & space info

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/Submodule/WidgetsHeader/WidgetsHeaderViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/Submodule/WidgetsHeader/WidgetsHeaderView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/Subviews/SpaceInfoView/SpaceInfoViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift`

- [x] In `WidgetsHeaderViewModel`: replaced `uxType.isOneToOne` → `isOneToOne`, `isDataSpace` → `!isOneToOne`
- [x] Left `uxType.isStream` check as-is in `WidgetsHeaderViewModel` (stream-specific invite logic)
- [x] `WidgetsHeaderView.notificationsMenu`: no change needed — reads from `isDataSpace` which is now `!isOneToOne`
- [x] In `SpaceInfoViewModel`: replaced `space.uxType.isOneToOne` → `space.isOneToOne`
- [x] In `HomeWidgetsViewModel`: replaced `uxType.supportsMultiChats` → `!isOneToOne` (2 places)

### Task 6: Space settings

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/SpaceSettings/SpaceSettings/SpaceSettingsViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/SpaceSettings/SpaceSettings/Models/SpaceUxTypeSettingsData.swift`

- [x] In `SpaceSettingsViewModel`: replaced `uxType.isOneToOne` → `isOneToOne` (3 places), `uxType.supportsMultiChats` → `!isOneToOne`
- [x] Left `uxType.isStream` in `updateInviteIfNeeded()` as-is (stream-specific)
- [x] In `SpaceUxTypeSettingsData`: updated icon mapping — oneToOne → `.X24.chat`, all others → `.X24.space`

### Task 7: Share suggestion service & sharing extension

**Files:**
- Modify: `Anytype/Sources/ServiceLayer/ShareSuggestionService/ShareSuggestionService.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SharingExtension/SharingExtensionViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SharingExtensionShareTo/SharingExtensionShareToViewModel.swift`

- [x] In `ShareSuggestionService`: replaced `switch spaceView.uxType` with `isOneToOne` checks in all 3 methods
- [x] `SharingExtensionViewModel`: already behind FeatureFlags.createChannelFlow with correct spaceType path — no change needed
- [x] `SharingExtensionShareToViewModel`: already behind FeatureFlags.createChannelFlow with correct spaceType path — no change needed

### Task 8: Chat header & view models

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/ChatHeader/ChatHeaderViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/ChatViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [x] In `ChatHeaderViewModel`: replaced `uxType.supportsMultiChats` → `!isOneToOne`, `uxType.isOneToOne` → `isOneToOne`
- [x] In `ChatViewModel` & `DiscussionViewModel`: replaced `spaceUxType` → `isOneToOneSpace`, `supportsMentions` → `!isOneToOneSpace`
- [x] Left `showsMessageAuthor` and `positionsYourMessageOnRight` in `ChatMessageBuilder` as-is (stream-specific)

### Task 9: Object menu & pin action

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Views/Settings/ObjectSettingsMenu/Models/ObjectMenuSectionType.swift`
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Views/Settings/ObjectSettings/ObjectSettingBuilder.swift`

- [x] In `ObjectMenuSectionType`: unified pin action to `.mainSettings` for all (removed `isChat` branching)
- [x] `ObjectSettingBuilder`: already has spaceType-based overload with correct `!= .oneToOne` check — no change needed

### Task 10: Navigation & space hub

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/SpaceHubViewModel.swift`

- [x] `SpaceHubCoordinatorViewModel`: left as-is — uses `spaceUxType` as parameter for join flow fallback, `spaceView?.isOneToOne` already handles main case
- [x] In `SpaceHubViewModel`: replaced `spaceView.uxType.isOneToOne` → `spaceView.isOneToOne` for mute toggle

### Task 11: Conversation empty state

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/ConversationEmptyStateView/ConversationEmptyStateView.swift`

- [x] Updated `chatEmptyStateView`: addMembers/qrCode buttons now nil for all non-stream spaces (regular and oneToOne don't need them)
- [x] Left `isStream` check as-is (stream-specific empty state)

### Task 12: Notification extension

**Files:**
- Modify: `AnytypeNotificationServiceExtension/NotificationService.swift`

- [x] `isOneToOne` already correct (checks `spaceUxType == .oneToOne`)
- [x] `supportsMultiChats` changed from `== .data` to `!isOneToOne`

### Task 13: Verify & clean up

- [x] Verified no remaining uxType behavioral branching in changed files (only intentional stream-specific and display-name refs remain)
- [x] Icon shape: regular=square, oneToOne=round (ObjectIconBuilder uses spaceTypeValue == .oneToOne)
- [x] Notification controls: regular=NotificationModeMenu, oneToOne=MuteToggle (via supportsMultiChats = !isOneToOne)
- [ ] Report changes to user for Xcode verification

## Post-Completion

**Manual verification:**
- Open app with spaces of different types (regular, oneToOne)
- Verify regular spaces show square icons, oneToOne shows round
- Verify space card context menus show NotificationModeMenu for regular, MuteToggle for oneToOne
- Verify message preview behavior on space cards
- Verify sharing extension behavior

**Follow-up tasks (out of scope):**
- Collapse `FeatureFlags.createChannelFlow` branches in ~24 service-layer files
- Migrate analytics `SpaceUxType` references
- Remove unused `SpaceUxType` extensions after full migration
