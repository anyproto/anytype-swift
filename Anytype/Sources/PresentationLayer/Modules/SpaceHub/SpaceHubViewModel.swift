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
    var animationsEnabled = false

    var wallpapers: [String: SpaceWallpaperType] = [:]

    @ObservationIgnored
    private var allSpaceCardModels: [SpaceCardModel] = []

    var notificationsNotDetermined = false
    var spaceMuteData: SpaceMuteData?
    var profileIcon: Icon?
    var spaceToDelete: StringIdentifiable?
    var spaceToLeave: StringIdentifiable?
    
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
    @Injected(\.spaceCardModelBuilder) @ObservationIgnored
    private var spaceCardModelBuilder: any SpaceCardModelBuilderProtocol

    init(output: (any SpaceHubModuleOutput)?) {
        self.output = output
    }
    
    func onTapSettings() {
        output?.onSelectAppSettings()
    }

    func onTapQuickCapture() {
        output?.onSelectQuickCapture()
    }

    func onSearchTap() {
        output?.onSelectSearch()
    }

    func onTapCreatePersonalChannel() {
        AnytypeAnalytics.instance().logClickVaultCreateMenuSpace()
        output?.onSelectCreatePersonalChannel()
    }

    func onTapCreateGroupChannel() {
        AnytypeAnalytics.instance().logClickVaultCreateMenuChat()
        output?.onSelectCreateGroupChannel()
    }

    func onTapJoinViaQrCode() {
        AnytypeAnalytics.instance().logClickVaultCreateMenuJoin()
        output?.onSelectQrCodeJoin()
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
        spaceMuteData = SpaceMuteData(
            spaceId: spaceView.targetSpaceId,
            mode: spaceView.pushNotificationMode.toggled(isOneToOne: spaceView.isOneToOne)
        )
    }

    func setSpaceNotificationMode(spaceViewId: String, mode: SpacePushNotificationsMode) {
        guard let spaceView = spaces?.first(where: { $0.spaceView.id == spaceViewId })?.spaceView else { return }
        spaceMuteData = SpaceMuteData(
            spaceId: spaceView.targetSpaceId,
            mode: mode
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

    func onLeaveSpace(spaceId: String) {
        spaceToLeave = spaceId.identifiable
    }
    
    func startSubscriptions() async {
        async let spacesSub: () = subscribeOnSpaces()
        async let wallpapersSub: () = subscribeOnWallpapers()
        async let profileSub: () = subscribeOnProfile()
        async let notificationsSub: () = notificationsStatusSubscription()

        _ = await (spacesSub, wallpapersSub, profileSub, notificationsSub)
    }
    
    func pushNotificationSetSpaceMode(data: SpaceMuteData) async {
        try? await workspaceService.pushNotificationSetSpaceMode(
            spaceId: data.spaceId,
            mode: data.mode
        )
        AnytypeAnalytics.instance().logChangeMessageNotificationState(
            type: data.mode.analyticsValue,
            route: .vault,
            uxType: .space
        )
        spaceMuteData = nil
    }
    
    func searchTextUpdated() {
        if searchText.isEmpty {
            filteredSpaces = allSpaceCardModels
        }
        Task {
            await updateFilteredSpaces()
        }
    }
    
    // MARK: - Private
    private func subscribeOnSpaces() async {
        for await spaces in await spaceHubSpacesStorage.spacesStream {
            self.spaces = spaces.sortedForSpaceHub()
            await updateFilteredSpaces()
            self.dataLoaded = true
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

    private func notificationsStatusSubscription() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            notificationsNotDetermined = status.isNotDetermined
        }
    }

    private func updateFilteredSpaces() async {
        guard let spaces else {
            filteredSpaces = []
            allSpaceCardModels = []
            return
        }

        let spacesToFilter: [ParticipantSpaceViewDataWithPreview]
        if searchText.isEmpty {
            spacesToFilter = spaces
        } else {
            spacesToFilter = spaces.filter { space in
                space.spaceView.name.localizedStandardContains(searchText)
            }
        }

        let models = await spaceCardModelBuilder.build(from: spacesToFilter, wallpapers: wallpapers)

        if searchText.isEmpty {
            allSpaceCardModels = models
        }

        self.filteredSpaces = models
    }
}
