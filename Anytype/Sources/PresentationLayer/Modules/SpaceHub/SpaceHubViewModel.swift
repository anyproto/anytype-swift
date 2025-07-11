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
    
    var allSpaces: [ParticipantSpaceViewDataWithPreview]? {
        guard let unreadSpaces, let spaces else { return nil }
        return unreadSpaces + spaces
    }
    
    @Published var wallpapers: [String: SpaceWallpaperType] = [:]
    
    @Published var showSettings = false
    @Published var createSpaceAvailable = false
    @Published var notificationsDenied = false
    @Published var spaceIdToLeave: StringIdentifiable?
    @Published var spaceIdToDelete: StringIdentifiable?
    @Published var spaceMuteData: SpaceMuteData?
    @Published var toastBarData: ToastBarData?
    
    @Published var profileIcon: Icon?
    
    private weak var output: (any SpaceHubModuleOutput)?
    
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
    
    init(output: (any SpaceHubModuleOutput)?) {
        self.output = output
    }
    
    func onTapCreateSpace() {
        output?.onSelectCreateObject()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenVault(type: "General")
    }
    
    func onSpaceTap(spaceId: String) {
        if FeatureFlags.spaceLoadingForScreen {
            output?.onSelectSpace(spaceId: spaceId)
            UISelectionFeedbackGenerator().selectionChanged()
        } else {
            Task {
                try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
                UISelectionFeedbackGenerator().selectionChanged()
            }
        }
    }
    
    func deleteSpace(spaceId: String) async throws {
        spaceIdToDelete = spaceId.identifiable
    }
    
    func leaveSpace(spaceId: String) {
        spaceIdToLeave = spaceId.identifiable
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
