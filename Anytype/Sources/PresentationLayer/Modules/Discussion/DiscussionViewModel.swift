import Foundation
import Services
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject, MessageModuleOutput {
    
    private let document: BaseDocumentProtocol
    private let spaceId: String
    private weak var output: DiscussionModuleOutput?
    
    private let openDocumentProvider: OpenedDocumentsProviderProtocol = Container.shared.documentService()
    @Injected(\.blockService)
    private var blockService: BlockServiceProtocol
    
    @Published var linkedObjects: [ObjectDetails] = []
    @Published var mesageBlocks: [MessageViewData] = []
    @Published var participants: [Participant] = []
    @Published var message: AttributedString = ""
    @Published var scrollViewPosition = DiscussionScrollViewPosition.none
    
    init(objectId: String, spaceId: String, output: DiscussionModuleOutput?) {
        self.document = openDocumentProvider.document(objectId: objectId)
        self.spaceId = spaceId
        self.output = output
    }
    
    func subscribeForBlocks() async {
        for await blocks in document.childrenPublisher.values {
            self.mesageBlocks = blocks.enumerated().compactMap { (offset, block) in
                guard block.isText else { return nil }
                return MessageViewData(objectId: document.objectId, blockId: block.id, relativeIndex: offset)
            }
            if let last = mesageBlocks.last, scrollViewPosition == .none {
                self.scrollViewPosition = .bottom(last.id)
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
}
