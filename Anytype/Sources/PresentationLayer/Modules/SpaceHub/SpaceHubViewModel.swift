import Services
import SwiftUI
import Combine


@MainActor
final class SpaceHubViewModel: ObservableObject, SpaceCreateModuleOutput {
    @Published var spaces: [ParticipantSpaceViewData]?
    @Published var wallpapers: [String: SpaceWallpaperType] = [:]
    
    @Published var showSpaceCreate = false
    @Published var showSettings = false
    @Published var createSpaceAvailable = false
    @Published var spaceIdToLeave: StringIdentifiable?
    
    @Published var profileIcon: Icon?
    
    let sceneId: String
    
    var showPlusInNavbar: Bool {
        guard let spaces else { return false }
        return spaces.count > 6 && createSpaceAvailable
    }
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.spaceOrderService)
    private var spaceOrderService: any SpaceOrderServiceProtocol
    @Injected(\.profileStorage)
    private var profileStorage: any ProfileStorageProtocol
    
    init(sceneId: String) {
        self.sceneId = sceneId
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenVault(type: "General")
    }
    
    func onSpaceTap(spaceId: String) {
        Task {
            try await spaceSetupManager.setActiveSpace(sceneId: sceneId, spaceId: spaceId)
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    func spaceCreateWillDismiss() {
        showSpaceCreate = false

    }
    
    func deleteSpace(spaceId: String) async throws {
        try await workspaceService.deleteSpace(spaceId: spaceId)
    }
    
    func leaveSpace(spaceId: String) {
        spaceIdToLeave = spaceId.identifiable
    }
    
    func copySpaceInfo(spaceView: SpaceView) {
        UIPasteboard.general.string = String(describing: spaceView)
    }
    
    func pin(spaceView: SpaceView) async throws {
        guard let spaces else { return }
        var newOrder = spaces.filter { $0.spaceView.id != spaceView.id && $0.spaceView.isPinned }.map(\.spaceView.id)
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
        
        (_, _, _) = await (spacesSub, wallpapersSub, profileSub)
    }
    
    // MARK: - Private
    private func subscribeOnSpaces() async {
        for await spaces in participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values {
            self.spaces = spaces
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
}
