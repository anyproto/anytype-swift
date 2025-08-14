import SwiftUI
import Services
import SharedContentManager

@MainActor
final class SharingExtensionShareToViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.sharingExtensionActionService)
    private var sharingExtensionActionService: any SharingExtensionActionServiceProtocol
    @Injected(\.sharedContentManager)
    private var contentManager: any SharedContentManagerProtocol
    
    private let data: SharingExtensionShareToData
    private weak var output: (any SharingExtensionShareToModuleOutput)?
    
    private var details: [ObjectDetails] = []
    private var showChatRow = true
    private let chatRowTitle = Loc.Sharing.sendToChat
    
    private var spaceView: SpaceView?
    var title: String { spaceView?.title ?? "" }
    
    @Published var searchText: String = ""
    @Published var rows: [SharingExtensionsShareRowData] = []
    @Published var selectedObjectIds: Set<String> = []
    @Published var dismiss = false
    @Published var chatRow: SharingExtensionsChatRowData?
    @Published var chatRowSelected = false
    @Published var sendInProgress = false
    
    @Published var comment: String = ""
    let commentLimit = ChatMessageGlobalLimits.textLimit
    let commentWarningLimit = ChatMessageGlobalLimits.textLimitWarning
    
    init(data: SharingExtensionShareToData, output: (any SharingExtensionShareToModuleOutput)?) {
        self.data = data
        self.output = output
        self.spaceView = workspacesStorage.spaceView(spaceId: data.spaceId)
    }
    
    func search() async {
        
        // Can call each times. Method is optimized
        await activeSpaceManager.prepareSpaceForPreview(spaceId: data.spaceId)
        
        do {
            let result = try await searchService.searchObjectsWithLayouts(
                text: searchText,
                layouts: DetailsLayout.supportedForSharingExtension,
                excludedIds: [],
                spaceId: data.spaceId
            )
            details = result
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            details = []
        }
        
        if spaceView?.chatId.isNotEmpty ?? false {
            showChatRow = searchText.isNotEmpty ? chatRowTitle.lowercased().contains(searchText.lowercased()) : true
        } else {
            showChatRow = false
        }
        
        updateRows()
    }
    
    func onTapChat() {
        chatRowSelected = !chatRowSelected
        updateRows()
    }
    
    func onTapCell(data: SharingExtensionsShareRowData) {
        if selectedObjectIds.contains(data.objectId) {
            selectedObjectIds.remove(data.objectId)
        } else {
            selectedObjectIds.insert(data.objectId)
        }
        updateRows()
    }
    
    func onTapSend() async throws {
        sendInProgress = true
        defer { sendInProgress = false }
        
        let content = try await contentManager.getSharedContent()
        let linkToDetails = details.filter { selectedObjectIds.contains($0.id) }
        
        try await sharingExtensionActionService.saveObjects(
            spaceId: data.spaceId,
            content: content,
            linkToObjects: linkToDetails,
            chatId: chatRowSelected ? spaceView?.chatId : nil,
            comment: comment
        )
        try await contentManager.clearSharedContent()
        
        if #available(iOS 16.4, *) {
        } else {
            dismiss.toggle()
        }
        output?.shareToFinished()
    }
    
    // MARK: - Private
    
    private func updateRows() {
        rows = details.compactMap { details in
            SharingExtensionsShareRowData(
                objectId: details.id,
                icon: details.objectIconImage,
                title: details.pluralTitle,
                subtitle: details.description,
                selected: selectedObjectIds.contains(details.id)
            )
        }
        
        chatRow = showChatRow ? SharingExtensionsChatRowData(title: chatRowTitle, selected: chatRowSelected) : nil
    }
}
