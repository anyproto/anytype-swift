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
    
    @Published var objectToMessageSearchData: ObjectSearchWithMetaModuleData?
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
    @Published var newLinkedObject: EditorScreenData?
    
    private var filesPickerData: ChatFilesPickerData?
    private var photosPickerData: ChatPhotosPickerData?
    private let info: AccountInfo
    
    var pageNavigation: PageNavigation?
    
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    init(data: ChatCoordinatorData) {
        self.chatId = data.chatId
        self.info = data.spaceInfo
    }
    
    func onLinkObjectSelected(data: ObjectSearchWithMetaModuleData) {
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
    
    func didSelectCreateObject(type: ObjectType) {
        Task {
            let object = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: false,
                spaceId: spaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            newLinkedObject = object.screenData().editorScreenData
        }
    }
}
