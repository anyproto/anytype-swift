import Foundation
import PhotosUI
import SwiftUI


struct ChatCoordinatorData: Hashable, Codable {
    let chatId: String
    let spaceId: String
}

@MainActor
final class ChatCoordinatorViewModel: ObservableObject, ChatModuleOutput {
    
    let chatId: String
    let spaceId: String
    
    @Published var objectToMessageSearchData: BlockObjectSearchData?
    @Published var showEmojiData: MessageReactionPickerData?
    @Published var showSyncStatusInfo = false
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var linkToObjectData: LinkToObjectSearchModuleData?
    @Published var showFilesPicker = false
    @Published var showPhotosPicker = false
    @Published var photosItems: [PhotosPickerItem] = []
    @Published var participantsReactionData: MessageParticipantsReactionData?
    @Published var safariUrl: URL?
    @Published var cameraData: SimpleCameraData?
    
    private var filesPickerData: ChatFilesPickerData?
    private var photosPickerData: ChatPhotosPickerData?
    
    var pageNavigation: PageNavigation?
    
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    
    init(data: ChatCoordinatorData) {
        self.chatId = data.chatId
        self.spaceId = data.spaceId
    }
    
    func onLinkObjectSelected(data: BlockObjectSearchData) {
        objectToMessageSearchData = data
    }
    
    func didSelectAddReaction(messageId: String) {
        showEmojiData = MessageReactionPickerData(chatObjectId: chatId, messageId: messageId)
    }
    
    func didLongTapOnReaction(data: MessageParticipantsReactionData) {
        participantsReactionData = data
    }
    
    func didSelectLinkToObject(data: LinkToObjectSearchModuleData) {
        linkToObjectData = data
    }
    
    func onObjectSelected(screenData: EditorScreenData) {
        pageNavigation?.push(screenData)
    }
    
    func onMediaFileSelected(startAtIndex: Int, items: [any PreviewRemoteItem]) {
        let previewController = AnytypePreviewController(with: items, initialPreviewItemIndex: startAtIndex)
        navigationContext.present(previewController) { [weak previewController] in
            previewController?.didFinishTransition = true
        }
    }
    
    func onUrlSelected(url: URL) {
        safariUrl = url
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
    
    func onShowCameraSelected(data: SimpleCameraData) {
        cameraData = data
    }
    
    func photosPickerFinished() {
        guard photosItems != photosPickerData?.selectedItems else { return }
        photosPickerData?.handler(photosItems)
    }
    
    func fileImporterFinished(result: Result<[URL], any Error>) {
        filesPickerData?.handler(result)
    }
}
