import Foundation
import Services

@MainActor
final class MessageViewModel: ObservableObject {
    
    private let data: MessageViewData
    private weak var output: MessageModuleOutput?
    
    @Injected(\.activeSpaceParticipantStorage)
    private var participantsStorage: ActiveSpaceParticipantStorageProtocol
    private let documentService: OpenedDocumentsProviderProtocol = Container.shared.documentService()
    private let document: BaseDocumentProtocol
    
    @Published var message: String = ""
    @Published var author: String = ""
    @Published var authorIcon: Icon?
    @Published var date: String = ""
    @Published var isYourMessage: Bool = false
    
    init(data: MessageViewData, output: MessageModuleOutput?) {
        self.data = data
        self.output = output
        self.document = documentService.document(objectId: data.objectId)
    }
    
    func subscribeOnBlock() async {
        for await block in document.subscribeForBlockInfo(blockId: data.blockId).values {
            guard block.isText, let textContent = block.textContent else { return }
            updateView(block: block, textContent: textContent)
        }
    }
    
    func onTapAddReaction() {
        output?.didSelectAddReaction(messageId: data.blockId)
    }
    
    private func updateView(block: BlockInformation, textContent: BlockText) {
        let participant = participantsStorage.participants.first
        
        message = textContent.text
        author = participant?.title ?? ""
        authorIcon = participant?.icon.map { .object($0) }
        date = Date().formatted(date: .omitted, time: .shortened)
        isYourMessage = data.relativeIndex % 2 == 0
    }
}
