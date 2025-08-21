import Foundation
import Services

@MainActor
protocol ChatModuleOutput: AnyObject {
    func onLinkObjectSelected(data: ObjectSearchWithMetaModuleData)
    func didSelectAddReaction(messageId: String)
    func didLongTapOnReaction(data: MessageParticipantsReactionData)
    func didSelectLinkToObject(data: LinkToObjectSearchModuleData)
    func onObjectSelected(screenData: ScreenData)
    func onPhotosPickerSelected(data: ChatPhotosPickerData)
    func onFilePickerSelected(data: FilesPickerData)
    func onShowCameraSelected(data: SimpleCameraData)
    func onUrlSelected(url: URL)
    func onWidgetsSelected()
    func onInviteLinkSelected()
    func onPushNotificationsAlertSelected()
    func didSelectCreateObject(type: ObjectType)
}
