import Foundation
import Services
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject {
    
    private let baseDocument: BaseDocumentProtocol
    private let spaceId: String
    private weak var output: DiscussionModuleOutput?
    
    private let openDocumentProvider: OpenedDocumentsProviderProtocol = Container.shared.documentService()
    @Injected(\.activeSpaceParticipantStorage)
    private var participantsStorage: ActiveSpaceParticipantStorageProtocol
    
    @Published var linkedObjects: [ObjectDetails] = []
    @Published var mesageBlocks: [MessageBlock] = []
    @Published var participants: [Participant] = []
    
    init(objectId: String, spaceId: String, output: DiscussionModuleOutput?) {
        self.baseDocument = openDocumentProvider.document(objectId: objectId)
        self.spaceId = spaceId
        self.output = output
    }
    
    func subscribeForBlocks() async {
        for await blocks in baseDocument.childrenPublisher.values {
            guard let participant = participants.first else { continue }
            self.mesageBlocks = blocks.compactMap { block in
                guard block.isText, let textContent = block.textContent else { return nil }
                return MessageBlock(text: textContent.text, id: block.id, author: participant)
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
    
    func onTapRemoveLinkedObject(details: ObjectDetails) {
        withAnimation {
            linkedObjects.removeAll { $0.id == details.id }
        }
    }
}
