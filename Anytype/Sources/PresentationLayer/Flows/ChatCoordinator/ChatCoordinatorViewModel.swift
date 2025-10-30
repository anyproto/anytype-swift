import Foundation
import PhotosUI
import SwiftUI
import Services

struct ChatCoordinatorData: Hashable, Codable {
    let chatId: String
    let spaceId: String
}

@MainActor
@Observable
final class ChatCoordinatorViewModel: ChatModuleOutput {
    
    @ObservationIgnored
    let chatId: String
    @ObservationIgnored
    let spaceId: String
    
    var objectToMessageSearchData: ObjectSearchWithMetaModuleData?
    var showEmojiData: MessageReactionPickerData?
    var showSyncStatusInfo = false
    var objectIconPickerData: ObjectIconPickerData?
    var linkToObjectData: LinkToObjectSearchModuleData?
    var showFilesPicker = false
    var showPhotosPicker = false
    var pushNotificationsAlertData: PushNotificationsAlertData?
    var showDisabledPushNotificationsAlert = false
    var photosItems: [PhotosPickerItem] = []
    var participantsReactionData: MessageParticipantsReactionData?
    var safariUrl: URL?
    var cameraData: SimpleCameraData?
    var showSpaceSettingsData: AccountInfo?
    var newLinkedObject: EditorScreenData?
    var spaceShareData: SpaceShareData?
    var qrCodeInviteLink: URL?
    
    @ObservationIgnored
    private var filesPickerData: FilesPickerData?
    @ObservationIgnored
    private var photosPickerData: ChatPhotosPickerData?
    
    @ObservationIgnored
    var pageNavigation: PageNavigation?
    
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    init(data: ChatCoordinatorData) {
        self.chatId = data.chatId
        self.spaceId = data.spaceId
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
    
    func onFilePickerSelected(data: FilesPickerData) {
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
    
    func onInviteLinkSelected() {
        spaceShareData = SpaceShareData(spaceId: spaceId, route: .chat)
    }

    func onShowQrCodeSelected(url: URL) {
        qrCodeInviteLink = url
    }
    
    func onPushNotificationsAlertSelected() {
        pushNotificationsAlertData = PushNotificationsAlertData(completion: { [weak self] granted in
            self?.showDisabledPushNotificationsAlert = !granted
        })
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
