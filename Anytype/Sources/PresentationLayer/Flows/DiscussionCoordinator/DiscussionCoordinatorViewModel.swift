import Foundation
import PhotosUI
import SwiftUI
import Services
import AnytypeCore

struct DiscussionCoordinatorData: Hashable, Codable {
    let discussionId: String?
    let objectId: String
    let objectName: String
    let spaceId: String
    let messageId: String?

    init(discussionId: String?, objectId: String, objectName: String, spaceId: String, messageId: String? = nil) {
        self.discussionId = discussionId
        self.objectId = objectId
        self.objectName = objectName
        self.spaceId = spaceId
        self.messageId = messageId
    }
}

@MainActor
@Observable
final class DiscussionCoordinatorViewModel: DiscussionModuleOutput {

    @ObservationIgnored
    var discussionId: String?
    @ObservationIgnored
    let objectId: String
    @ObservationIgnored
    let objectName: String
    @ObservationIgnored
    let spaceId: String
    @ObservationIgnored
    let messageId: String?

    var objectToMessageSearchData: ObjectSearchWithMetaModuleData?
    var showEmojiData: MessageReactionPickerData?
    var linkToObjectData: LinkToObjectSearchModuleData?
    var showFilesPicker = false
    var showPhotosPicker = false
    var pushNotificationsAlertData: PushNotificationsAlertData?
    var showDisabledPushNotificationsAlert = false
    var photosItems: [PhotosPickerItem] = []
    var participantsReactionData: MessageParticipantsReactionData?
    var safariUrl: URL?
    var cameraData: SimpleCameraData?
    var newLinkedObject: EditorScreenData?

    @ObservationIgnored
    private var filesPickerData: FilesPickerData?
    @ObservationIgnored
    private var photosPickerData: ChatPhotosPickerData?

    @ObservationIgnored
    var pageNavigation: PageNavigation?

    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionsService: any ObjectActionsServiceProtocol

    init(data: DiscussionCoordinatorData) {
        self.discussionId = data.discussionId
        self.objectId = data.objectId
        self.objectName = data.objectName
        self.spaceId = data.spaceId
        self.messageId = data.messageId
    }

    func onLinkObjectSelected(data: ObjectSearchWithMetaModuleData) {
        objectToMessageSearchData = data
    }

    func didCreateDiscussion(discussionId: String) {
        self.discussionId = discussionId
    }

    func didSelectAddReaction(messageId: String) {
        guard let discussionId else { return }
        showEmojiData = MessageReactionPickerData(chatObjectId: discussionId, messageId: messageId)
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
