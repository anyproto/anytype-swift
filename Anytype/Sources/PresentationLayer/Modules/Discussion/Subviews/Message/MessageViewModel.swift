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
    
    @Published var chatMessage: ChatMessage?
    private let yourProfileIdentity: String?
    
    init(data: MessageViewData, output: (any MessageModuleOutput)?) {
        self.data = data
        self.output = output
        self.yourProfileIdentity = accountParticipantsStorage.participants.first?.identity
        updateView()
    }
    
    func onTapAddReaction() {
        output?.didSelectAddReaction(messageId: data.message.id)
    }
    
    func onTapReaction(_ reaction: MessageReactionModel) {
        // TODO: Integrate middleware
    }
    
    private func updateView() {
//        guard let chatMessage else { return }
        let chatMessage = data.message
        let authorParticipant = data.participant
        
        message = chatMessage.message.text
        author = authorParticipant?.title ?? ""
        authorIcon = authorParticipant?.icon.map { .object($0) }
        date = chatMessage.createdAtDate.formatted(date: .omitted, time: .shortened)
        isYourMessage = chatMessage.creator == yourProfileIdentity
        
        reactions = chatMessage.reactions.reactions.map { (key, value) in
            MessageReactionModel(
                emoji: key,
                count: value.ids.count,
                selected: yourProfileIdentity.map { value.ids.contains($0) } ?? false
            )
        }.sorted { $0.count > $1.count }
        
        linkedObjects = chatMessage.attachments.map { ObjectDetails(id: $0.target) }
    }
}
