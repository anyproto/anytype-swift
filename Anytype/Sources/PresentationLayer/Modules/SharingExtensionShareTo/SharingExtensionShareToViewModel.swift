import SwiftUI
import Services
import SharedContentManager

@MainActor
@Observable
final class SharingExtensionShareToViewModel {

    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspacesStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @ObservationIgnored
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @ObservationIgnored
    @Injected(\.sharingExtensionActionService)
    private var sharingExtensionActionService: any SharingExtensionActionServiceProtocol
    @ObservationIgnored
    @Injected(\.sharedContentManager)
    private var contentManager: any SharedContentManagerProtocol

    @ObservationIgnored
    private let data: SharingExtensionShareToData
    @ObservationIgnored
    private weak var output: (any SharingExtensionShareToModuleOutput)?

    @ObservationIgnored
    private var details: [ObjectDetails] = []
    @ObservationIgnored
    private var showChatRow = true
    @ObservationIgnored
    private let chatRowTitle = Loc.Sharing.sendToChat

    @ObservationIgnored
    private var spaceView: SpaceView?
    var title: String { spaceView?.title ?? "" }
    var chatRowSelected: Bool { selectedObjectId == spaceView?.chatId }

    var searchText: String = ""
    var rows: [SharingExtensionsShareRowData] = []
    var selectedObjectId: String?
    var dismiss = false
    var chatRow: SharingExtensionsChatRowData?
    var sendInProgress = false

    var comment: String = ""
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
        
        if spaceView?.canAddChatWidget ?? false {
            showChatRow = searchText.isNotEmpty ? chatRowTitle.lowercased().contains(searchText.lowercased()) : true
        } else {
            showChatRow = false
        }
        
        updateRows()
    }
    
    func onTapChat() {
        selectedObjectId = chatRowSelected ? nil : spaceView?.chatId
        updateRows()
    }
    
    func onTapCell(data: SharingExtensionsShareRowData) {
        selectedObjectId = (selectedObjectId == data.objectId) ? nil : data.objectId
        updateRows()
    }
    
    func onTapSend() async throws {
        sendInProgress = true
        defer { sendInProgress = false }
        
        let content = try await contentManager.getSharedContent()
        let linkToDetails = details.filter { selectedObjectId == $0.id }
        
        try await sharingExtensionActionService.saveObjects(
            spaceId: data.spaceId,
            content: content,
            linkToObjects: linkToDetails,
            chatId: chatRowSelected ? spaceView?.chatId : nil,
            comment: comment
        )
        try await contentManager.clearSharedContent()

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
                selected: selectedObjectId == details.id
            )
        }
        
        chatRow = showChatRow ? SharingExtensionsChatRowData(title: chatRowTitle, selected: chatRowSelected) : nil
    }
}
