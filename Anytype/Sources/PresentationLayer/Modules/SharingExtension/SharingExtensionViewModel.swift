import SwiftUI
import AnytypeCore
import SharedContentManager
import Services

@MainActor
final class SharingExtensionViewModel: ObservableObject {
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.sharedContentManager)
    private var contentManager: any SharedContentManagerProtocol
    @Injected(\.chatActionService)
    private var chatActionService: any ChatActionServiceProtocol
    
    @Published var spaces: [SpaceView] = []
    @Published var selectedSpace: SpaceView?
    // Debug
    @Published var debugInfo: SharedContentDebugInfo? = nil
    
    init() {
        if #available(iOS 17.0, *) {
            SharingTip().invalidate(reason: .actionPerformed)
        }
    }
    
    func onAppear() async {
        await startSpacesSub()
    }
    
    func onTapSpace(_ space: SpaceView) {
        selectedSpace = space
    }
    
    func onTapSend() async throws {
        guard let selectedSpace else { return }
        if selectedSpace.uxType.isChat {
            // TODO: Create chat
        } else {
            // TODO: Open object list
        }
    }
    
    // MARK: - Private
    
    private func setupData() async {
        guard let content = try? await contentManager.getSharedContent() else {
            try? await contentManager.clearSharedContent()
            return
        }
        
        if FeatureFlags.sharingExtensionShowContentTypes {
            debugInfo = content.debugInfo
        }
    }
    
    private func startSpacesSub() async {
        for await participantSpaces in participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values {
            spaces = participantSpaces.filter { $0.canEdit }.map { $0.spaceView }
        }
    }
}
