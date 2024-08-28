import Foundation
import Services

@MainActor
final class MessageViewModel: ObservableObject {
    
    private let data: MessageViewData
    private weak var output: (any MessageModuleOutput)?
    
    private let accountParticipantsStorage: any AccountParticipantsStorageProtocol = Container.shared.accountParticipantsStorage()
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(data.spaceId)
    
    @Published var message: String = ""
    @Published var author: String = ""
    @Published var authorIcon: Icon?
    @Published var date: String = ""
    @Published var isYourMessage: Bool = false
    @Published var reactions: [MessageReactionModel] = []
    @Published var linkedObjects: [ObjectDetails] = []
    
    private var chatMessage: ChatMessage?
    private var authorParticipant: Participant?
    private let yourProfileIdentity: String?
    
    init(data: MessageViewData, output: (any MessageModuleOutput)?) {
        self.data = data
        self.output = output
        self.yourProfileIdentity = accountParticipantsStorage.participants.first?.identity
    }
    
    func subscribeOnBlock() async {
        // TODO: Handle update block
        self.chatMessage = data.message
        updateView()
    }
    
    func subscribeOnAuthor() async {
        let publisher = participantSubscription.participantsPublisher.map { [weak self] in
            $0.first { $0.identity == self?.chatMessage?.creator }
        }.removeDuplicates()
        for await participant in publisher.values {
            authorParticipant = participant
            updateView()
        }
    }
    
    func onTapAddReaction() {
        output?.didSelectAddReaction(messageId: data.message.id)
    }
    
    func onTapReaction(_ reaction: MessageReactionModel) {
        // TODO: Integrate middleware
    }
    
    private func updateView() {
        guard let chatMessage else { return }
        
        message = chatMessage.message.text
        author = authorParticipant?.title ?? ""
        authorIcon = authorParticipant?.icon.map { .object($0) }
        date = chatMessage.createdAtDate.formatted(date: .omitted, time: .shortened)
        isYourMessage = chatMessage.creator == yourProfileIdentity
        
        // TODO: Temporary data. Will be deleted in future
//        let reactionsCount = data.relativeIndex % 5
//        reactions = [
//            MessageReactionModel(emoji: "😍", count: 2, selected: false),
//            MessageReactionModel(emoji: "😗", count: 50, selected: true),
//            MessageReactionModel(emoji: "😎", count: 150, selected: false),
//            MessageReactionModel(emoji: "🤓", count: 4, selected: true),
//            MessageReactionModel(emoji: "👨‍🍳", count: 24, selected: false)
//        ].suffix(reactionsCount)
//        
//        let linkedObjectsCount = data.relativeIndex % 3
//        linkedObjects = [
//            ObjectDetails(id: "1", values: [
//                BundledRelationKey.name.rawValue: "Mock object 1",
//                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
//                BundledRelationKey.iconEmoji.rawValue: "🦜"
//            ]),
//            ObjectDetails(id: "2", values: [
//                BundledRelationKey.name.rawValue: "Mock object 2",
//                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
//                BundledRelationKey.iconEmoji.rawValue: "🐓"
//            ]),
//            ObjectDetails(id: "3", values: [
//                BundledRelationKey.name.rawValue: "Mock object 3",
//                BundledRelationKey.layout.rawValue: DetailsLayout.basic.rawValue.protobufValue,
//                BundledRelationKey.iconEmoji.rawValue: "🦋"
//            ])
//        ].suffix(linkedObjectsCount)
    }
}
