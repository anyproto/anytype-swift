import Foundation
import Services
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject, MessageModuleOutput {
    
    private let spaceId: String
    private let objectId: String
    private let chatId: String
    private weak var output: (any DiscussionModuleOutput)?
    
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.chatMessageStorageProvider)
    private var chatMessageStorageProvider: any ChatMessagesStorageProviderProtocol
    private lazy var chatMessageStorage: any ChatMessagesStorageProtocol = Container.shared.chatMessageStorage(chatId)
    
    @Published var linkedObjects: [ObjectDetails] = []
    @Published var mesageBlocks: [MessageViewData] = []
    @Published var participants: [Participant] = []
    @Published var message: AttributedString = ""
    @Published var scrollViewPosition = DiscussionScrollViewPosition.none
    
    init(objectId: String, spaceId: String, chatId: String, output: (any DiscussionModuleOutput)?) {
        self.spaceId = spaceId
        self.objectId = objectId
        self.chatId = chatId
        self.output = output
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
    
    func loadNextPage() {
        Task {
            let newMessages = try await chatMessageStorage.getNextTopPage()
            let newMessagesData = newMessages.map { MessageViewData(spaceId: spaceId, objectId: objectId, chatId: chatId, messageId: $0.id) }
            mesageBlocks = mesageBlocks + newMessagesData
            if let last = newMessages.last {
                scrollViewPosition = .bottom(last.id)
            }
        }
    }
    
    func onTapSendMessage() {
        // TODO: Implement
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
