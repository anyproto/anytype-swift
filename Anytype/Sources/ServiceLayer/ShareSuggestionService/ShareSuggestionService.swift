import Intents
import Services
import AnytypeCore
import NotificationsCore

protocol ShareSuggestionServiceProtocol: Sendable {
    func donateInteraction(chatDetails: ObjectDetails, spaceId: String) async
}

final class ShareSuggestionService: ShareSuggestionServiceProtocol, Sendable {

    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @Injected(\.spaceIconStorage)
    private var spaceIconStorage: any SpaceIconStorageProtocol

    func donateInteraction(chatDetails: ObjectDetails, spaceId: String) async {
        guard let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId) else { return }
        
        // Create INPerson for the chat recipient
        let person = INPerson(
            personHandle: INPersonHandle(value: chatDetails.id, type: .unknown),
            nameComponents: nil,
            displayName: displayName(spaceView: spaceView, chatDetails: chatDetails),
            image: await displayIcon(spaceView: spaceView, chatDetails: chatDetails),
            contactIdentifier: nil,
            customIdentifier: chatDetails.id
        )

        // Create the intent for sending a message
        let intent = INSendMessageIntent(
            recipients: [person],
            outgoingMessageType: .outgoingMessageText,
            content: nil,
            speakableGroupName: nil,
            conversationIdentifier: conversationIdentifier(spaceView: spaceView, chatDetails: chatDetails),
            serviceName: nil,
            sender: nil,
            attachments: nil
        )

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .outgoing

        do {
            try await interaction.donate()
        } catch {
            anytypeAssertionFailure("interaction.donate failed", info: ["error": error.localizedDescription])
        }
    }
    
    private func displayIcon(spaceView: SpaceView, chatDetails: ObjectDetails) async -> INImage? {
        switch spaceView.uxType {
        case .chat, .oneToOne:
            return spaceIconStorage.iconLocalUrl(forSpaceId: spaceView.targetSpaceId)
                .flatMap { try? Data(contentsOf: $0) }
                .flatMap { INImage(imageData: $0) }
        case .data, .stream, .none, .UNRECOGNIZED:
            guard let url = chatDetails.objectIcon?.imageId
                .flatMap({ ImageMetadata(id: $0, side: .width(50)).contentUrl }) else { return nil }
            return await AnytypeImageDownloader.retrieveImage(with: url)
                .flatMap { $0.data() }
                .flatMap { INImage(imageData: $0) }
        }
    }
    
    private func displayName(spaceView: SpaceView, chatDetails: ObjectDetails) -> String {
        switch spaceView.uxType {
        case .chat, .oneToOne:
            return spaceView.title
        case .data, .stream, .none, .UNRECOGNIZED:
            return chatDetails.name
        }
    }

    private func conversationIdentifier(spaceView: SpaceView, chatDetails: ObjectDetails) -> String? {
        switch spaceView.uxType {
        case .chat, .oneToOne:
            ConversationIdentifier(spaceId: spaceView.targetSpaceId, chatId: nil).encoded()
        case .data, .stream, .none, .UNRECOGNIZED:
            ConversationIdentifier(spaceId: spaceView.targetSpaceId, chatId: chatDetails.id).encoded()
        }
    }
}

struct ConversationIdentifier: Codable {
    let spaceId: String
    let chatId: String?

    func encoded() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decode(from string: String) -> ConversationIdentifier? {
        guard let data = string.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ConversationIdentifier.self, from: data)
    }
}
