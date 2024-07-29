import Foundation
import Services

@MainActor
final class MessageViewModel: ObservableObject {
    
    private let data: MessageViewData
    private weak var output: MessageModuleOutput?
    
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantsStorage: AccountParticipantsStorageProtocol
    private let documentService: OpenedDocumentsProviderProtocol = Container.shared.documentService()
    private let document: BaseDocumentProtocol
    
    @Published var message: String = ""
    @Published var author: String = ""
    @Published var authorIcon: Icon?
    @Published var date: String = ""
    @Published var isYourMessage: Bool = false
    @Published var reactions: [MessageReactionModel] = []
    @Published var linkedObjects: [ObjectDetails] = []
    
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
    
    func onTapReaction(_ reaction: MessageReactionModel) {
        // TODO: Temporary code. Integrate middleware
        guard let index = reactions.firstIndex(where: { $0.emoji == reaction.emoji }) else { return }
        var newReaction = reaction
        if reaction.selected {
            newReaction.selected = false
            newReaction.count -= 1
        } else {
            newReaction.selected = true
            newReaction.count += 1
        }
        
        if newReaction.count <= 0 {
            reactions.remove(at: index)
        } else {
            reactions[index] = newReaction
        }
    }
    
    private func updateView(block: BlockInformation, textContent: BlockText) {
        let participant = accountParticipantsStorage.participants.first
        
        message = textContent.text
        author = participant?.title ?? ""
        authorIcon = participant?.icon.map { .object($0) }
        date = Date().formatted(date: .omitted, time: .shortened)
        isYourMessage = data.relativeIndex % 2 == 0
        let reactionsCount = data.relativeIndex % 5
        reactions = [
            MessageReactionModel(emoji: "😍", count: 2, selected: false),
            MessageReactionModel(emoji: "😗", count: 50, selected: true),
            MessageReactionModel(emoji: "😎", count: 150, selected: false),
            MessageReactionModel(emoji: "🤓", count: 4, selected: true),
            MessageReactionModel(emoji: "👨‍🍳", count: 24, selected: false)
        ].suffix(reactionsCount)
        
        let linkedObjectsCount = data.relativeIndex % 3
        linkedObjects = [
            ObjectDetails(id: "1", values: [
                BundledRelationKey.name.rawValue: "Mock object 1",
                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                BundledRelationKey.iconEmoji.rawValue: "🦜"
            ]),
            ObjectDetails(id: "2", values: [
                BundledRelationKey.name.rawValue: "Mock object 2",
                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                BundledRelationKey.iconEmoji.rawValue: "🐓"
            ]),
            ObjectDetails(id: "3", values: [
                BundledRelationKey.name.rawValue: "Mock object 3",
                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
                BundledRelationKey.iconEmoji.rawValue: "🦋"
            ])
        ].suffix(linkedObjectsCount)
    }
}
