import Foundation
import Services
import SwiftUI
import AnytypeCore

@MainActor
final class MessageViewModel: ObservableObject {
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    private var data: MessageViewData
    private weak var output: (any MessageModuleOutput)?
    
    private let accountParticipantsStorage: any AccountParticipantsStorageProtocol = Container.shared.accountParticipantsStorage()
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(data.spaceId)
    @Injected(\.objectIdsSubscriptionService)
    private var objectIdsSubscriptionService: any ObjectIdsSubscriptionServiceProtocol
    
    @Published var message = AttributedString("")
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
    
    func onTapReaction(_ reaction: MessageReactionModel) async throws {
        try await chatService.toggleMessageReaction(chatObjectId: data.chatId, messageId: data.message.id, emoji: reaction.emoji)
    }
    
    private func updateView() {
        let chatMessage = data.message
        let authorParticipant = data.participant
        
        message = makeMessage(content: chatMessage.message)
        author = authorParticipant?.title ?? ""
        authorIcon = authorParticipant?.icon.map { .object($0) }
        date = chatMessage.createdAtDate.formatted(date: .omitted, time: .shortened)
        isYourMessage = chatMessage.creator == yourProfileIdentity
        reactions = data.reactions
        
        linkedObjects = chatMessage.attachments.map { ObjectDetails(id: $0.target) }
    }
    
    func update(data: MessageViewData) {
        self.data = data
        withAnimation {
            updateView()
        }
        Task {
            await updateSubscription()
        }
    }
    
    func onAppear() {
        Task {
            await updateSubscription()
        }
    }
    
    func onDisappear() {
        Task {
            await objectIdsSubscriptionService.stopSubscription()
        }
    }
    
    // MARK: - Private
    
    private func updateSubscription() async {
        await objectIdsSubscriptionService.startSubscription(objectIds: data.message.attachments.map(\.target)) { [weak self] linkedDetails in
            self?.linkedObjects = linkedDetails
        }
    }
    
    private func makeMessage(content: ChatMessageContent) -> AttributedString {
        var message = AttributedString(content.text)
        
        message.font = AnytypeFontBuilder.font(anytypeFont: .bodyRegular)
        for mark in content.marks.reversed() {
            let nsRange = NSRange(mark.range)
            guard let range = Range(nsRange, in: message) else {
                anytypeAssertionFailure("Out of range", info: ["range": nsRange.description, "textLenght": content.text.count.description])
                continue
            }
            
            switch mark.type {
            case .strikethrough:
                message[range].strikethroughStyle = .single
            case .keyboard:
                message[range].font = AnytypeFontBuilder.font(anytypeFont: .codeBlock)
            case .italic:
                message[range].font = message[range].font?.italic()
            case .bold:
                message[range].font = message[range].font?.bold()
            case .underscored:
                message[range].underlineStyle = .single
            case .link:
                message[range].underlineStyle = .single
            case .object:
                message[range].underlineStyle = .single
            case .textColor:
                message[range].foregroundColor = MiddlewareColor(rawValue: mark.param).map { Color.Dark.color(from: $0) }
            case .backgroundColor:
                message[range].backgroundColor = MiddlewareColor(rawValue: mark.param).map { Color.VeryLight.color(from: $0) }
            case .mention:
                message[range].underlineStyle = .single
            case .emoji:
                message.replaceSubrange(range, with: AttributedString(mark.param))
            case .UNRECOGNIZED(let int):
                anytypeAssertionFailure("Undefined text attribute", info: ["value": int.description, "param": mark.param])
                break
            }
        }
        
        return message
    }
}
