import Services
import SwiftUI
@preconcurrency import Combine
import AnytypeCore
import AsyncAlgorithms

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
    
    func startSubscriptions() async {
        async let spacesSub: () = subscribeOnSpaces()
        async let wallpapersSub: () = subscribeOnWallpapers()
        async let profileSub: () = subscribeOnProfile()
        async let pushNotificationsSystemSettingsSub: () = pushNotificationsSystemSettingsSubscription()
    
        _ = await (spacesSub, wallpapersSub, profileSub, pushNotificationsSystemSettingsSub)
    }
    
    // MARK: - Private
    private func subscribeOnSpaces() async {
        for await spaces in await spaceHubSpacesStorage.spacesStream {
            if FeatureFlags.unreadOnHome {
                self.unreadSpaces = spaces
                    .filter { $0.preview.unreadCounter > 0 }
                    .sorted {
                        ($0.preview.lastMessage?.createdAt ?? Date.distantPast) > ($1.preview.lastMessage?.createdAt ?? Date.distantPast)
                    }
                self.spaces = spaces.filter { $0.preview.unreadCounter == 0 }
            } else {
                self.unreadSpaces = []
                self.spaces = spaces
            }
            createSpaceAvailable = workspacesStorage.canCreateNewSpace()
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
