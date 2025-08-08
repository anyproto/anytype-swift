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
    
    private weak var output: (any SharingExtensionModuleOutput)?
    
    @Published var spaces: [SpaceView] = []
    @Published var selectedSpace: SpaceView?
    @Published var comment: String = ""
    let commentLimit = ChatMessageGlobalLimits.textLimit
    let commentWarningLimit = ChatMessageGlobalLimits.textLimitWarning
    
    // Debug
    @Published var debugInfo: SharedContentDebugInfo? = nil
    
    init(output: (any SharingExtensionModuleOutput)?) {
        self.output = output
        if #available(iOS 17.0, *) {
            SharingTip().invalidate(reason: .actionPerformed)
        }
    }
    
    func onAppear() async {
        async let spacesSub: () = await startSpacesSub()
        async let debugSub: () = await startDebugData()
        
        _ = await (spacesSub, debugSub)
    }
    
    func onTapSpace(_ space: SpaceView) {
        if space.uxType.isChat {
            selectedSpace = space
        } else {
            selectedSpace = nil
            output?.onSelectDataSpace(spaceId: space.targetSpaceId)
        }
    }
    
    func onTapSend() async throws {
        guard let selectedSpace, selectedSpace.uxType.isChat else { return }
        // TODO: Create chat
    }
    
    // MARK: - Private
    
    private func startDebugData() async {
        guard FeatureFlags.sharingExtensionShowContentTypes else { return }
        
        if let content = try? await contentManager.getSharedContent() {
            debugInfo = content.debugInfo
        }
    }
    
    private func startSpacesSub() async {
        for await participantSpaces in participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values {
            spaces = participantSpaces.filter { $0.canEdit }.map { $0.spaceView }
        }
    }
}
