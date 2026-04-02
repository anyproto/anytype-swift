import AnytypeCore
import SwiftUI
import Services
import SharedContentManager

enum SharingExtensionChatDisplayMode {
    case sendToChat(SharingExtensionsChatRowData)
    case individualChats([SharingExtensionsShareRowData])
}

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
    private var individualChatDetails: [ObjectDetails] = []
    @ObservationIgnored
    private let sendToChatTitle = Loc.Sharing.sendToChat

    @ObservationIgnored
    private var spaceView: SpaceView?
    var title: String { spaceView?.title ?? "" }
    var sendToChatSelected: Bool { selectedObjectId == spaceView?.chatId }
    private var isMultiChatSpace: Bool {
        if FeatureFlags.createChannelFlow {
            return spaceView.map { $0.spaceType != .oneToOne } ?? false
        }
        return spaceView?.uxType.supportsMultiChats ?? false
    }

    // Returns the selected chat ID (either from generic chat row or from individual chat selection)
    private var selectedChatId: String? {
        if sendToChatSelected {
            return spaceView?.chatId
        }
        if let selectedObjectId, individualChatDetails.contains(where: { $0.id == selectedObjectId }) {
            return selectedObjectId
        }
        return nil
    }

    var chatSelected: Bool { selectedChatId != nil }

    var searchText: String = ""
    var rows: [SharingExtensionsShareRowData] = []
    var chatDisplayMode: SharingExtensionChatDisplayMode?
    var selectedObjectId: String?
    var dismiss = false
    var sendInProgress = false

    var comment: String = ""
    let commentLimit = ChatMessageGlobalLimits.textLimit
    let commentWarningLimit = ChatMessageGlobalLimits.textLimitWarning
    
    init(data: SharingExtensionShareToData, output: (any SharingExtensionShareToModuleOutput)?) {
        self.data = data
        self.output = output
        self.spaceView = workspacesStorage.spaceView(spaceId: data.spaceId)
        self.selectedObjectId = data.suggestedChatId
    }
    
    func search() async {
        
        // Can call each times. Method is optimized
        await activeSpaceManager.prepareSpaceForPreview(spaceId: data.spaceId)
        
        do {
            let layouts: [DetailsLayout]
            if FeatureFlags.createChannelFlow {
                layouts = DetailsLayout.supportedForSharingExtension(spaceType: spaceView?.spaceType)
            } else {
                layouts = DetailsLayout.supportedForSharingExtension(spaceUxType: spaceView?.uxType)
            }
            let result = try await searchService.searchObjectsWithLayouts(
                text: searchText,
                layouts: layouts,
                excludedIds: [],
                spaceId: data.spaceId
            )

            // Separate chats from other objects for multi-chat spaces
            if isMultiChatSpace {
                individualChatDetails = result.filter { $0.resolvedLayoutValue.isChat }
                details = result.filter { !($0.resolvedLayoutValue.isChat) }
            } else {
                individualChatDetails = []
                details = result
            }
        } catch is CancellationError {
            // Ignore cancellations. That means we was run new search.
        } catch {
            individualChatDetails = []
            details = []
        }

        updateRows()
    }
    
    func onTapChat() {
        selectedObjectId = sendToChatSelected ? nil : spaceView?.chatId
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
            chatId: selectedChatId,
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

        if isMultiChatSpace {
            let chatRows = individualChatDetails.map { details in
                SharingExtensionsShareRowData(
                    objectId: details.id,
                    icon: details.objectIconImage,
                    title: details.pluralTitle,
                    subtitle: details.description,
                    selected: selectedObjectId == details.id
                )
            }
            chatDisplayMode = chatRows.isEmpty ? nil : .individualChats(chatRows)
        } else {
            let canShowSendToChat = spaceView?.canAddChatWidget ?? false
            let matchesSearch = searchText.isEmpty || sendToChatTitle.lowercased().contains(searchText.lowercased())
            if canShowSendToChat && matchesSearch {
                chatDisplayMode = .sendToChat(SharingExtensionsChatRowData(title: sendToChatTitle, selected: sendToChatSelected))
            } else {
                chatDisplayMode = nil
            }
        }
    }
}
