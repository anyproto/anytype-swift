import Foundation

@MainActor
final class DiscussionCoordinatorViewModel: ObservableObject, DiscussionModuleOutput {
    
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    private let document: any BaseDocumentProtocol
    let objectId: String
    let spaceId: String
    @Published var objectToMessageSearchData: BlockObjectSearchData?
    @Published var showEmojiData: MessageReactionPickerData?
    @Published var chatId: String?
    
    init(data: EditorDiscussionObject) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
        self.document = openDocumentProvider.document(objectId: objectId)
    }
    
    func startHandleDetails() async {
        for await details in document.detailsPublisher.values {
            if chatId.isNil {
                chatId = details.chatId
            }
        }
    }
    
    func onLinkObjectSelected(data: BlockObjectSearchData) {
        objectToMessageSearchData = data
    }
    
    func didSelectAddReaction(messageId: String) {
        guard let chatId else { return }
        showEmojiData = MessageReactionPickerData(chatObjectId: chatId, messageId: messageId)
    }
    
    func onSettingsSelected() {
        // TODO: open settings
    }
    
    func onSyncStatusSelected() {
        // TODO: open sync status
    }
}
