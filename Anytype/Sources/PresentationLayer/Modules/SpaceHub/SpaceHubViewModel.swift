import Services
import SwiftUI
import Combine
import AnytypeCore


@MainActor
final class SpaceHubViewModel: ObservableObject {
    @Published var spaces: [ParticipantSpaceViewData]?
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
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.spaceOrderService)
    private var spaceOrderService: any SpaceOrderServiceProtocol
    @Injected(\.profileStorage)
    private var profileStorage: any ProfileStorageProtocol
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    
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
        async let messagesPreviewsSub: () = subscribeOnMessagesPreviews()
        
        (_, _, _, _) = await (spacesSub, wallpapersSub, profileSub, messagesPreviewsSub)
    }
    
    // MARK: - Private
    private func subscribeOnSpaces() async {
        for await spaces in participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values {
            let previews = await chatMessagesPreviewsStorage.previews()
            updateSpaces(spaces, previews: previews)
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
    
    private func subscribeOnMessagesPreviews() async {
        guard FeatureFlags.countersOnSpaceHub else { return }
        
        await chatMessagesPreviewsStorage.startSubscriptionIfNeeded()
        for await preview in chatMessagesPreviewsStorage.previewStream {
            updateSpaces(spaces, previews: [preview])
        }
    }
    
    private func updateSpaces(_ spaces: [ParticipantSpaceViewData]?, previews: [ChatMessagePreview]) {
        let enrichedSpaces = enrichSpaces(spaces, previews: previews)
        self.spaces = enrichedSpaces
    }
    
    private func enrichSpaces(_ spaces: [ParticipantSpaceViewData]?, previews: [ChatMessagePreview]) -> [ParticipantSpaceViewData]? {
        guard var spaces else { return nil }
        
        for preview in previews {
            if let spaceIndex = spaces.firstIndex(where: { $0.spaceView.targetSpaceId == preview.spaceId }) {
                spaces[spaceIndex] = spaces[spaceIndex].updateUnreadMessagesCount(preview.counter)
            }
        }
        
        return spaces
    }
}
