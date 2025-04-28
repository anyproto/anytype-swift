import Services
import SwiftUI
@preconcurrency import Combine
import AnytypeCore
import AsyncAlgorithms

@MainActor
final class SpaceHubViewModel: ObservableObject {
    @Published var spaces: [ParticipantSpaceViewDataWithPreview]?
    @Published var wallpapers: [String: SpaceWallpaperType] = [:]
    
    @Published var showSettings = false
    @Published var createSpaceAvailable = false
    @Published var spaceIdToLeave: StringIdentifiable?
    @Published var spaceIdToDelete: StringIdentifiable?
    
    @Published var profileIcon: Icon?
    
    private weak var output: (any SpaceHubModuleOutput)?
    
    var showPlusInNavbar: Bool {
        guard let spaces else { return false }
        return spaces.count > 6 && createSpaceAvailable
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
        for await spaces in await spaceHubSpacesStorage.spacesStream {
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
