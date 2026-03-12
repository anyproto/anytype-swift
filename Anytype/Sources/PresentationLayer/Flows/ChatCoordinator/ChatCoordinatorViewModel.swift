import Foundation
import PhotosUI
import SwiftUI
import Services
import AnytypeCore

struct ChatCoordinatorData: Hashable, Codable {
    let chatId: String
    let spaceId: String
    let messageId: String?

    init(chatId: String, spaceId: String, messageId: String? = nil) {
        self.chatId = chatId
        self.spaceId = spaceId
        self.messageId = messageId
    }
}

@MainActor
@Observable
final class ChatCoordinatorViewModel: ChatModuleOutput, ObjectSettingsCoordinatorOutput {
    
    @ObservationIgnored
    let chatId: String
    @ObservationIgnored
    let spaceId: String
    @ObservationIgnored
    let messageId: String?
    
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
    var dismiss = false

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
        self.messageId = data.messageId
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
        let widgetData = HomeWidgetData(spaceId: spaceId)
        pageNavigation?.open(.alert(.widgets(widgetData)))
    }

    func onSpaceSettingsSelected() {
        pageNavigation?.open(.spaceInfo(.settings(spaceId: spaceId)))
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

    // MARK: - ObjectSettingsCoordinatorOutput

    func closeEditor() {
        dismiss.toggle()
    }

    func showEditorScreen(data: ScreenData) {
        pageNavigation?.open(data)
    }

    func didCreateLinkToItself(selfName: String, data: ScreenData) {
        anytypeAssertionFailure("Unsupported method: didCreateLinkToItself")
    }

    func didCreateTemplate(templateId: String) {
        anytypeAssertionFailure("Unsupported method: didCreateTemplate")
    }

    func didTapUseTemplateAsDefault(templateId: String) {
        anytypeAssertionFailure("Unsupported method: didTapUseTemplateAsDefault")
    }

    func didUndoRedo() {
        anytypeAssertionFailure("Unsupported method: didUndoRedo")
    }

    func versionRestored(_ text: String) {
        anytypeAssertionFailure("Unsupported method: versionRestored")
    }

    func showInviteMembers(spaceId: String) {
        spaceShareData = SpaceShareData(spaceId: spaceId, route: .chat)
    }
}
