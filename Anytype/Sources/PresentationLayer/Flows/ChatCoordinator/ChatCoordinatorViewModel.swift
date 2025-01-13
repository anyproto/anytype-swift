import Foundation
import PhotosUI
import SwiftUI
import Services

struct ChatCoordinatorData: Hashable {
    let chatId: String
    let spaceInfo: AccountInfo
}

@MainActor
final class ChatCoordinatorViewModel: ObservableObject, ChatModuleOutput {
    
    let chatId: String
    var spaceId: String { info.accountSpaceId }
    
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
    @Published var showSpaceSettingsData: AccountInfo?
    
    private var filesPickerData: ChatFilesPickerData?
    private var photosPickerData: ChatPhotosPickerData?
    private let info: AccountInfo
    
    var pageNavigation: PageNavigation?
    
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    
    init(data: ChatCoordinatorData) {
        self.chatId = data.chatId
        self.info = data.spaceInfo
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
    
    func onObjectSelected(screenData: ScreenData) {
        pageNavigation?.open(screenData)
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
    
    func onWidgetsSelected() {
        pageNavigation?.pushHome()
    }
}
