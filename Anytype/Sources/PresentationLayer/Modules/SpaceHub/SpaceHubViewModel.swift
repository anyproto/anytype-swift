import Services
import SwiftUI
import Combine


@MainActor
final class SpaceHubViewModel: ObservableObject, SpaceCreateModuleOutput {
    @Published var spaces: [ParticipantSpaceViewData]?
    @Published var wallpapers: [String: SpaceWallpaperType] = [:]
    
    @Published var showSpaceCreate = false
    @Published var showSettings = false
    
    let sceneId: String
    
    var showPlusInNavbar: Bool {
        guard let spaces else { return false }
        return spaces.count > 6
    }
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    private var subscriptions = [AnyCancellable]()
    
    
    init(sceneId: String) {
        self.sceneId = sceneId
        Task { startSubscriptions() }
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
    
    // MARK: - Private
    private func startSubscriptions() {
        participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher
            .receiveOnMain()
            .sink { [weak self] spaces in
                guard let self else { return }
                
                self.spaces = spaces
            }
            .store(in: &subscriptions)
        
        userDefaults.wallpapersPublisher().receiveOnMain().assign(to: &$wallpapers)
    }
}
