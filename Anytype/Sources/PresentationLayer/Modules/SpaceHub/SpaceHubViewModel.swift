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
    
    private var subscriptions = [AnyCancellable]()
    
    
    init(sceneId: String) {
        self.sceneId = sceneId
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenVault(type: "General")
        if #available(iOS 17.0, *) {
            SpaceHubTip.didShowSpaceHub = true
        }
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
    
    func deleteSpace(spaceId: String) {
        Task {
            try await workspaceService.deleteSpace(spaceId: spaceId)
        }
    }
    
    func copySpaceInfo(spaceView: SpaceView) {
        UIPasteboard.general.string = String(describing: spaceView)
    }
    
    func startSubscriptions() async {
        async let spacesSub: () = subscribeOnSpaces()
        async let wallpapersSub: () = subscribeOnWallpapers()
        
        (_, _) = await (spacesSub, wallpapersSub)
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
}
