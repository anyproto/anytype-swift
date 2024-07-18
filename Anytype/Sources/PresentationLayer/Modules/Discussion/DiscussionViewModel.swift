import Foundation
import Services
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject {
    
    private let document: BaseDocumentProtocol
    private let spaceId: String
    private weak var output: DiscussionModuleOutput?
    
    private let openDocumentProvider: OpenedDocumentsProviderProtocol = Container.shared.documentService()
    @Injected(\.activeSpaceParticipantStorage)
    private var participantsStorage: ActiveSpaceParticipantStorageProtocol
    @Injected(\.blockService)
    private var blockService: BlockServiceProtocol
    
    @Published var linkedObjects: [ObjectDetails] = []
    @Published var mesageBlocks: [MessageBlock] = []
    @Published var participants: [Participant] = []
    @Published var message: AttributedString = ""
    @Published var scrollViewPosition = DiscussionScrollViewPosition.bottom("")
    
    init(objectId: String, spaceId: String, output: DiscussionModuleOutput?) {
        self.document = openDocumentProvider.document(objectId: objectId)
        self.spaceId = spaceId
        self.output = output
    }
    
    func subscribeForBlocks() async {
        for await blocks in document.childrenPublisher.values {
            guard let participant = participants.first else { continue }
            var isYour = false
            self.mesageBlocks = blocks.compactMap { block in
                guard block.isText, let textContent = block.textContent else { return nil }
                isYour = !isYour
                return MessageBlock(
                    text: textContent.text,
                    id: block.id,
                    author: participant,
                    createDate: Date(),
                    isYourMessage: isYour
                )
            }
            if let last = mesageBlocks.last {
                self.scrollViewPosition = .bottom(last.id)
            }
        }
    }
    
    func subscribeForParticipants() async {
        for await participants in participantsStorage.activeParticipantsPublisher.values {
            self.participants = participants
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
            _ = try await blockService.add(
                contextId: document.objectId,
                targetId: lastBlock.id,
                info: BlockInformation.empty(content: .text(text)),
                position: .bottom
            )
            message = AttributedString()
        }
    }
    
    func onTapRemoveLinkedObject(details: ObjectDetails) {
        withAnimation {
            linkedObjects.removeAll { $0.id == details.id }
        }
    }
}
