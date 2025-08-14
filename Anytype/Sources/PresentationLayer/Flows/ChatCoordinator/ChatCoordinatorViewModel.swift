import Foundation
import PhotosUI
import SwiftUI
import Services
import AnytypeCore

struct ChatCoordinatorData: Hashable, Codable {
    let chatId: String
    let spaceId: String
}

@MainActor
final class ChatCoordinatorViewModel: ObservableObject, ChatModuleOutput {
    
    let chatId: String
    let spaceId: String
    
    @Published var objectToMessageSearchData: ObjectSearchWithMetaModuleData?
    @Published var showEmojiData: MessageReactionPickerData?
    @Published var showSyncStatusInfo = false
    @Published var objectIconPickerData: ObjectIconPickerData?
    @Published var linkToObjectData: LinkToObjectSearchModuleData?
    @Published var showFilesPicker = false
    @Published var showPhotosPicker = false
    @Published var pushNotificationsAlertData: PushNotificationsAlertData?
    @Published var showDisabledPushNotificationsAlert = false
    @Published var photosItems: [PhotosPickerItem] = []
    @Published var participantsReactionData: MessageParticipantsReactionData?
    @Published var safariUrl: URL?
    @Published var cameraData: SimpleCameraData?
    @Published var showSpaceSettingsData: AccountInfo?
    @Published var newLinkedObject: EditorScreenData?
    @Published var inviteLinkData: SpaceShareData?
    @Published var spaceShareData: SpaceShareData?
    
    private var filesPickerData: ChatFilesPickerData?
    private var photosPickerData: ChatPhotosPickerData?
    
    var pageNavigation: PageNavigation?
    
    @Injected(\.objectActionsService)
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
    
    func onInviteLinkSelected() {
        let data = SpaceShareData(spaceId: spaceId, route: .chat)
        if FeatureFlags.newSpaceMembersFlow {
            spaceShareData = data
        } else {
            inviteLinkData = data
        }
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
