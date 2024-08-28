import Foundation
import Services
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject, MessageModuleOutput {
    
    private let document: any BaseDocumentProtocol
    private let spaceId: String
    private weak var output: (any DiscussionModuleOutput)?
    
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    @Published var linkedObjects: [ObjectDetails] = []
    @Published var mesageBlocks: [MessageViewData] = []
    @Published var participants: [Participant] = []
    @Published var message: AttributedString = ""
    @Published var scrollViewPosition = DiscussionScrollViewPosition.none
    
    private var chatId: String?
    
    init(objectId: String, spaceId: String, output: (any DiscussionModuleOutput)?) {
        self.document = openDocumentProvider.document(objectId: objectId)
        self.spaceId = spaceId
        self.output = output
    }
    
    func startHandleDetails() async {
        for await details in document.detailsPublisher.values {
            if chatId != details.chatId {
                chatId = details.chatId
                try? await updateFullChatList()
            }
        }
    }
    
    func onTapAddObjectToMessage() {
        let data = BlockObjectSearchData(
            title: Loc.linkTo,
            spaceId: spaceId,
            excludedObjectIds: linkedObjects.map(\.id),
            excludedLayouts: [],
            onSelect: { [weak self] details in
                self?.linkedObjects.append(details)
            }
        )
        output?.onLinkObjectSelected(data: data)
    }
    
    func onTapSendMessage() {
        Task {
            guard let lastBlock = document.children.last else { return }
            let text = BlockText(
                text: String(message.characters),
                marks: .empty,
                color: nil,
                contentType: .text,
                checked: false,
                iconEmoji: "",
                iconImage: ""
            )
            let blockId = try await blockService.add(
                contextId: document.objectId,
                targetId: lastBlock.id,
                info: BlockInformation.empty(content: .text(text)),
                position: .bottom
            )
            message = AttributedString()
            scrollViewPosition = .bottom(blockId)
        }
    }
    
    func onTapRemoveLinkedObject(details: ObjectDetails) {
        withAnimation {
            linkedObjects.removeAll { $0.id == details.id }
        }
    }
    
    func didSelectAddReaction(messageId: String) {
        output?.didSelectAddReaction(messageId: messageId)
    }
    
    private func updateFullChatList() async throws {
        guard let chatId else { return }
        let messages = try await chatService.getMessages(chatObjectId: chatId)
        mesageBlocks = messages.map { MessageViewData(
            spaceId: document.spaceId,
            objectId: document.objectId,
            message: $0,
            relativeIndex: 0)
        }
    }
}
