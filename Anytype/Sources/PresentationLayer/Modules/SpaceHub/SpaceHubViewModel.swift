import Services
import SwiftUI
@preconcurrency import Combine
import AnytypeCore
import AsyncAlgorithms
import Loc

@MainActor
final class SpaceHubViewModel: ObservableObject {
    @Published var unreadSpaces: [ParticipantSpaceViewDataWithPreview]?
    @Published var spaces: [ParticipantSpaceViewDataWithPreview]?
    @Published var searchText: String = ""
    
    var allSpaces: [ParticipantSpaceViewDataWithPreview]? {
        guard let unreadSpaces, let spaces else { return nil }
        return unreadSpaces + spaces
    }
    
    var filteredUnreadSpaces: [ParticipantSpaceViewDataWithPreview]? {
        guard !searchText.isEmpty, let unreadSpaces else { return unreadSpaces }
        return unreadSpaces.filter { space in
            space.spaceView.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var filteredSpaces: [ParticipantSpaceViewDataWithPreview]? {
        guard !searchText.isEmpty, let spaces else { return spaces }
        return spaces.filter { space in
            space.spaceView.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    @Published var wallpapers: [String: SpaceWallpaperType] = [:]
    
    @Published var createSpaceAvailable = false
    @Published var notificationsDenied = false
    @Published var spaceMuteData: SpaceMuteData?
    @Published var toastBarData: ToastBarData?
    @Published var showLoading = false
    @Published var profileIcon: Icon?
    @Published var showSettings = false
    @Published var spaceIdToLeave: StringIdentifiable?
    @Published var spaceIdToDelete: StringIdentifiable?
    
    private weak var output: (any SpaceHubModuleOutput)?
    private let showOnlyChats: Bool
    
    var showPlusInNavbar: Bool {
        guard let allSpaces else { return false }
        return allSpaces.count > 6 && createSpaceAvailable
    }
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.spaceOrderService)
    private var spaceOrderService: any SpaceOrderServiceProtocol
    @Injected(\.profileStorage)
    private var profileStorage: any ProfileStorageProtocol
    @Injected(\.spaceHubSpacesStorage)
    private var spaceHubSpacesStorage: any SpaceHubSpacesStorageProtocol
    @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    init(output: (any SpaceHubModuleOutput)?, showOnlyChats: Bool) {
        self.output = output
        self.showOnlyChats = showOnlyChats
    }
    
    func onTapSettings() {
        output?.onSelectAppSettings()
    }
    
    func onTapCreateSpace() {
        output?.onSelectCreateObject()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenVault(type: "General")
    }
    
    func onSpaceTap(spaceId: String, presentation: SpacePreferredPresentationMode?) {
        if FeatureFlags.spaceLoadingForScreen {
            output?.onSelectSpace(spaceId: spaceId, preferredPresentation: presentation)
            UISelectionFeedbackGenerator().selectionChanged()
        } else {
            Task {
                try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
                UISelectionFeedbackGenerator().selectionChanged()
            }
        }
    }
    
    
    func copySpaceInfo(spaceView: SpaceView) {
        UIPasteboard.general.string = String(describing: spaceView)
    }
    
    func muteSpace(spaceView: SpaceView) {
        let isUnmutedAll = spaceView.pushNotificationMode.isUnmutedAll
        spaceMuteData = SpaceMuteData(
            spaceId: spaceView.targetSpaceId,
            mode: isUnmutedAll ? .mentions : .all
        )
    }
    
    func pin(spaceView: SpaceView) async throws {
        guard let spaces else { return }
        let pinnedSpaces = spaces.filter { $0.spaceView.isPinned }
        
        let pinnedSpacesLimit = 6
        if pinnedSpaces.count >= pinnedSpacesLimit {
            toastBarData = ToastBarData(Loc.pinLimitReached(pinnedSpacesLimit), type: .failure)
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        var newOrder = pinnedSpaces.filter { $0.spaceView.id != spaceView.id }.map(\.spaceView.id)
        newOrder.insert(spaceView.id, at: 0)
        
        try await spaceOrderService.setOrder(spaceViewIdMoved: spaceView.id, newOrder: newOrder)
    }
    
    func unpin(spaceView: SpaceView) async throws {
        try await spaceOrderService.unsetOrder(spaceViewId: spaceView.id)
    }
    
    func openSpaceSettings(spaceId: String) {
        output?.onOpenSpaceSettings(spaceId: spaceId)
    }
    
    func leaveSpace(spaceId: String) {
        spaceIdToLeave = spaceId.identifiable
    }
    
    func deleteSpace(spaceId: String) async throws {
        spaceIdToDelete = spaceId.identifiable
    }
    
    func startSubscriptions() async {
        async let spacesSub: () = subscribeOnSpaces()
        async let wallpapersSub: () = subscribeOnWallpapers()
        async let profileSub: () = subscribeOnProfile()
        async let pushNotificationsSystemSettingsSub: () = pushNotificationsSystemSettingsSubscription()
    
        _ = await (spacesSub, wallpapersSub, profileSub, pushNotificationsSystemSettingsSub)
    }
    
    func pushNotificationSetSpaceMode(data: SpaceMuteData) async {
        try? await workspaceService.pushNotificationSetSpaceMode(
            spaceId: data.spaceId,
            mode: data.mode
        )
        AnytypeAnalytics.instance().logChangeMessageNotificationState(
            type: data.mode.analyticsValue,
            route: .vault
        )
        spaceMuteData = nil
    }
    
    // MARK: - Private
    private func subscribeOnSpaces() async {
        for await spaces in await spaceHubSpacesStorage.spacesStream {
            // todo change chatId check to uxType when fixed
            let spaces = showOnlyChats ? spaces.filter { $0.space.spaceView.uxType == .chat  } : spaces.filter { $0.space.spaceView.uxType == .data }
            
            if FeatureFlags.pinnedSpaces {
                self.spaces = spaces.sorted(by: sortSpacesForPinnedFeature)
                self.unreadSpaces = []
            } else {
                self.unreadSpaces = spaces
                    .filter { $0.preview.unreadCounter > 0 }
                    .sorted {
                        ($0.preview.lastMessage?.createdAt ?? Date.distantPast) > ($1.preview.lastMessage?.createdAt ?? Date.distantPast)
                    }
                self.spaces = spaces.filter { $0.preview.unreadCounter == 0 }
            }
            createSpaceAvailable = workspacesStorage.canCreateNewSpace()
            if FeatureFlags.spaceLoadingForScreen {
                showLoading = spaces.contains { $0.spaceView.isLoading }
            }
        }
    }
    
    private func sortSpacesForPinnedFeature(_ lhs: ParticipantSpaceViewDataWithPreview, _ rhs: ParticipantSpaceViewDataWithPreview) -> Bool {
        switch (lhs.spaceView.isPinned, rhs.spaceView.isPinned) {
        case (true, true):
            return lhs.spaceView.spaceOrder < rhs.spaceView.spaceOrder
        case (true, false):
            return true
        case (false, true):
            return false
        case (false, false):
            let lhsMessageDate = lhs.preview.lastMessage?.createdAt
            let rhsMessageDate = rhs.preview.lastMessage?.createdAt
            
            switch (lhsMessageDate, rhsMessageDate) {
            case let (date1?, date2?):
                return date1 > date2
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                let lhsCreatedDate = lhs.spaceView.createdDate ?? .distantPast
                let rhsCreatedDate = rhs.spaceView.createdDate ?? .distantPast
                return lhsCreatedDate > rhsCreatedDate
            }
        }
    }
    
    private func subscribeOnWallpapers() async {
        for await wallpapers in userDefaults.wallpapersPublisher().values {
            self.wallpapers = wallpapers
        }
    }
    
    private func subscribeOnProfile() async {
        for await profile in profileStorage.profilePublisher.values {
            profileIcon = profile.icon
        }
    }
    
    private func pushNotificationsSystemSettingsSubscription() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            notificationsDenied = status.isDenied
        }
    }
}
