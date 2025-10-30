import Services
import SwiftUI
@preconcurrency import Combine
import AnytypeCore
import AsyncAlgorithms
import Loc

@MainActor
@Observable
final class SpaceHubViewModel {
    
    var spaces: [ParticipantSpaceViewDataWithPreview]?
    var dataLoaded = false
    var searchText: String = ""
    var filteredSpaces: [SpaceCardModel] = []
    
    var wallpapers: [String: SpaceWallpaperType] = [:]
    
    var notificationsDenied = false
    var spaceMuteData: SpaceMuteData?
    var showLoading = false
    var profileIcon: Icon?
    var spaceToDelete: StringIdentifiable?
    
    @ObservationIgnored
    private weak var output: (any SpaceHubModuleOutput)?

    @Injected(\.userDefaultsStorage) @ObservationIgnored
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var workspacesStorage: any SpaceViewsStorageProtocol
    @Injected(\.spaceOrderService) @ObservationIgnored
    private var spaceOrderService: any SpaceOrderServiceProtocol
    @Injected(\.profileStorage) @ObservationIgnored
    private var profileStorage: any ProfileStorageProtocol
    @Injected(\.spaceHubSpacesStorage) @ObservationIgnored
    private var spaceHubSpacesStorage: any SpaceHubSpacesStorageProtocol
    @Injected(\.pushNotificationsSystemSettingsBroadcaster) @ObservationIgnored
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    @Injected(\.workspaceService) @ObservationIgnored
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.spaceCardModelBuilder)@ObservationIgnored
    private var spaceCardModelBuilder: any SpaceCardModelBuilderProtocol
    
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
    
    
    func copySpaceInfo(spaceViewId: String) {
        guard let spaceView = spaces?.first(where: { $0.spaceView.id == spaceViewId })?.spaceView else { return }
        UIPasteboard.general.string = String(describing: spaceView)
    }
    
    func muteSpace(spaceViewId: String) {
        guard let spaceView = spaces?.first(where: { $0.spaceView.id == spaceViewId })?.spaceView else { return }
        let isUnmutedAll = spaceView.pushNotificationMode.isUnmutedAll
        spaceMuteData = SpaceMuteData(
            spaceId: spaceView.targetSpaceId,
            mode: isUnmutedAll ? .mentions : .all
        )
    }
    
    func pin(spaceViewId: String) async throws {
        guard let spaces else { return }
        let pinnedSpaces = spaces.filter { $0.spaceView.isPinned }
        
        var newOrder = pinnedSpaces.filter { $0.spaceView.id != spaceViewId }.map(\.spaceView.id)
        newOrder.insert(spaceViewId, at: 0)

        try await spaceOrderService.setOrder(spaceViewIdMoved: spaceViewId, newOrder: newOrder)
        AnytypeAnalytics.instance().logPinSpace()
    }
    
    func unpin(spaceViewId: String) async throws {
        try await spaceOrderService.unsetOrder(spaceViewId: spaceViewId)
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
    
    func searchTextUpdated() {
        updateFilteredSpaces()
    }
    
    // MARK: - Private
    private func subscribeOnSpaces() async {
        for await spaces in await spaceHubSpacesStorage.spacesStream {
            self.spaces = spaces.sorted(by: sortSpacesForPinnedFeature)
            self.dataLoaded = spaces.isNotEmpty
            showLoading = spaces.contains { $0.spaceView.isLoading }
            updateFilteredSpaces()
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
    
    private func updateFilteredSpaces() {
        Task {
            guard let spaces else {
                filteredSpaces = []
                return
            }
            
            let spacesToFilter: [ParticipantSpaceViewDataWithPreview]
            if searchText.isEmpty {
                spacesToFilter = spaces
            } else {
                spacesToFilter = spaces.filter { space in
                    space.spaceView.name.localizedCaseInsensitiveContains(searchText)
                }
            }
            
            self.filteredSpaces = await spaceCardModelBuilder.build(from: spacesToFilter, wallpapers: wallpapers)
        }
    }
}
