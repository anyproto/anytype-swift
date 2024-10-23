import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class ChatCoordinatorViewModel: ObservableObject, ChatModuleOutput {
    
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    private let document: any BaseDocumentProtocol
    let objectId: String
    let spaceId: String
    
    @Published var objectToMessageSearchData: BlockObjectSearchData?
    @Published var showEmojiData: MessageReactionPickerData?
    @Published var chatId: String?
    @Published var showSyncStatusInfo = false
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var linkToObjectData: LinkToObjectSearchModuleData?
    @Published var showFilesPicker = false
    @Published var showPhotosPicker = false
    @Published var photosItems: [PhotosPickerItem] = []
    
    private var filesPickerData: ChatFilesPickerData?
    private var photosPickerData: ChatPhotosPickerData?
    
    var pageNavigation: PageNavigation?
    
    init(data: EditorChatObject) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
        self.document = openDocumentProvider.document(objectId: objectId, spaceId: spaceId)
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
    
    func didSelectLinkToObject(data: LinkToObjectSearchModuleData) {
        linkToObjectData = data
    }
    
    func onSettingsSelected() {
        // TODO: open settings
    }
    
    func onSyncStatusSelected() {
        showSyncStatusInfo = true
    }
    
    func onIconSelected() {
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func onObjectSelected(screenData: EditorScreenData) {
        pageNavigation?.push(screenData)
    }
    
    func onPhotosPickerSelected(data: ChatPhotosPickerData) {
        photosItems = data.selectedItems
        photosPickerData = data
        showPhotosPicker = true
    }
    
    func onFilePickerSelected(data: ChatFilesPickerData) {
        showFilesPicker = true
        filesPickerData = data
    }
    
    func photosPickerFinished() {
        guard photosItems != photosPickerData?.selectedItems else { return }
        photosPickerData?.handler(photosItems)
    }
    
    func fileImporterFinished(result: Result<[URL], any Error>) {
        filesPickerData?.handler(result)
    }
}
