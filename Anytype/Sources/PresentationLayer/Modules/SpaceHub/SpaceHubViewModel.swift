import Services
import SwiftUI
@preconcurrency import Combine
import AnytypeCore
import AsyncAlgorithms
import Loc

@MainActor
final class SpaceHubViewModel: ObservableObject {
    @Published var spaces: [ParticipantSpaceViewDataWithPreview]?
    @Published var searchText: String = ""
    
    var filteredSpaces: [ParticipantSpaceViewDataWithPreview] {
        guard let spaces else { return [] }
        guard !searchText.isEmpty else { return spaces }
        
        return spaces.filter { space in
            space.spaceView.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    @Published var wallpapers: [String: SpaceWallpaperType] = [:]
    
    @Published var notificationsDenied = false
    @Published var spaceMuteData: SpaceMuteData?
    @Published var showLoading = false
    @Published var profileIcon: Icon?
    @Published var spaceToDelete: StringIdentifiable?
    
    private weak var output: (any SpaceHubModuleOutput)?
    

    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
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
    
    func onTapSettings() {
        output?.onSelectAppSettings()
    }
    
    func onTapCreateSpace() {
        output?.onSelectCreateObject()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenVault(type: "General")
    }
    
    func onSpaceTap(spaceId: String) {
        output?.onSelectSpace(spaceId: spaceId)
        UISelectionFeedbackGenerator().selectionChanged()
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

        var newOrder = pinnedSpaces.filter { $0.spaceView.id != spaceView.id }.map(\.spaceView.id)
        newOrder.insert(spaceView.id, at: 0)

        try await spaceOrderService.setOrder(spaceViewIdMoved: spaceView.id, newOrder: newOrder)
        AnytypeAnalytics.instance().logPinSpace()
    }
    
    func unpin(spaceView: SpaceView) async throws {
        try await spaceOrderService.unsetOrder(spaceViewId: spaceView.id)
        AnytypeAnalytics.instance().logUnpinSpace()
    }
    
    func openSpaceSettings(spaceId: String) {
        output?.onOpenSpaceSettings(spaceId: spaceId)
    }
    
    func onDeleteSpace(spaceId: String) {
        spaceToDelete = spaceId.identifiable
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
            self.spaces = spaces.sorted(by: sortSpacesForPinnedFeature)
            showLoading = spaces.contains { $0.spaceView.isLoading }
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
            let lhsJoinDate = lhs.spaceView.joinDate
            let rhsJoinDate = rhs.spaceView.joinDate
            
            // Determine effective date for lhs (use joinDate if no message, or more recent of the two)
            let lhsEffectiveDate: Date? = {
                switch (lhsMessageDate, lhsJoinDate) {
                case let (messageDate?, joinDate?):
                    return max(messageDate, joinDate)
                case (let messageDate?, nil):
                    return messageDate
                case (nil, let joinDate?):
                    return joinDate
                case (nil, nil):
                    return nil
                }
            }()
            
            // Determine effective date for rhs (use joinDate if no message, or more recent of the two)
            let rhsEffectiveDate: Date? = {
                switch (rhsMessageDate, rhsJoinDate) {
                case let (messageDate?, joinDate?):
                    return max(messageDate, joinDate)
                case (let messageDate?, nil):
                    return messageDate
                case (nil, let joinDate?):
                    return joinDate
                case (nil, nil):
                    return nil
                }
            }()
            
            switch (lhsEffectiveDate, rhsEffectiveDate) {
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
