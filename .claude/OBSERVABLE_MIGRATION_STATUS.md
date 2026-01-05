# @Observable Migration Status

**Task**: IOS-5635
**Last Updated**: 2025-12-30
**Total ViewModels Migrated**: 131
**Remaining ViewModels**: 70

---

## Overview

Migration from `ObservableObject` protocol + `@Published` to Swift's `@Observable` macro (iOS 17+).

## Completed PRs

| PR | Title | ViewModels Migrated |
|----|-------|---------------------|
| [#4403](https://github.com/anyproto/anytype-swift/pull/4403) | Migrate Settings ViewModels | 11 |
| [#4405](https://github.com/anyproto/anytype-swift/pull/4405) | Migrate batch 2 | 15 |
| [#4406](https://github.com/anyproto/anytype-swift/pull/4406) | Migrate batch 3 (Auth + misc) | 15 |
| [#4407](https://github.com/anyproto/anytype-swift/pull/4407) | Migrate batch 4 | 11 |
| [#4412](https://github.com/anyproto/anytype-swift/pull/4412) | Migrate Membership + PushNotifications (batch 5) | 9 |
| [#4417](https://github.com/anyproto/anytype-swift/pull/4417) | Migrate 7 notification ViewModels (batch 6) | 7 |
| [#4418](https://github.com/anyproto/anytype-swift/pull/4418) | Migrate 27 ViewModels (batch 7) | 20 |

**All PRs are MERGED to develop.**

### In Progress (Current Branch)
| Branch | Title | ViewModels Migrated |
|--------|-------|---------------------|
| ios-5635-migrate-to-observable | Migrate batch 11 | 8 |

---

## Migrated ViewModels (131 total)

### PR #4403 - Settings (11 files)
- [x] SettingsViewModel.swift
- [x] SettingsCoordinatorViewModel.swift
- [x] SettingsAppearanceViewModel.swift
- [x] AboutViewModel.swift
- [x] FileStorageViewModel.swift
- [x] KeychainPhraseViewModel.swift
- [x] ProfileQRCodeViewModel.swift
- [x] PublishedSitesViewModel.swift
- [x] PushNotificationsSettingsViewModel.swift
- [x] WallpaperPickerViewModel.swift
- [x] RemoteStorageViewModel.swift

### PR #4405 - Settings/Space Settings (15 files)
- [x] SpaceSettingsCoordinatorViewModel.swift
- [x] SpaceNotificationsSettingsViewModel.swift
- [x] PersonalizationViewModel.swift
- [x] DisabledPushNotificationsBannerViewModel.swift
- [x] SpaceProfileViewModel.swift
- [x] SpaceSettingsViewModel.swift
- [x] SpaceLeaveAlertModel.swift
- [x] ObjectCoverPickerViewModel.swift
- [x] VersionHistoryViewModel.swift
- [x] LocalObjectIconPickerViewModel.swift
- [x] ObjectIconPickerViewModel.swift
- [x] SpaceObjectIconPickerViewModel.swift
- [x] TextIconPickerViewModel.swift
- [x] ObjectLayoutPickerViewModel.swift
- [x] TypePropertiesViewModel.swift

### PR #4406 - Auth & Misc (15 files)
- [x] AuthCoordinatorViewModel.swift
- [x] DeletedAccountViewModel.swift
- [x] JoinCoordinatorViewModel.swift
- [x] EmailCollectionViewModel.swift
- [x] JoinSelectionViewModel.swift
- [x] JoinViewModel.swift
- [x] KeyPhraseViewModel.swift
- [x] LoginCoordinatorViewModel.swift
- [x] LoginViewModel.swift
- [x] PrimaryAuthViewModel.swift
- [x] QrCodeViewModel.swift
- [x] InitialCoordinatorViewModel.swift
- [x] MigrationCoordinatorViewModel.swift
- [x] MigrationViewModel.swift
- [x] SecureAlertViewModel.swift

### PR #4407 - Misc (11 files)
- [x] ChatCreateObjectCoordinatorViewModel.swift
- [x] TypeSearchForNewObjectCoordinatorViewModel.swift
- [x] ChatHeaderViewModel.swift
- [x] CreateObjectTypeViewModel.swift
- [x] HomeBottomNavigationPanelViewModel.swift
- [x] ProfileViewModel.swift
- [x] SpaceCreateViewModel.swift
- [x] WidgetTypeChangeViewModel.swift
- [x] NotificationCoordinatorViewModel.swift
- [x] ObjectTypeSearchViewModel.swift

### PR #4412 - Membership & PushNotifications (9 files)
- [x] DisabledPushNotificationsAlertViewModel.swift
- [x] MembershipCoordinatorModel.swift
- [x] MembershipNameFinalizationViewModel.swift
- [x] MembershipTierViewModel.swift
- [x] MembershipTierSelectionViewModel.swift
- [x] MembershipNameSheetViewModel.swift
- [x] MembershipOwnerInfoSheetViewModel.swift
- [x] MembershipNameValidationViewModel.swift
- [x] PushNotificationsAlertViewModel.swift

### PR #4417 - Notifications (7 files)
- [x] GalleryInstallationCoordinatorViewModel.swift
- [x] ParticipantApproveNotificationViewModel.swift
- [x] ParticipantDeclineNotificationViewModel.swift
- [x] PermissionChangeNotificationViewModel.swift
- [x] ParticipantRemoveNotificationViewModel.swift
- [x] RequestToJoinNotificationViewModel.swift
- [x] RequestToLeaveNotificationViewModel.swift

### PR #4418 - Misc Batch (20 files)
- [x] TextPropertyEditingViewModel.swift
- [x] LinkToObjectSearchViewModel.swift
- [x] ObjectSearchWithMetaCoordinatorViewModel.swift
- [x] EditorPageCoordinatorViewModel.swift
- [x] SharingExtensionCoordinatorViewModel.swift
- [x] SpaceLoadingContainerViewModel.swift
- [x] SpaceShareCoordinatorViewModel.swift
- [x] CodeLanguageListViewModel.swift
- [x] ExperimentalFeaturesViewModel.swift
- [x] GallerySpaceSelectionViewModel.swift
- [x] HomeWallpaperViewModel.swift
- [x] ObjectTypeDeleteConfirmationAlertViewModel.swift
- [x] MessageParticipantsReactionViewModel.swift
- [x] MessageReactionPickerViewModel.swift
- [x] SharingTipViewModel.swift
- [x] ChatCreationTipViewModel.swift
- [x] SpaceJoinViewModel.swift
- [x] SpaceTypeChangeViewModel.swift
- [x] ObjectTypeInfoViewModel.swift
- [x] UndoRedoViewModel.swift

### Batch 8 - Search + Properties (16 files)
- [x] GlobalSearchViewModel.swift
- [x] ObjectSearchWithMetaViewModel.swift
- [x] SimpleSearchListViewModel.swift
- [x] LegacySearchViewModel.swift
- [x] ObjectPreviewViewModel.swift
- [x] ObjectPropertiesViewModel.swift
- [x] ObjectPropertiesLibraryViewModel.swift
- [x] PropertiesListCoordinatorViewModel.swift
- [x] PropertyCreationViewModel.swift
- [x] PropertyOptionSettingsViewModel.swift
- [x] PropertyInfoViewModel.swift
- [x] PropertyCalendarViewModel.swift
- [x] PropertyFormatsListViewModel.swift
- [x] SelectPropertyListViewModel.swift
- [x] ObjectPropertyListViewModel.swift
- [x] FlowPropertiesViewModel.swift

### Batch 9 - Coordinator ViewModels (10 files)
- [x] DateCoordinatorViewModel.swift
- [x] ObjectSettingsCoordinatorViewModel.swift
- [x] ServerConfigurationCoordinatorViewModel.swift
- [x] PropertyCalendarCoordinatorViewModel.swift
- [x] ObjectPropertyListCoordinatorViewModel.swift
- [x] SelectPropertyListCoordinatorViewModel.swift
- [x] PropertyInfoCoordinatorViewModel.swift
- [x] VersionHistoryCoordinatorViewModel.swift
- [x] SpaceCreateCoordinatorViewModel.swift
- [x] PropertyValueCoordinatorViewModel.swift

### Batch 10 - Mixed ViewModels (9 files)
- [x] EditorCoordinatorViewModel.swift
- [x] EditorSetCoordinatorViewModel.swift
- [x] DateViewModel.swift
- [x] GalleryInstallationPreviewViewModel.swift
- [x] SpaceMembersViewModel.swift
- [x] SpacesManagerViewModel.swift
- [x] PublishToWebViewModel.swift
- [x] WidgetsHeaderViewModel.swift
- [x] LinkWidgetViewModel.swift

### Batch 11 - HomeWidgets + Misc (8 files)
- [x] WidgetContainerViewModel.swift
- [x] BinLinkWidgetViewModel.swift
- [x] HomeUpdateSubmoduleViewModel.swift
- [x] ServerDocumentPickerViewModel.swift
- [x] EmbedContentViewModel.swift
- [x] GalleryNotificationViewModel.swift
- [x] SharingExtensionViewModel.swift
- [x] SharingExtensionShareToViewModel.swift

---

## Remaining ViewModels (70 total)

### Simple Migrations (No complex Combine patterns)

These can be migrated with the standard pattern:

#### HomeWidgets (5 files)
- [ ] TreeWidgetViewModel.swift
- [ ] ListWidgetViewModel.swift
- [ ] ObjectWidgetInternalViewModel.swift
- [ ] PinnedWidgetInternalViewModel.swift ⚠️ has .eraseToAnyPublisher()
- [ ] RecentWidgetInternalViewModel.swift ⚠️ has .eraseToAnyPublisher()

#### Set/Collection (17 files)
- [ ] EditorSetViewModel.swift
- [ ] SetViewPickerViewModel.swift
- [ ] SetViewPickerCoordinatorViewModel.swift
- [ ] ObjectTypeTemplatePickerViewModel.swift
- [ ] SetFiltersListViewModel.swift
- [ ] SetFiltersListCoordinatorViewModel.swift
- [ ] SetFiltersTextViewModel.swift
- [ ] SetFiltersCheckboxViewModel.swift
- [ ] SetFiltersDateViewModel.swift
- [ ] SetFiltersDateCoordinatorViewModel.swift
- [ ] SetFiltersSelectionViewModel.swift
- [ ] SetFiltersSelectionHeaderViewModel.swift
- [ ] SetFiltersSelectionCoordinatorViewModel.swift
- [ ] SetSortsListViewModel.swift
- [ ] SetSortsListCoordinatorViewModel.swift
- [ ] SetSortTypesListViewModel.swift
- [ ] SetPropertiesViewModel.swift
- [ ] SetPropertiesCoordinatorViewModel.swift
- [ ] SetHeaderSettingsViewModel.swift
- [ ] SetKanbanColumnSettingsViewModel.swift
- [ ] SetLayoutSettingsViewModel.swift
- [ ] SetLayoutSettingsCoordinatorViewModel.swift
- [ ] SetViewSettingsCoordinatorViewModel.swift
- [ ] SetViewSettingsImagePreviewViewModel.swift
- [ ] SetObjectCreationSettingsViewModel.swift

#### TextEditor (7 files)
- [ ] EditorPageViewModel.swift (LARGE - complex)
- [ ] ObjectHeaderViewModel.swift
- [ ] SlashMenuViewModel.swift
- [ ] MarkupAccessoryViewModel.swift
- [ ] SelectionOptionsViewModel.swift
- [ ] HorizonalTypeListViewModel.swift
- [ ] GridItemViewModel.swift

#### Misc Modules (9 files)
- [ ] BinListViewModel.swift
- [ ] WidgetObjectListViewModel.swift
- [ ] TemplatePickerViewModel.swift
- [ ] PublishToWebInternalViewModel.swift
- [ ] ServerConfigurationViewModel.swift
- [ ] SyncStatusInfoViewModel.swift
- [ ] FileDownloadingViewModel.swift
- [ ] DebugMenuViewModel.swift
- [ ] PublicDebugMenuViewModel.swift

#### UIKit-based (2 files)
- [ ] AnytypeAlertViewModel.swift
- [ ] AnytypePopupViewModel.swift

### Deferred (Special Handling Required)

#### EmailVerificationViewModel.swift
- Has `@Binding private var email: String` which doesn't work with `@Observable`
- Need alternative pattern: closure-based or passing parent Observable

---

## Migration Patterns

### Pattern 1: Basic ViewModel

**Before:**
```swift
import Combine

@MainActor
final class MyViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var isLoading = false
}
```

**After:**
```swift
@MainActor
@Observable
final class MyViewModel {
    var name: String = ""
    var isLoading = false
}
```

### Pattern 2: @StateObject → @State

**Before:**
```swift
struct MyView: View {
    @StateObject private var model: MyViewModel

    init(data: MyData) {
        _model = StateObject(wrappedValue: MyViewModel(data: data))
    }
}
```

**After:**
```swift
struct MyView: View {
    @State private var model: MyViewModel

    init(data: MyData) {
        _model = State(initialValue: MyViewModel(data: data))
    }
}
```

### Pattern 3: @Injected Dependencies

**After:**
```swift
@Observable
final class MyViewModel {
    @ObservationIgnored
    @Injected(\.myService)
    private var myService: any MyServiceProtocol
}
```

### Pattern 4: Excluding from Observation

**After:**
```swift
@Observable
final class MyViewModel {
    @ObservationIgnored
    private var task: Task<Void, Never>?

    @ObservationIgnored
    private var subscriptions: [AnyCancellable] = []
}
```

### Pattern 5: @Published with didSet (Still Works!)

**After:**
```swift
@Observable
final class MyViewModel {
    var errorText: String? {
        didSet { showError = errorText.isNotNil }
    }
}
```

### Pattern 6: $property Combine → onChange + Task

**Before:**
```swift
$profileName
    .delay(for: 0.3, scheduler: DispatchQueue.main)
    .sink { [weak self] name in
        self?.updateName(name: name)
    }
    .store(in: &subscriptions)
```

**After (View):**
```swift
.onChange(of: model.profileName) {
    model.onProfileNameChange()
}
```

**After (ViewModel):**
```swift
@ObservationIgnored
private var debounceTask: Task<Void, Never>?

func onProfileNameChange() {
    debounceTask?.cancel()
    debounceTask = Task { [weak self] in
        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled, let self else { return }
        await updateName(name: profileName)
    }
}
```

---

## Files NOT to Migrate (Services)

Keep these as `ObservableObject` - they expose `$property` publishers:
- `ApplicationStateService.swift`
- `MembershipStatusStorage.swift`
- `FileLimitsStorage.swift`
- `ObjectTypeProvider.swift`

---

## Quick Commands

### Find remaining ViewModels with ObservableObject
```bash
rg "ObservableObject" --glob "*ViewModel.swift" -l
```

### Count remaining
```bash
rg "ObservableObject" --glob "*ViewModel.swift" -l | wc -l
```

### Find ViewModels with complex Combine (skip these initially)
```bash
rg "\.assign\(to:|\.eraseToAnyPublisher\(\)|AnyCancellable" --glob "*ViewModel.swift" -l
```

---

## Sources

- [Apple: Migrating from ObservableObject to Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- [Jesse Squires: @Observable is not a drop-in replacement](https://www.jessesquires.com/blog/2024/09/09/swift-observable-macro/)
- [Use Your Loaf: Migrating to Observable](https://useyourloaf.com/blog/migrating-to-observable/)
