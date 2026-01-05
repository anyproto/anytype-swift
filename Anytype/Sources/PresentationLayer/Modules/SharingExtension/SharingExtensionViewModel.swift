import SwiftUI
import AnytypeCore
import SharedContentManager
import Services

@MainActor
@Observable
final class SharingExtensionViewModel {

    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    @Injected(\.sharedContentManager)
    private var contentManager: any SharedContentManagerProtocol
    @ObservationIgnored
    @Injected(\.sharingExtensionActionService)
    private var sharingExtensionActionService: any SharingExtensionActionServiceProtocol

    @ObservationIgnored
    private weak var output: (any SharingExtensionModuleOutput)?
    private var allSpaces: [SpaceView] = []

    var spaces: [SpaceView] = []
    var selectedSpace: SpaceView?
    var comment: String = ""
    var dismiss = false
    var sendInProgress = false
    var searchText: String = ""
    
    var withoutSpaceState: Bool { allSpaces.isEmpty }
    
    let commentLimit = ChatMessageGlobalLimits.textLimit
    let commentWarningLimit = ChatMessageGlobalLimits.textLimitWarning

    // Debug
    var debugInfo: SharedContentDebugInfo? = nil
    
    init(output: (any SharingExtensionModuleOutput)?) {
        self.output = output
        SharingTip().invalidate(reason: .actionPerformed)
    }
    
    func onAppear() async {
        async let spacesSub: () = await startSpacesSub()
        async let debugSub: () = await startDebugData()
        
        _ = await (spacesSub, debugSub)
    }
    
    func onTapSpace(_ space: SpaceView) {
        if !space.uxType.supportsMultiChats {
            selectedSpace = space == selectedSpace ? nil : space
        } else {
            selectedSpace = nil
            output?.onSelectDataSpace(spaceId: space.targetSpaceId)
        }
    }

    func onTapSend() async throws {
        sendInProgress = true
        defer { sendInProgress = false }

        guard let selectedSpace, !selectedSpace.uxType.supportsMultiChats else { return }
        
        let content = try await contentManager.getSharedContent()
        
        try await sharingExtensionActionService.saveObjects(
            spaceId: selectedSpace.targetSpaceId,
            content: content,
            linkToObjects: [],
            chatId: selectedSpace.chatId,
            comment: comment
        )
        try await contentManager.clearSharedContent()
        
        dismiss.toggle()
    }
    
    func search() {
        spaces = searchText.isNotEmpty ? allSpaces.filter { $0.title.lowercased().contains(searchText.lowercased()) } : allSpaces
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
            allSpaces = participantSpaces.filter { $0.canEdit }.map { $0.spaceView }
            search()
        }
    }
}
